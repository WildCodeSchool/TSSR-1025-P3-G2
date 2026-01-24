# Documentation Technique - Routeur Backbone (DX03)

- **Projet :** EcoTech Solutions - Sprint 2
- **Groupe :** 2
- **Hostname :** `ECO-BDX-DX03`
- **OS :** VyOS

## 1. Rôle et Place dans l'architecture
Ce routeur assure la fonction de **Backbone de Transit**. Il sert de "pont" entre le pare-feu périmétrique (PfSense) et le cœur de réseau interne (DX04).
Il ne porte **aucun VLAN utilisateur** et ne fait pas de NAT. Son rôle est purement le routage de paquets entre les zones de transit.

## 2. Connexions Physiques & Adressage

| Interface | Zone | Connecté à | Adresse IP | CIDR | Passerelle (Next Hop) |
| :--- | :--- | :--- | :--- | :---: | :--- |
| **eth0** | Transit 2 (Wan Side) | PfSense (DX02) | `10.40.10.2` | /28 | `10.40.10.1` |
| **eth1** | Transit 3 (Lan Side) | Cœur L3 (DX04) | `10.40.20.1` | /28 | N/A (Est la GW de DX04) |

## 3. Configuration du Routage (Static Routing)

Ce routeur nécessite deux types de routes pour assurer la connectivité bidirectionnelle.

### 3.1. Route par défaut (Vers Internet)
Tout le trafic sortant vers Internet est redirigé vers le PfSense.
- **Destination :** `0.0.0.0/0`
- **Next Hop :** `10.40.10.1` (Interface LAN du PfSense DX02)

### 3.2. Routes vers le Réseau Interne (Vers le Cœur)
Le Backbone doit savoir où se trouvent les réseaux utilisateurs (10.20.x.x et 10.60.x.x) pour renvoyer les réponses.
Le routage est sommaire (super-netting) pour simplifier la table de routage.

- **Destination :** `10.20.0.0/16` (Zone Infra)
- **Next Hop :** `10.40.20.2` (Interface Uplink du DX04)

- **Destination :** `10.60.0.0/16` (Zone Métiers)
- **Next Hop :** `10.40.20.2` (Interface Uplink du DX04)

*(Note : Une route globale `10.0.0.0/8` vers `10.40.20.2` est aussi possible si aucun autre réseau 10.x.x.x ne se trouve côté PfSense).*

*Voir si changement*
## 4. Services d'Administration
- **SSH :** Port 22
- **Accès :** Restreint aux IPs d'administration (VLAN 210 via le routage).

----
----

# Documentation Technique - Routeur Cœur L3 (DX04)

**Projet :** EcoTech Solutions - Sprint 2
**Groupe :** 2
**Hostname :** `ECO-BDX-DX04`
**OS :** VyOS 
**Rôle :** Cœur de réseau, Routage Inter-VLAN, DHCP Relay.

## 1. Description de l'élément
Le routeur DX04 est le point central de l'infrastructure LAN.
- Il termine les VLANs utilisateurs (Gateway).
- Il route le trafic entre les différents départements (Inter-VLAN).
- Il redirige le trafic Internet vers le Backbone (DX03).

## 2. Topologie Logique

| Interface | Zone | Description | Type | Adresse IP / Masque |
| :--- | :--- | :--- | :--- | :--- |
| **eth0** | **Transit 3** | Vers Backbone DX03 | Uplink | `10.40.20.2/28` |
| **eth1** | **LAN** | Vers Switchs L2 | Trunk (802.1q) | *Voir tableau des VIFs* |

## 3. Configuration des Interfaces Virtuelles (VIF) - Interface eth1

Les adresses IP ci-dessous correspondent aux **passerelles par défaut** configurées sur les postes clients.

> **Note :** Les masques de sous-réseau varient (VLSM) selon les services.

### Zone Infrastructure (10.20.0.0/16)
| VLAN | VIF | Nom du Service | Sous-réseau | Masque | IP Passerelle (DX04) |
| :---: | :---: | :--- | :--- | :---: | :--- |
| **200** | 200 | MGMT (ESXi) | `10.20.0.0` | /24 | `10.20.0.4`* |
| **210** | 210 | DSI / ADMIN | `10.20.10.0` | /24 | `10.20.10.254` |
| **220** | 220 | SERVEURS | `10.20.20.0` | /24 | `10.20.20.254` |

*(\* IP spécifique notée dans le fichier infra dx04.txt)*

### Zone Métiers (10.60.0.0/16)
| Service / Département | VLAN | Réseau IP    | Masque (CIDR) | Nbr IP Utilisables | Passerelle (DX04) |
| --------------------- | ---- | ------------ | ------------- | ------------------ | ----------------- |
| **MGMT (ESXi)**       | 200  | `10.20.0.0`  | **/28**       | 14                 | `10.20.0.4`       |
| **Admin IT** t1       | 210  | `10.20.10.0` | **/28**       | 14                 | `10.20.10.1`      |
| **SERVEURS**          | 220  | `10.20.20.0` | **/27**       | 30                 | `10.20.20.1`      |
| **DIRECTION**         | 600  | `10.60.0.0`  | **/27**       | 62                 | `10.60.0.1`       |
| **DSI**               | 610  | `10.60.10.0` | **/27**       | 32                 | `10.60.10.1`      |
| **DRH**               | 620  | `10.60.20.0` | **/26**       | 32                 | `10.60.20.1`      |
| **COMMERCIAL**        | 630  | `10.60.30.0` | **/25**       | 126                | `10.60.30.1`      |
| **FINANCE / COMPTA**  | 640  | `10.60.40.0` | **/26**       | 62                 | `10.60.40.1`      |
| **COMMUNICATION**     | 650  | `10.60.50.0` | **/26**       | 62                 | `10.60.50.1`      |
| **DÉVELOPPEMENT**     | 660  | `10.60.60.0` | **/26**       | 62                 | `10.60.60.1`      |
| **VOIP / IOT**        | 670  | `10.60.70.0` | **/23**       | 126                | `10.60.70.1`      |
| **NATIVE**            | 999  | -            | -             | -                  | -                 |

## 4. Routage Statique

Le routeur ne connaît pas la route vers Internet par défaut. Une route statique est nécessaire.

- **Route par défaut (0.0.0.0/0)** :
    - **Next Hop :** `10.40.20.1` (Interface eth1 du routeur DX03)
    - **Interface de sortie :** `eth0`

## 5. Services Associés

### DHCP Relay
Les requêtes DHCP des clients (VLANs Métiers) sont relayées vers le serveur DHCP (Windows/Linux) situé dans le VLAN 220.
- **Serveur Cible :** `10.20.20.x` (IP du serveur DHCP à définir).
