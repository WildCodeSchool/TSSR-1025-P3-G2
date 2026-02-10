################################################################################
# Script : install_zabbix_agent_windows.ps1
# Version : 5.2 - URL MSI CORRIGÉE
# Compatible : Windows Server 2008 R2+ / Windows 7+
# PSK : Gestion manuelle
################################################################################

$ErrorActionPreference = "Stop"

$ZABBIX_VERSION = if ($env:ZABBIX_VERSION) { $env:ZABBIX_VERSION } else { "7.4" }
$ZABBIX_SERVER = if ($env:ZABBIX_SERVER) { $env:ZABBIX_SERVER } else { "10.20.20.12" }
$TARGET_HOSTNAME = if ($env:HOSTNAME) { $env:HOSTNAME } else { $env:COMPUTERNAME }
$MODE = if ($env:MODE) { $env:MODE } else { "install" }
$USE_PSK = if ($env:USE_PSK) { $env:USE_PSK } else { "no" }
$PSK_CONTENT = if ($env:PSK_CONTENT) { $env:PSK_CONTENT } else { "" }
$PSK_IDENTITY = if ($env:PSK_IDENTITY) { $env:PSK_IDENTITY } else { "PSK:$TARGET_HOSTNAME" }

$AGENT_SERVICE = "Zabbix Agent 2"
$AGENT_PORT = 10050

$INSTALL_DIR = "C:\Program Files\Zabbix Agent 2"
$CONFIG_FILE = "$INSTALL_DIR\zabbix_agent2.conf"
$PSK_FILE = "$INSTALL_DIR\zabbix_agent2.psk"
$LOG_FILE = "$INSTALL_DIR\zabbix_agent2.log"
$BACKUP_DIR = "C:\ZabbixBackups"

# URLs MSI Zabbix (versions LTS 7.0)
$MSI_URLS = @(
    "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.7/zabbix_agent2-7.0.7-windows-amd64-openssl.msi",
    "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.6/zabbix_agent2-7.0.6-windows-amd64-openssl.msi",
    "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.5/zabbix_agent2-7.0.5-windows-amd64-openssl.msi",
    "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.0/zabbix_agent2-7.0.0-windows-amd64-openssl.msi"
)

$MSI_DOWNLOAD_PATH = "$env:TEMP\zabbix_agent2.msi"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $prefix = switch ($Level) {
        "ERROR"   { "[ERREUR]" }
        "WARNING" { "[ATTENTION]" }
        "SUCCESS" { "[OK]" }
        default   { "[INFO]" }
    }
    
    Write-Host "[$timestamp] $prefix $Message"
}

function Test-AgentInstalled {
    Write-Log "Verification installation..."
    
    $service = Get-Service -Name $AGENT_SERVICE -ErrorAction SilentlyContinue
    if ($service) {
        Write-Log "Service trouve"
        return $true
    }
    
    if (Test-Path $INSTALL_DIR) {
        Write-Log "Repertoire trouve"
        return $true
    }
    
    Write-Log "Aucun agent detecte"
    return $false
}

function Download-ZabbixMSI {
    Write-Log "Recherche meilleure URL de telechargement..."
    
    foreach ($url in $MSI_URLS) {
        Write-Log "Tentative: $url"
        
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($url, $MSI_DOWNLOAD_PATH)
            
            if (Test-Path $MSI_DOWNLOAD_PATH) {
                $fileSize = (Get-Item $MSI_DOWNLOAD_PATH).Length
                if ($fileSize -gt 1MB) {
                    Write-Log "Telechargement reussi ($([math]::Round($fileSize/1MB, 2)) MB)" -Level SUCCESS
                    Write-Log "URL utilisee: $url" -Level INFO
                    return $true
                }
                else {
                    Write-Log "Fichier invalide, tentative suivante..." -Level WARNING
                    Remove-Item $MSI_DOWNLOAD_PATH -Force -ErrorAction SilentlyContinue
                }
            }
        }
        catch {
            Write-Log "Echec: $($_.Exception.Message)" -Level WARNING
        }
    }
    
    Write-Log "Toutes les URLs ont echoue" -Level ERROR
    Write-Log "Telechargement manuel requis depuis: https://www.zabbix.com/download_agents" -Level INFO
    return $false
}

function Install-ZabbixAgent {
    Write-Log "Installation silencieuse..."
    
    $logPath = "$env:TEMP\zabbix_install_${TIMESTAMP}.log"
    
    $args = @(
        "/i", "`"$MSI_DOWNLOAD_PATH`"",
        "/qn",
        "/l*v", "`"$logPath`"",
        "SERVER=`"$ZABBIX_SERVER`"",
        "SERVERACTIVE=`"$ZABBIX_SERVER`"",
        "HOSTNAME=`"$TARGET_HOSTNAME`""
    )
    
    try {
        $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $args -Wait -PassThru -NoNewWindow
        
        if ($proc.ExitCode -in @(0, 1641, 3010)) {
            Write-Log "Installation reussie" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "Erreur installation (code: $($proc.ExitCode))" -Level ERROR
            if (Test-Path $logPath) {
                Write-Log "Log: $logPath" -Level INFO
            }
            return $false
        }
    }
    catch {
        Write-Log "Exception: $_" -Level ERROR
        return $false
    }
}

function Backup-Config {
    if (Test-Path $CONFIG_FILE) {
        if (-not (Test-Path $BACKUP_DIR)) {
            New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
        }
        $backup = "$BACKUP_DIR\zabbix_agent2.conf.backup_$TIMESTAMP"
        Copy-Item -Path $CONFIG_FILE -Destination $backup
        Write-Log "Config sauvegardee"
    }
}

function Configure-Agent {
    Write-Log "Configuration agent..."
    
    Backup-Config
    
    if (-not (Test-Path $CONFIG_FILE)) {
        Write-Log "Config non trouvee" -Level ERROR
        return $false
    }
    
    $config = Get-Content $CONFIG_FILE
    
    function Set-ConfigValue {
        param([string]$Key, [string]$Value, [ref]$Arr)
        
        $pattern = "^$Key\s*="
        $newLine = "$Key=$Value"
        
        $found = $false
        for ($i = 0; $i -lt $Arr.Value.Count; $i++) {
            if ($Arr.Value[$i] -match $pattern) {
                $Arr.Value[$i] = $newLine
                $found = $true
                break
            }
        }
        
        if (-not $found) {
            $commentPattern = "^#\s*$Key\s*="
            for ($i = 0; $i -lt $Arr.Value.Count; $i++) {
                if ($Arr.Value[$i] -match $commentPattern) {
                    $Arr.Value[$i] = $newLine
                    $found = $true
                    break
                }
            }
        }
        
        if (-not $found) {
            $Arr.Value += $newLine
        }
    }
    
    Set-ConfigValue -Key "Server" -Value $ZABBIX_SERVER -Arr ([ref]$config)
    Set-ConfigValue -Key "ServerActive" -Value $ZABBIX_SERVER -Arr ([ref]$config)
    Set-ConfigValue -Key "Hostname" -Value $TARGET_HOSTNAME -Arr ([ref]$config)
    Set-ConfigValue -Key "LogFile" -Value $LOG_FILE -Arr ([ref]$config)
    Set-ConfigValue -Key "LogFileSize" -Value "10" -Arr ([ref]$config)
    
    $config | Set-Content -Path $CONFIG_FILE -Encoding UTF8
    
    Write-Log "Configuration appliquee" -Level SUCCESS
    Write-Log "  Server       : $ZABBIX_SERVER"
    Write-Log "  ServerActive : $ZABBIX_SERVER"
    Write-Log "  Hostname     : $TARGET_HOSTNAME"
    
    return $true
}

function Configure-PSK {
    if ($USE_PSK -ne "yes") {
        Write-Log "PSK desactive - Installation sans chiffrement" -Level WARNING
        return $true
    }
    
    if (-not $PSK_CONTENT) {
        Write-Log "PSK_CONTENT vide - Installation sans chiffrement" -Level ERROR
        return $false
    }
    
    Write-Log "Configuration PSK..."
    
    try {
        $PSK_CONTENT | Set-Content -Path $PSK_FILE -Encoding ASCII -NoNewline
        
        $acl = Get-Acl $PSK_FILE
        $acl.SetAccessRuleProtection($true, $false)
        
        $system = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "NT AUTHORITY\SYSTEM", "FullControl", "Allow"
        )
        $admin = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "BUILTIN\Administrators", "FullControl", "Allow"
        )
        
        $acl.SetAccessRule($system)
        $acl.SetAccessRule($admin)
        Set-Acl -Path $PSK_FILE -AclObject $acl
        
        Write-Log "Fichier PSK cree [OK]" -Level SUCCESS
    }
    catch {
        Write-Log "Erreur creation PSK: $_" -Level ERROR
        return $false
    }
    
    $config = Get-Content $CONFIG_FILE
    
    function Set-ConfigValue {
        param([string]$Key, [string]$Value, [ref]$Arr)
        
        $pattern = "^$Key\s*="
        $newLine = "$Key=$Value"
        
        $found = $false
        for ($i = 0; $i -lt $Arr.Value.Count; $i++) {
            if ($Arr.Value[$i] -match $pattern) {
                $Arr.Value[$i] = $newLine
                $found = $true
                break
            }
        }
        
        if (-not $found) {
            $commentPattern = "^#\s*$Key\s*="
            for ($i = 0; $i -lt $Arr.Value.Count; $i++) {
                if ($Arr.Value[$i] -match $commentPattern) {
                    $Arr.Value[$i] = $newLine
                    $found = $true
                    break
                }
            }
        }
        
        if (-not $found) {
            $Arr.Value += $newLine
        }
    }
    
    Set-ConfigValue -Key "TLSConnect" -Value "psk" -Arr ([ref]$config)
    Set-ConfigValue -Key "TLSAccept" -Value "psk" -Arr ([ref]$config)
    Set-ConfigValue -Key "TLSPSKIdentity" -Value $PSK_IDENTITY -Arr ([ref]$config)
    Set-ConfigValue -Key "TLSPSKFile" -Value $PSK_FILE -Arr ([ref]$config)
    
    $config | Set-Content -Path $CONFIG_FILE -Encoding UTF8
    
    Write-Log "PSK configure [OK]" -Level SUCCESS
    Write-Log "  Identity: $PSK_IDENTITY"
    Write-Log "  Fichier: $PSK_FILE"
    
    return $true
}

function Configure-Firewall {
    Write-Log "Configuration firewall..."
    
    $ruleName = "Zabbix Agent 2 (Port $AGENT_PORT)"
    
    try {
        $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        
        if ($existingRule) {
            Write-Log "Regle deja presente"
            return $true
        }
        
        New-NetFirewallRule `
            -DisplayName $ruleName `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort $AGENT_PORT `
            -RemoteAddress $ZABBIX_SERVER `
            -Action Allow `
            -Profile Any `
            -Description "Zabbix Server -> Agent" | Out-Null
        
        Write-Log "Regle firewall creee" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Configuration firewall via netsh..." -Level WARNING
        
        try {
            netsh advfirewall firewall add rule name="$ruleName" dir=in action=allow protocol=TCP localport=$AGENT_PORT remoteip=$ZABBIX_SERVER | Out-Null
            Write-Log "Regle firewall creee (netsh)" -Level SUCCESS
            return $true
        }
        catch {
            Write-Log "Erreur firewall: $_" -Level ERROR
            return $false
        }
    }
}

function Start-AndVerify {
    Write-Log "Demarrage service..."
    
    try {
        $service = Get-Service -Name $AGENT_SERVICE -ErrorAction Stop
        
        Set-Service -Name $AGENT_SERVICE -StartupType Automatic
        Restart-Service -Name $AGENT_SERVICE -Force
        Start-Sleep 3
        
        $service = Get-Service -Name $AGENT_SERVICE
        
        if ($service.Status -eq "Running") {
            Write-Log "[OK] Service actif" -Level SUCCESS
        } else {
            Write-Log "[ERREUR] Service non actif" -Level ERROR
            return $false
        }
        
        $listening = Get-NetTCPConnection -LocalPort $AGENT_PORT -State Listen -ErrorAction SilentlyContinue
        
        if ($listening) {
            Write-Log "[OK] Port $AGENT_PORT en ecoute" -Level SUCCESS
        } else {
            Write-Log "[ATTENTION] Port non en ecoute" -Level WARNING
        }
        
        return $true
    }
    catch {
        Write-Log "Erreur: $_" -Level ERROR
        return $false
    }
}

function Main {
    Write-Log "===== INSTALLATION AGENT ZABBIX ====="
    Write-Log "Serveur   : $ZABBIX_SERVER"
    Write-Log "Hostname  : $TARGET_HOSTNAME"
    Write-Log "Mode      : $MODE"
    Write-Log "PSK       : $USE_PSK"
    Write-Log "======================================"
    
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Log "ERREUR: Executer en Administrateur" -Level ERROR
        exit 1
    }
    
    $installed = Test-AgentInstalled
    
    if ($MODE -eq "repair") {
        if (-not $installed) {
            Write-Log "ERREUR: Aucun agent" -Level ERROR
            exit 1
        }
        
        Configure-Agent | Out-Null
        Configure-PSK | Out-Null
        Configure-Firewall | Out-Null
        
        if (Start-AndVerify) { exit 0 } else { exit 1 }
    }
    
    if ($installed) {
        Write-Log "Agent present, reconfiguration..." -Level WARNING
        Stop-Service -Name $AGENT_SERVICE -Force -ErrorAction SilentlyContinue
    } else {
        if (-not (Download-ZabbixMSI)) {
            Write-Log "Echec telechargement" -Level ERROR
            exit 1
        }
        
        if (-not (Install-ZabbixAgent)) {
            Write-Log "Echec installation" -Level ERROR
            exit 1
        }
        
        Start-Sleep 5
    }
    
    if (-not (Configure-Agent)) { exit 1 }
    if (-not (Configure-PSK)) { exit 1 }
    Configure-Firewall | Out-Null
    
    if (Start-AndVerify) {
        Write-Log "===== INSTALLATION TERMINEE ====="
        Write-Log "Fichier config : $CONFIG_FILE"
        if ($USE_PSK -eq "yes") {
            Write-Log "Chiffrement PSK : ACTIVE"
            Write-Log "Configurer PSK cote serveur Zabbix !"
        } else {
            Write-Log "Chiffrement PSK : DESACTIVE"
        }
        Write-Log "=================================="
        
        if (Test-Path $MSI_DOWNLOAD_PATH) {
            Remove-Item $MSI_DOWNLOAD_PATH -Force
        }
        exit 0
    } else {
        exit 1
    }
}

Main
