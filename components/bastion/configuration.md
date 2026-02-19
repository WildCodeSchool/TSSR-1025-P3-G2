# Configuration du Serveur Bastion - Apache Guacamole

Dans ce fichier se trouve les étapes de la configuration du serveur Bastion. De la configuration de son réseau dédié à la configuration du serveur en lui même.

## Tables des matière :

- [1. Création de la VLAN 520](#1-création-de-la-vlan-520)
- [2. Configuration des interfaces sur le cluster pfSense](#2-configuration-des-interfaces-sur-le-cluster-pfsense)
- [3. Création de la VIP CARP](#3-création-de-la-vip-carp)
- [4. Création des règles de pare-feu](#4-création-des-règles-de-pare-feu)
- [5. Validation de la configuration](#5-validation-de-la-configuration)
- [6. Synthèse de l'architecture](#6-synthèse-de-larchitecture)

## 1. Création de la VLAN 520

Le serveur bastion nécessite un réseau isolé pour respecter le principe de séparation des responsabilités. Le VLAN 520 a été créé spécifiquement pour héberger cette infrastructure d'administration sécurisée.

Caractéristiques du VLAN 520 :

- Réseau : 10.50.20.0/28
- Passerelle : 10.50.20.1 (VIP CARP haute disponibilité)
- Usage : Administration sécurisée des serveurs

Ce réseau est distinct de la DMZ publique (VLAN 500) pour éviter qu'une compromission des services exposés à Internet n'impacte les accès d'administration.

---

## 2. Configuration des interfaces sur le cluster pfSense

Le bastion étant un point d'accès critique, il bénéficie de la haute disponibilité du cluster pfSense (DX01 et DX02).

### Ajout et configuration des interfaces BASTION

Dans l'interface web de pfSense, accéder à : 
  - Interfaces 
    -  Assignments 
  
Puis ajouter la nouvelle interface réseau disponible.

| Paramètre | Valeur DX01 | Valeur DX02 |
| --- | --- | --- |
| Enable | ✅ Activé | ✅ Activé | 
| Description | BASTION | BASTION | 
| IPv4 Configuration Type | Static IPv4 | Static IPv4 |
| IPv4 Address | 10.50.20.3 / 28 | 10.50.20.4 / 28 |
| IPv6 Configuration Type | None | None |

Sauvegarder et appliquer les changements sur chaque pare-feu. Les deux pare-feu possèdent désormais une interface dédiée sur le réseau du bastion, avec des IPs physiques distinctes.

--- 

## 3. Création de la VIP CARP

La VIP (Virtual IP) CARP permet aux deux pare-feu de partager une adresse IP virtuelle qui bascule automatiquement en cas de panne.

### Configuration de la VIP CARP sur les deux pare-feu

Dans l'interface web de pfSense, accéder à :
  - Firewall
    - Virtual IPs
 
créer ou éditer la VIP CARP avec les paramètres suivants :

| Paramètre | Valeur commune | Valeur DX01 | Valeur DX02 |
| --- | --- | --- | --- |
| Type | CARP | - | - | 
| Interface | BASTION | - | - |
| Address | 10.50.20.1 / 28 | - | - |
| Virtual IP Password | Azerty1* | - | - |
| VHID Group | 2 | - | - | 
| Advertising Frequency - Base | 1 | - | - |
| Advertising Frequency - Skew | - | 0 (MASTER) | 100 (BACKUP) |
| Description| VIP CARP Bastion Gateway | - | - |

Note importante : Grâce à la synchronisation XMLRPC, la VIP est automatiquement créée sur DX02 après sa configuration sur DX01. Seul le paramètre Skew doit être ajusté manuellement sur DX02 pour établir la priorité (BACKUP).

---

## 4. Création des règles de pare-feu

Par défaut, pfSense bloque tout trafic sur une nouvelle interface. Il est nécessaire de créer des règles explicites pour autoriser les flux légitimes.

*⚠️ Cette règle ne sert que pour la phase de configuration.*

*Dans l'interface web de pfSense, accéder à :*
  - *Firewall*
    - *Rules*
      - *BASTION*

*Créer une première règle pour valider la connectivité :*

  - *Action : `Pass`*
  - *Protocol : `Any`*
  - *Sources : `10.50.20.5` (IP Bastion)*
  - *Destination : `any`*
  - *Description : `Test Bastion`*

## 5. Validation de la configuration

Une fois la configuration appliquée, les tests suivants s'effectuent sur le serveur Bastion et attestent une bonne configuration :

``` Bash
# Vérification de l'IP et de la route par défaut
ip addr show
ip route show

# Test de la passerelle (VIP CARP)
ping 10.50.20.1

# Test de sortie vers Internet
ping 8.8.8.8
```

Résultats attendus :

✅ IP du serveur : 10.50.20.5/28
✅ Passerelle par défaut : 10.50.20.1
✅ Ping vers la passerelle : succès
✅ Ping vers Internet : succès

## 6. Synthèse de l'architecture

| Équipement | Interface| IP | Rôle |
| --- | --- | --- | --- |
| pfSense DX01 | BASTION | 10.50.20.3/28 | Pare-feu principal |
| pfSense DX02 | BASTION | 10.50.20.4/28 | Pare-feu backup |
| VIP CARP | BASTION | 10.50.20.1/28 | Passerelle virtuelle HA |
| Serveur Bastion | eth0 | 10.50.20.5/28 | Serveur Guacamole |
