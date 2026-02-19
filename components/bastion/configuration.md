# Configuration du Serveur Bastion - Apache Guacamole

Dans ce fichier se trouve les étapes de la configuration du serveur Bastion. De la configuration de son réseau dédié à la configuration du serveur en lui même.

## Tables des matière :

- [1. Rentrée de la VLAN 520 sue le réseau](#1-rentrée-de-la-vlan-520-sue-le-réseau)
  - [1.2. Configuration des interfaces sur le cluster pfSense](#12-configuration-des-interfaces-sur-le-cluster-pfsense)
  - [1.3. Création de la VIP CARP](#13-création-de-la-vip-carp)     
  - [1.4. Création des règles de pare-feu](#14-création-des-règles-de-pare-feu)
  - [1.5. Validation de la configuration](#15-validation-de-la-configuration)
  - [1.6. Synthèse de l'architecture](#16-synthèse-de-larchitecture)
- [2. Routage inter-VLAN vers le serveur Bastion](#2-routage-inter-vlan-vers-le-serveur-bastion)
  - [2.1. Vérification de la connectivité](#21-vérification-de-la-connectivité)
  - [2.2. Analyse du chemin réseau](#22-analyse-du-chemin-réseau)
  - [2.3. Explication du routage](#23-explication-du-routage)
  - [2.4. Bonne pratique vs implémentation](#24-bonne-pratique-vs-implémentation)
  - [2.5. Validation technique](#25-validation-technique)
- [3. Matrice de routage du réseau Bastion](#3-matrice-de-routage-du-réseau-bastion)

## 1. Rentrée de la VLAN 520 sue le réseau

### 1.2. Configuration des interfaces sur le cluster pfSense

Le bastion étant un point d'accès critique, il bénéficie de la haute disponibilité du cluster pfSense (DX01 et DX02).

#### Ajout et configuration des interfaces BASTION

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

### 1.3. Création de la VIP CARP

La VIP (Virtual IP) CARP permet aux deux pare-feu de partager une adresse IP virtuelle qui bascule automatiquement en cas de panne.

#### Configuration de la VIP CARP sur les deux pare-feu

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

### 1.4. Création des règles de pare-feu

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

### 1.5. Validation de la configuration

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

### 1.6. Synthèse de l'architecture

| Équipement | Interface| IP | Rôle |
| --- | --- | --- | --- |
| pfSense DX01 | BASTION | 10.50.20.3/28 | Pare-feu principal |
| pfSense DX02 | BASTION | 10.50.20.4/28 | Pare-feu backup |
| VIP CARP | BASTION | 10.50.20.1/28 | Passerelle virtuelle HA |
| Serveur Bastion | eth0 | 10.50.20.5/28 | Serveur Guacamole |

## 2. Routage inter-VLAN vers le serveur Bastion

### 2.1. Vérification de la connectivité

Une fois l'infrastructure réseau du bastion configurée sur pfSense, des tests de connectivité ont été effectués depuis différents VLANs de l'infrastructure.

**Test depuis le serveur Active Directory (VLAN 220) :**
```bash
ping 10.50.20.5
traceroute 10.50.20.5
```

**Résultat :** La connectivité fonctionne dans les deux sens, avec un chemin de routage passant par VyOS puis pfSense.

### 2.2. Analyse du chemin réseau

Le traceroute révèle le cheminement suivant :
```
1  10.20.20.1      (VyOS - passerelle VLAN 220)
2  10.40.10.1      (VyOS - interface transit)
3  10.40.0.3       (pfSense DX01 - interface LAN)
4  10.50.20.5      (Serveur Bastion)
```

### 2.3. Explication du routage

Le routeur VyOS utilise sa **route par défaut** (`0.0.0.0/0`) pointant vers pfSense pour acheminer le trafic vers le réseau `10.50.20.0/28`.

**Flux aller (VLAN interne → Bastion) :**

1. Un serveur du VLAN 220 envoie un paquet vers `10.50.20.5`.
2. VyOS consulte sa table de routage et ne trouve pas de route spécifique pour `10.50.20.0/28`.
3. VyOS applique la **route par défaut** et transmet le paquet à pfSense.
4. pfSense connaît le réseau `10.50.20.0/28` car il possède une interface directement connectée.
5. pfSense transmet le paquet au serveur bastion.

**Flux retour (Bastion → VLAN interne) :**

1. Le bastion répond en envoyant le paquet vers sa passerelle `10.50.20.1` (VIP CARP pfSense).
2. pfSense connaît les réseaux internes `10.20.0.0/16` via le routeur VyOS.
3. pfSense transmet le paquet à VyOS.
4. VyOS route le paquet vers le VLAN de destination.

### 2.4. Bonne pratique vs implémentation

**Bonne pratique recommandée :**

Ajouter une route statique explicite sur VyOS :
```
set protocols static route 10.50.20.0/28 next-hop 10.40.0.1
```

**Avantages d'une route spécifique :**
- Clarté architecturale (documentation du réseau plus lisible)
- Performance légèrement supérieure (route directe prioritaire sur route par défaut)
- Résilience (maintien de la connectivité même si la route par défaut change)

**Implémentation actuelle :**

Dans notre cas, la route par défaut suffit car :
- pfSense est le seul point de sortie du réseau interne
- La route par défaut pointe déjà vers pfSense
- Aucune modification de cette route n'est prévue

La connectivité est donc assurée sans configuration supplémentaire sur VyOS.

### 2.5. Validation technique

**Commande de vérification sur VyOS :**
```bash
show ip route 10.50.20.5
```

**Résultat obtenu :** Le routage s'effectue via la route par défaut (`0.0.0.0/0`) vers pfSense.

---

## 3. Matrice de routage du réseau Bastion

| Source | Destination | Routeur 1 (VyOS) | Routeur 2 (pfSense) | Résultat |
|--------|-------------|------------------|---------------------|----------|
| VLAN 220 (10.20.20.x) | Bastion (10.50.20.5) | Route par défaut → pfSense | Interface connectée → Bastion | ✅ Fonctionne |
| Bastion (10.50.20.5) | VLAN 220 (10.20.20.x) | Interface connectée | Route transit → VyOS | ✅ Fonctionne |
