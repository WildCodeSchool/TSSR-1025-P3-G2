<h2 id="haut-de-page">Table des matières</h2>

- [1. VLAN](#vlan)
- [2. Configuration IP par matériel](#configuration)
  - [2.1. VLAN_100](#vlan-100)
  - [2.2. VLAN_110](#vlan-110)


## 1. VLAN
<span id="vlan"><span/>

Le découpage du réseau dans lequel chaque VLAN représente un département avec une plage IP adaptée au nombre d'hôtes dans le réseau.

|      Vlan       |   Département             |    Adresse réseau    |    Broadcast    |      Masque       |   Nombre d'hôte   |
| --------------- | ------------------------- | -------------------- | --------------- | ----------------- | ----------------- |
|    VLAN_10      | VoIP                      | 172.16.10.0          | 172.16.10.255   |        /24        |        243        | 
|    VLAN_20      | IoT                       | 172.16.20.0          | 172.16.20.255   |        /24        |        243        | 
|    VLAN_30      | Développement             | 172.16.30.0          | 172.16.30.255   |        /24        |        116        | 
|    VLAN_40      | Commercial                | 172.16.40.0          | 172.16.40.127   |        /25        |        42         | 
|    VLAN_50      | Communication             | 172.16.50.0          | 172.16.50.127   |        /25        |        38         |  
|    VLAN_60      | DRH                       | 172.16.60.0          | 172.16.60.63    |        /26        |        24         | 
|    VLAN_70      | Finance_Comptabilité      | 172.16.70.0          | 172.16.70.63    |        /26        |        16         | 
|    VLAN_80      | Direction                 | 172.16.90.0          | 172.16.90.15    |        /28        |        6          | 
|    VLAN_90      | DSI                       | 172.16.80.0          | 172.16.80.31    |        /27        |        13         | 
|    VLAN_100     | Serveurs                  | 172.16.100.0         | 172.16.100.15   |        /28        |        10         |
|    VLAN_110     | DMZ                       | 172.16.110.0         | 172.16.110.15   |        /28        |        6          | 
|    VLAN_120     | WAN                       | 172.16.120.0         | 172.16.120.3    |        /30        |        2          | 

## 2. Configuration IP par matériel
<span id="configuration"><span/>

Seules les VLAN_100 (Serveurs) et VLAN_110 (DMZ) seront configurées en statiques.  
Le reste des VLAN seront configurés de manière dynamique via le serveur DHCP.  
La passerelle se trouvera toujours sur la première adresse du réseau.  

### 2.1. VLAN_100 :
<span id="vlan-100"><span/>

|  ID Matériel   |   IP Matériel    |     Masque      |   Passerelle   |
| -------------- | ---------------- | --------------- | -------------- |
| Passerelle     | 172.16.100.1     | 255.255.255.240 |                |
| AD / DNS       | 172.16.100.2     | 255.255.255.240 | 172.16.100.1   |
| DHCP           | 172.16.100.3     | 255.255.255.240 | 172.16.100.1   |
| Messagerie     | 172.16.100.4     | 255.255.255.240 | 172.16.100.1   |
| Stockage       | 172.16.100.5     | 255.255.255.240 | 172.16.100.1   |
| Virtualisation | 172.16.100.6     | 255.255.255.240 | 172.16.100.1   |
| Supervision    | 172.16.100.7     | 255.255.255.240 | 172.16.100.1   |
| Déploiement    | 172.16.100.8     | 255.255.255.240 | 172.16.100.1   |
| GLPI           | 172.16.100.9     | 255.255.255.240 | 172.16.100.1   |

### 2.2. VLAN_110 :
<span id="vlan-110"><span/>

|  ID Matériel   |  IP Matériel    |     Masque      |   Passerelle    |
| -------------- | --------------- | --------------- | --------------- |
|  Passerelle    | 172.16.110.1    | 255.255.255.240 |                 |
|  Messagerie    | 172.16.110.2    | 255.255.255.240 | 172.16.110.1    |
|  Stockage      | 172.16.110.3    | 255.255.255.240 | 172.16.110.1    |
|  WEB           | 172.16.110.4    | 255.255.255.240 | 172.16.110.1    |
|  DNS           | 172.16.110.5    | 255.255.255.240 | 172.16.110.1    |
|  NTP           | 172.16.110.6    | 255.255.255.240 | 172.16.110.1    |

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>





