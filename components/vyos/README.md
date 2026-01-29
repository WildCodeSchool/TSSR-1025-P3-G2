# 1. Routeur Backbone (DX03)

## 1.1 Rôle et Place dans l'architecture - DX03
Ce routeur assure la fonction de **Backbone de Transit**. Il sert de "pont" entre les pare-feux périmétriques (PfSense DX01 - DX02) et le cœur de réseau interne (AX01).
Il ne porte **aucun VLAN utilisateur** et ne fait pas de NAT. Son rôle est purement le routage de paquets entre les zones de transit. Il permet non seulement de superviser le trafic réseau, mais aussi de prévoir l’évolution de l’infrastructure. Grâce à lui, il est possible d’analyser en détail les flux entre les différents segments et de détecter les éventuels goulots d’étranglement ou zones saturées.

## 1.2 Topologie Logique

Cette section décrit comment les équipements sont connectés, en particulier la gestion de la sécurité en entrée de réseau.

## Le Cluster de Pare-feu (DX01 & DX02)
L'accès vers Internet est géré par deux pare-feu pfSense (**DX01** et **DX02**) configurés en **mode cluster**.

**Qu'est-ce qu'un Cluster ?**
C'est une technique qui consiste à faire fonctionner deux machines comme une seule pour assurer la **Haute Disponibilité**.
Si le pare-feu principal tombe en panne, le second prend le relais immédiatement sans couper la connexion. Pour les autres équipements, ce changement est invisible car ils communiquent avec une **adresse IP virtuelle (VIP)** unique, et non avec les adresses physiques des machines.

## Lien avec le Routeur Backbone (DX03)
Le routeur **Backbone (DX03)** est situé dans la zone de **TRANSIT 1** (`10.40.0.0/28`).
Il permet de faire le lien entre le cœur du réseau et la sortie Internet.

Pour garantir la continuité de service, ce routeur n'envoie pas ses données vers DX01 ou DX02 directement, mais vers l'**IP Virtuelle (VIP)** du cluster. Ainsi, la sortie Internet reste fonctionnelle même si un des pare-feu est éteint.

## 1.3 Configuration du Routage (Static Routing)

Le routage sur l'équipement **DX03** est configuré de manière statique pour aiguiller les paquets dans deux directions.

### 1.4 Route par défaut (Vers Internet)
Tout le trafic qui n'est pas destiné au réseau local est envoyé vers l'extérieur.

**Destination :** 0.0.0.0/0 (Internet)
**Interface de sortie :** eth0 (TRANSIT 1)
**Passerelle (Next Hop) (VIP) :** 10.40.0.1 *L'adresse IP virtuelle (VIP) du cluster pfSense*.

### 1.5 Route vers l'interne (Vers le Cœur de Réseau)
Le trafic destiné aux serveurs ou aux PC utilisateurs est renvoyé vers l'intérieur du réseau.

**Destination :** Les réseaux internes de l'entreprise.
**Interface de sortie :** eth1 (TRANSIT 2)
**Passerelle (Next Hop) :** 10.40.10.2 *L'adresse du routeur Cœur L3 DX04*.

### 1.6 Table de Routage - DX03

*Pour le moment le routeur posséde ces routes spécifiques, Il peut en avoir de nouvelles ou quelques changements celon l'avancée du projet*

- **eth0 via DX02**
- **eth1 via AX01**

| Réseau Destination | Masque (CIDR) | Prochain Saut (Next-Hop) | Interface | Description |
|-------------------|---------------|-------------------------|-----------|-------------|
| 0.0.0.0           | /0            | 10.40.10.1              | eth0      | Route par défaut (Internet via PfSense) |
| 10.50.0.0         | /28           | 10.40.10.1              | eth0      | Zone DMZ |
| 10.20.0.0         | /28           | 10.40.20.2              | eth1      | VLAN 200 - MGMT (Core) |
| 10.20.10.0        | /28           | 10.40.20.2              | eth1      | VLAN 210 - Admin IT |
| 10.20.20.0        | /27           | 10.40.20.2              | eth1      | VLAN 220 - Serveurs |
| 10.60.0.0         | /24           | 10.40.20.2              | eth1      | VLAN 600 - Direction |
| 10.60.10.0        | /24           | 10.40.20.2              | eth1      | VLAN 610 - DSI |
| 10.60.20.0        | /24           | 10.40.20.2              | eth1      | VLAN 620 - DRH |
| 10.60.30.0        | /24           | 10.40.20.2              | eth1      | VLAN 630 - Commercial |
| 10.60.40.0        | /24           | 10.40.20.2              | eth1      | VLAN 640 - Finance / Compta |
| 10.60.50.0        | /24           | 10.40.20.2              | eth1      | VLAN 650 - Communication |
| 10.60.60.0        | /24           | 10.40.20.2              | eth1      | VLAN 660 - Développement |
| 10.60.70.0        | /23           | 10.40.20.2              | eth1      | VLAN 670 - VOIP / IOT |

## 1.7 Services d'Administration
- **SSH :** Port 22
- **Accès :** Restreint aux IPs d'administration (VLAN 210 via le routage).

# 2. Routeur Cœur L3 (AX01)

## 2.1 Rôle et Place dans l'architecture - AX01
Le routeur AX01 est le véritable cœur de l'infrastructure réseau d'EcoTech Solutions. Il agit comme une tour de contrôle centrale qui organise et sécurise la circulation des données à l'intérieur de l'entreprise. Ses missions principales se divisent en trois axes :

Porte d'entrée des utilisateurs (Gateway) : C'est le point de passage obligé pour tous les équipements des collaborateurs. En "terminant" les VLANs, il sert de référence (passerelle par défaut) pour chaque ordinateur du parc, leur permettant de sortir de leur propre réseau local.

Aiguillage entre services (Routage Inter-VLAN) : AX01 assure la communication entre les différents départements (par exemple, permettre au service Développement d'accéder aux serveurs de l'unité Infrastructure). Il segmente le trafic pour éviter que tout le réseau ne soit "mélangé", tout en créant des ponts sécurisés là où c'est nécessaire.

Lien vers l'extérieur (Sortie Internet) : Lorsqu'un utilisateur souhaite accéder à une ressource externe, AX01 réceptionne la demande et la redirige intelligemment vers le Backbone (DX03), qui fait office de colonne vertébrale pour acheminer les données vers la sortie du réseau.

## 2.2 Topologie Logique

| Interface | Zone | Description | Type | Adresse IP / Masque |
| :--- | :--- | :--- | :--- | :--- |
| **eth0** | **Transit 3** | Vers Backbone DX03 | Uplink | 10.40.20.2/28 |
| **eth1** | **LAN** | Vers Switchs L2 | Trunk (802.1q) | *Voir tableau des VIFs* |

## 2.3 Routage Statique

Le routeur ne connaît pas la route vers Internet par défaut. Une route statique est nécessaire.

- **Route par défaut (0.0.0.0/0)** :
    - **Next Hop :** 10.40.20.1 (Interface eth1 du routeur DX03)
    - **Interface de sortie :** eth0

La communication entre les VLANs est assurée par le routeur AX01 via le routage inter-VLAN. Aucune route statique n'est nécessaire car les réseaux sont directement connectés aux interfaces du routeur, qui connaît donc nativement les chemins pour acheminer les paquets entre les segments.

## 2.4 Routes vers le Réseau Interne & configuration des Interfaces Virtuelles (VIF - Interface eth1)

Les adresses IP ci-dessous correspondent aux **passerelles par défaut** configurées sur les postes clients.

### Table de Routage - AX01

| VLAN | VIF | Nom du Service | Sous-réseau | Masque | IP Passerelle (DX04) |
| :---: | :---: | :--- | :--- | :---: | :--- |
| **200** | 200 | MGMT (Core) | 10.20.0.0 | /28 | 10.20.0.1 |
| **210** | 210 | DSI / ADMIN | 10.20.10.0 | /28 | 10.20.10.1 |
| **220** | 220 | SERVEURS | 10.20.20.0 | /27 | 10.20.20.1 |

**Note :** Les masques de sous-réseau varient (VLSM) selon les services.

### Table de Routage - AX01

| Service / Département | VLAN | Réseau IP    | Masque (CIDR) | Nbr IP Utilisables | Passerelle (DX04) |
| --------------------- | ---- | ------------ | ------------- | ------------------ | ----------------- |
| **MGMT (Core)**       | 200  | 10.20.0.0  | **/28**       | 14                 | 10.20.0.1      |
| **Admin IT**          | 210  | 10.20.10.0 | **/28**       | 14                 | 10.20.10.1     |
| **SERVEURS**          | 220  | 10.20.20.0 | **/27**       | 30                 | 10.20.20.1     |
| **DIRECTION**         | 600  | 10.60.0.0  | **/24**       | 254                | 10.60.0.1      |
| **DSI**               | 610  | 10.60.10.0 | **/24**       | 254                | 10.60.10.1     |
| **DRH**               | 620  | 10.60.20.0 | **/24**       | 254                | 10.60.20.1     |
| **COMMERCIAL**        | 630  | 10.60.30.0 | **/24**       | 254                | 10.60.30.1     |
| **FINANCE / COMPTA**  | 640  | 10.60.40.0 | **/24**       | 254                | 10.60.40.1     |
| **COMMUNICATION**     | 650  | 10.60.50.0 | **/24**       | 254                | 10.60.50.1     |
| **DÉVELOPPEMENT**     | 660  | 10.60.60.0 | **/24**       | 254                | 10.60.60.1     |
| **VOIP / IOT**        | 670  | 10.60.70.0 | **/23**       | 510                | 10.60.70.1     |
| **Wifi (Radius)**     | 800  | 10.80.0.0  | **/23**       | 510                | 10.80.0.1      |
| **NATIVE**            | 999  | -          | -             | -                  | -              |

**Note :** Les masques de sous-réseau varient (VLSM) selon les services.


## 2.5 Services Associés

### DHCP Relay
Les requêtes DHCP des clients (VLANs Métiers) sont relayées vers le serveur DHCP (Windows/Linux) situé dans le VLAN 220.
- **Serveur Cible :** 10.20.20.8.




















