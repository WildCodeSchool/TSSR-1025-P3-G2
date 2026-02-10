################################################################################
# Script : install_zabbix_agent_windows.ps1
# Version : 6.0 - CORRECTION FINALE (Config corrompu + Service manquant)
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
    Write-Log "Verification repertoire installation..."
    
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
            Write-Log "Installation MSI reussie" -Level SUCCESS
            Start-Sleep 5
            return $true
        }
        else {
            Write-Log "Erreur installation (code: $($proc.ExitCode))" -Level ERROR
            return $false
        }
    }
    catch {
        Write-Log "Exception: $_" -Level ERROR
        return $false
    }
}

function Create-CleanConfig {
    Write-Log "Creation configuration propre..."
    
    # Configuration minimale mais complète
    $configContent = @"
Server=$ZABBIX_SERVER
ServerActive=$ZABBIX_SERVER
Hostname=$TARGET_HOSTNAME

LogFile=$LOG_FILE
LogFileSize=10
"@

    # Ajouter PSK si activé
    if ($USE_PSK -eq "yes") {
        $configContent += @"

TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=$PSK_IDENTITY
TLSPSKFile=$PSK_FILE
"@
    }
    
    # Backup ancien fichier
    if (Test-Path $CONFIG_FILE) {
        if (-not (Test-Path $BACKUP_DIR)) {
            New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
        }
        $backup = "$BACKUP_DIR\zabbix_agent2.conf.backup_$TIMESTAMP"
        Copy-Item -Path $CONFIG_FILE -Destination $backup -ErrorAction SilentlyContinue
        Write-Log "Config sauvegardee: $backup"
    }
    
    # Créer nouveau fichier
    $configContent | Set-Content -Path $CONFIG_FILE -Encoding UTF8
    Write-Log "Configuration creee" -Level SUCCESS
    
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
        # Créer fichier PSK
        $PSK_CONTENT | Set-Content -Path $PSK_FILE -Encoding ASCII -NoNewline
        
        # Permissions restrictives
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
        Write-Log "  Identity: $PSK_IDENTITY"
        Write-Log "  Fichier: $PSK_FILE"
        
        return $true
    }
    catch {
        Write-Log "Erreur creation PSK: $_" -Level ERROR
        return $false
    }
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

function Install-Service {
    Write-Log "Installation du service Windows..."
    
    # Vérifier si le service existe déjà
    $existingService = Get-Service -Name $AGENT_SERVICE -ErrorAction SilentlyContinue
    
    if ($existingService) {
        Write-Log "Service deja present, suppression..." -Level WARNING
        Stop-Service -Name $AGENT_SERVICE -Force -ErrorAction SilentlyContinue
        Start-Sleep 2
        
        & sc.exe delete $AGENT_SERVICE
        Start-Sleep 2
    }
    
    # Installer le service via l'exécutable
    try {
        $exePath = Join-Path $INSTALL_DIR "zabbix_agent2.exe"
        
        if (-not (Test-Path $exePath)) {
            Write-Log "Executable non trouve: $exePath" -Level ERROR
            return $false
        }
        
        Write-Log "Installation service via: $exePath"
        
        & $exePath --config $CONFIG_FILE --install
        
        Start-Sleep 3
        
        # Configurer démarrage automatique
        & sc.exe config $AGENT_SERVICE start= auto
        
        Write-Log "Service installe [OK]" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Erreur installation service: $_" -Level ERROR
        return $false
    }
}

function Start-AndVerify {
    Write-Log "Demarrage service..."
    
    try {
        # Démarrer le service
        & sc.exe start $AGENT_SERVICE
        
        Start-Sleep 5
        
        # Vérifier status
        $service = Get-Service -Name $AGENT_SERVICE -ErrorAction Stop
        
        if ($service.Status -eq "Running") {
            Write-Log "[OK] Service actif" -Level SUCCESS
        } else {
            Write-Log "[ERREUR] Service non actif (status: $($service.Status))" -Level ERROR
            
            # Logs Event Viewer
            Write-Log "Consultation logs..."
            Get-EventLog -LogName Application -Source "Zabbix*" -Newest 5 -ErrorAction SilentlyContinue | 
                ForEach-Object { Write-Log "  $($_.Message)" }
            
            return $false
        }
        
        # Vérifier port
        Start-Sleep 2
        $listening = Get-NetTCPConnection -LocalPort $AGENT_PORT -State Listen -ErrorAction SilentlyContinue
        
        if ($listening) {
            Write-Log "[OK] Port $AGENT_PORT en ecoute" -Level SUCCESS
        } else {
            Write-Log "[ATTENTION] Port non en ecoute" -Level WARNING
        }
        
        return $true
    }
    catch {
        Write-Log "Erreur demarrage: $_" -Level ERROR
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
    
    # Vérifier admin
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Log "ERREUR: Executer en Administrateur" -Level ERROR
        exit 1
    }
    
    $installed = Test-AgentInstalled
    
    # Mode repair
    if ($MODE -eq "repair") {
        if (-not $installed) {
            Write-Log "ERREUR: Aucun agent installe" -Level ERROR
            exit 1
        }
        
        Write-Log "Mode reparation..."
        
        Create-CleanConfig | Out-Null
        Configure-PSK | Out-Null
        Configure-Firewall | Out-Null
        
        # Réinstaller service
        Install-Service | Out-Null
        
        if (Start-AndVerify) { exit 0 } else { exit 1 }
    }
    
    # Mode install
    if ($installed) {
        Write-Log "Agent present, reconfiguration..." -Level WARNING
    } else {
        Write-Log "Nouvelle installation..."
        
        if (-not (Download-ZabbixMSI)) {
            Write-Log "Echec telechargement MSI" -Level ERROR
            exit 1
        }
        
        if (-not (Install-ZabbixAgent)) {
            Write-Log "Echec installation MSI" -Level ERROR
            exit 1
        }
    }
    
    # Configuration
    if (-not (Create-CleanConfig)) { exit 1 }
    if (-not (Configure-PSK)) { exit 1 }
    Configure-Firewall | Out-Null
    
    # Installation et démarrage service
    if (-not (Install-Service)) {
        Write-Log "Echec installation service" -Level ERROR
        exit 1
    }
    
    if (Start-AndVerify) {
        Write-Log "===== INSTALLATION TERMINEE ====="
        Write-Log "Fichier config : $CONFIG_FILE"
        if ($USE_PSK -eq "yes") {
            Write-Log "Chiffrement PSK : ACTIVE"
            Write-Log "IMPORTANT: Configurer PSK dans Zabbix !"
        } else {
            Write-Log "Chiffrement PSK : DESACTIVE"
        }
        Write-Log "=================================="
        
        # Cleanup
        if (Test-Path $MSI_DOWNLOAD_PATH) {
            Remove-Item $MSI_DOWNLOAD_PATH -Force -ErrorAction SilentlyContinue
        }
        
        exit 0
    } else {
        Write-Log "Echec demarrage service" -Level ERROR
        exit 1
    }
}

Main
