
# 1. Référentiel des VLANs et Adressage IP

L'infrastructure d'EcoTech Solutions utilise la plage privée **10.0.0.0/8** (RFC 1918). Ce choix permet une segmentation quasi illimitée tout en conservant une logique d'administration simplifiée.

### 1.1. Nomenclature d'adressage

L'adressage respecte une convention stricte de type **`10.[Zone].[Index].[Hôte]`** :

- **1er octet (10)** : Réseau racine de l'organisation.
- **2ème octet [Zone]** : Identifie la catégorie de sécurité/zone (ex: 20 pour l'Infra).
- **3ème octet [Index]** : Identifie le sous-réseau spécifique (dérivé de l'ID VLAN).
- **4ème octet [Hôte]** : Identifie la machine (statique ou DHCP).

### 1.2. Organisation par Zones de Sécurité (2ème octet)

Cette segmentation permet d'appliquer des politiques de sécurité globales par zone de confiance.

| Catégorie          | **Zone (2ème octet)** | Plage ID VLAN | Description                                                          |
| ------------------ | --------------------- | ------------- | -------------------------------------------------------------------- |
| **INFRASTRUCTURE** | **20**                | 200 à 299     | Coeur de réseau, serveurs AD, fichiers, sauvegarde et management.    |
| **TRANSIT**        | **40**                | 400 à 499     | Liaisons techniques entre les routeurs (pfSense <-> VyOS <-> Coeur). |
| **BORDURE**        | **50**                | 500 à 599     | Services exposés (DMZ Web/Proxy) et accès distants (VPN).            |
| **METIERS**        | **60**                | 600 à 799     | Services utilisateurs (RH, Dev, Com), téléphonie (VoIP) et Lab.      |
| **MOBILITE**       | **80**                | 800 à 899     | Accès sans-fil sécurisé via RADIUS.                                  |
| **SECURITE**       | **99**                | 999           | Isolation des hôtes non conformes ou infectés.                       |

### 1.3. Plan d'adressage détaillé

Le masque de sous-réseau (CIDR) est adapté au besoin réel de chaque segment pour limiter la surface d'attaque et optimiser la diffusion.

| Catégorie    | ID      | Nom          | Plage IP   | CIDR    | Hôtes | Zone de Confiance            |
| ------------ | ------- | ------------ | ---------- | ------- | ----- | ---------------------------- |
| **INFRA**    | **200** | **VLAN_200** | 10.20.0.0  | **/28** | 14    | **P** (Tier 0)               |
| _(+10)_      | **210** | **VLAN_210** | 10.20.10.0 | **/28** | 14    | **S** (Tier 1)               |
|              | **220** | **VLAN_220** | 10.20.20.0 | **/27** | 30    | **S** (Services Core)        |
|              | **230** | **VLAN_230** | 10.20.30.0 | **/28** | 14    | **S** (Fichiers)             |
|              | **240** | **VLAN_240** | 10.20.40.0 | **/29** | 6     | **S** (Bareos)               |
|              | **250** | **VLAN_250** | 10.20.50.0 | **/29** | 6     | **P** (Stockage L2)          |
| **TRANSIT**  | **400** | **VLAN_400** | 10.40.0.0  | **/30** | 2     | **A** (Transit SEC)          |
| _(+10)_      | **410** | **VLAN_410** | 10.40.10.0 | **/30** | 2     | **A** (Transit CORE)         |
| **BORDURE**  | **500** | **VLAN_500** | 10.50.0.0  | **/28** | 14    | **E** (DMZ)                  |
| _(+10)_      | **510** | **VLAN_510** | 10.50.10.0 | **/26** | 62    | **E** (VPN Partenaires)      |
| **METIERS**  | **600** | **VLAN_600** | 10.60.0.0  | **/26** | 62    | **U** (Direction/RH/Finance) |
| _(+10)_      | **610** | **VLAN_610** | 10.60.10.0 | **/24** | 254   | **U** (Pôle Dev)             |
|              | **620** | **VLAN_620** | 10.60.20.0 | **/25** | 126   | **U** (Commercial/Com/DSI)   |
|              | **630** | **VLAN_630** | 10.60.30.0 | **/28** | 14    | **U** (Lab / Tests)          |
|              | **640** | **VLAN_640** | 10.60.40.0 | **/23** | 510   | **R** (VoIP)                 |
| **MOBILITE** | **800** | **VLAN_800** | 10.80.0.0  | **/24** | 254   | **W** (WiFi RADIUS)          |
| **SECURITE** | **999** | **VLAN_999** | 10.99.99.0 | **/24** | 254   | **S** (Quarantaine)          |

### 1.4. Principes d'administration et de sécurité

- **Logique Visuelle :** La corrélation entre l'ID du VLAN et l'IP (ex: VLAN **61**0 -> 10.60.**10**.0) facilite la mémorisation pour les techniciens et accélère le diagnostic lors de l'analyse des logs.
- **Sécurité par l'obscurité :** L'utilisation du deuxième octet par zone permet de créer des règles de pare-feu globales simplifiées. Par exemple, une règle unique peut bloquer tout flux provenant de la zone Mobilité (`10.80.0.0/16`) vers le cœur de l'infrastructure (`10.20.0.0/16`).
- **Scalabilité :** Les réseaux métiers sont fixés en `/24` pour absorber la croissance de l'entreprise (recrutements) sans nécessiter de re-adressage complexe.

## 2. Configuration IP par matériel

Cette section détaille l'adressage statique des interfaces pour chaque équipement critique de l'infrastructure.

### 2.1. Équipements de Sécurité et de Routage

| **Équipement**        | **Interface / Rôle**           | **VLAN** | **Adresse IP**    | **Masque (CIDR)** |
| --------------------- | ------------------------------ | -------- | ----------------- | ----------------- |
| **pfSense**           | WAN (Internet)                 | -        | _DHCP / Fixe FAI_ | -                 |
| (Edge)                | LAN (Interco VyOS Backbone)    | **400**  | 10.40.0.1         | **/28**           |
|                       | DMZ (Interface Virtuelle)      | **500**  | 10.50.0.1         | **/28**           |
|                       | VPN (Tunnel virtuel)           | **510**  | 10.50.10.1        | **/26**           |
| **VyOS**              | eth0 (Interco pfSense)         | **400**  | 10.40.0.2         | **/28**           |
| ( Backbone)           | eth1 (Interco Cœur)            | **410**  | 10.40.10.1        | **/28**           |
|                       | **vif 200 (Management SSH)**   | **200**  | **10.20.0.13**    | **/28**           |
| **VyOS**              | vif 410 (Interco Backbone)     | **410**  | 10.40.10.2        | **/28**           |
| (Cœur)                | **vif 200 (Management SVI)**   | **200**  | **10.20.0.14**    | **/28**           |
|                       | **vif 210 (Gateway PC Admin)** | **210**  | **10.20.10.1**    | **/28**           |
|                       | **Gateways (SVI) Métiers**     | _Multi_  | 10.60.x.1         | **Variable***     |

### 2.2. Infrastructure et Serveurs Critiques (Tableau d'affectation des hôtes)

Pour maintenir une cohérence d'administration, les serveurs utilisent systématiquement l'IP **.5** (ou une plage commençant à .5) dans leur VLAN respectif.

|**Nom (VM/CT)**|**Serveur / Service**|**VLAN**|**Adresse IP**|**Passerelle (GW)**|**Rôle / Justification**|
|---|---|---|---|---|---|
|**ECO-BDX-GX01**  |  **PC d'administration**  |**210**  | 10.20.10.5  | 10.20.10.1 | Poste de pilotage (Management Tier 1)|
|**ECO-BDX-EX01**  |  **Windows AD-01**        | **220** | 10.20.20.5  | 10.20.20.1 | DC Principal (GUI) / DNS / DHCP      |
|**ECO-BDX-EX02**  |  **Windows AD-02 / NPS**  | **220** | 10.20.20.6  | 10.20.20.1 | DC Sec (Core) & RADIUS               |
|**ECO-BDX-EX03**  |  **Serveur de Fichiers**  | **230** | 10.20.30.5  | 10.20.30.1 | Serveur de données Métiers           |
|**ECO-BDX-FX01**  |  **Bareos (Backup)**      | **240** | 10.20.40.5  | 10.20.40.1 | Orchestrateur de sauvegarde          |
|**ECO-BDX-EX04**  |  **Stockage Isolé**       | **250** | 10.20.50.5  |  _Aucune_  | Interface de stockage (L2)           |
|**ECO-BDX-EX05**  |  **FreePBX (VoIP)**       | **640** | 10.60.40.5  | 10.60.40.1 | IP-PBX Téléphonie                    |
|**ECO-BDX-EX06**  |  **Proxy / Web (DMZ)**    | **500** | 10.50.0.5   | 10.50.0.1  | Sortie Web & Site EcoTech            |

### 2.3. Récapitulatif de la hiérarchie des hôtes (Convention .x)

Pour faciliter la mémorisation lors de vos configurations sur Proxmox, nous appliquons cette convention sur l'ensemble du projet :

- **10.[Zone].[Index].1** : Toujours la **Passerelle par défaut** (Gateway).
- **10.[Zone].[Index].5 à 49** : Réservé aux **Serveurs et IPs Statiques**.
- **10.[Zone].[Index].50 à 250** : Plage de distribution **DHCP** (pour les utilisateurs).
- **10.[Zone].[Index].254** : **Interface d'administration** réseau (Switch/Routeur).

## 3. Étendues DHCP et Réservations

Afin de garantir une gestion fluide des 251 collaborateurs et de leurs terminaux, le service DHCP est centralisé sur le serveur **Windows AD (10.20.20.10)**.  
Les adresses sont distribuées à partir de l'IP **.50** pour laisser une plage de sécurité aux équipements à IP fixe (imprimantes, copieurs, postes VIP).

### 3.1. Étendues DHCP (Scopes)

Tous les scopes utilisent les paramètres suivants, sauf mention contraire :

- **DNS Primaire :** 10.20.20.10 (AD)
- **DNS Secondaire :** 10.50.0.1 (pfSense)
- **Suffixe DNS :** **ecotech.local**
- **Durée du bail :** 8 heures (optimisé pour la mobilité)

| **VLAN** | **Réseau**    | **Plage DHCP (Pool)**       | **Passerelle (GW)** | **Usage**              |
| -------- | ------------- | --------------------------- | ------------------- | ---------------------- |
| **600**  | 10.60.0.0/26  | 10.60.0.5 - 10.60.0.55      | 10.60.0.1           | Direction / RH         |
| **610**  | 10.60.10.0/24 | 10.60.10.50 - 10.60.10.250  | 10.60.10.1          | Pôle Développement     |
| **620**  | 10.60.20.0/25 | 10.60.20.5 - 10.60.20.105   | 10.60.20.1          | Commercial / Com / DSI |
| **640**  | 10.60.40.0/23 | 10.60.40.50 - 10.60.41.250  | 10.60.40.1          | Téléphonie IP          |
| **800**  | 10.80.0.0/24  | 10.80.0.50 - 10.80.0.250    | 10.80.0.1           | WiFi RADIUS            |
| **999**  | 10.99.99.0/24 | 10.99.99.100 - 10.99.99.200 | 10.99.99.1          | Quarantaine            |

### 3.2. Mécanisme de Relais DHCP (IP Helper)

Étant donné que le serveur DHCP est situé dans le **VLAN 220** et que les clients sont dans des VLANs différents, un agent de relais est configuré.

- **Emplacement du Relais :** Routeur VyOS (Interfaces virtuelles eth1.x)
- **Configuration :** Sur chaque interface SVI des VLANs 600, 610, 620, 640 et 800, l'adresse de l'assistant (Helper-Address) pointe vers **10.20.20.10**.





