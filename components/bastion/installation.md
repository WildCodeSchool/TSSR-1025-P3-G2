# Configuration du Serveur Bastion - Apache Guacamole

Dans ce fichier se trouvent les étapes de la configuration du serveur Bastion. De la configuration de son réseau dédié à l'installation et la sécurisation du serveur en lui-même.

---

## Table des matières

- [1. Entrée de la VLAN 520 sur le réseau](#1-entrée-de-la-vlan-520-sur-le-réseau)
  - [1.1. Contexte et justification](#11-contexte-et-justification)
  - [1.2. Configuration des interfaces sur le cluster pfSense](#12-configuration-des-interfaces-sur-le-cluster-pfsense)
  - [1.3. Création de la VIP CARP](#13-création-de-la-vip-carp)
  - [1.4. Création des règles de pare-feu](#14-création-des-règles-de-pare-feu)
  - [1.5. Validation de la configuration](#15-validation-de-la-configuration)
  - [1.6. Synthèse de l'architecture réseau](#16-synthèse-de-larchitecture-réseau)
- [2. Routage inter-VLAN vers le serveur Bastion](#2-routage-inter-vlan-vers-le-serveur-bastion)
  - [2.1. Vérification de la connectivité](#21-vérification-de-la-connectivité)
  - [2.2. Analyse du chemin réseau](#22-analyse-du-chemin-réseau)
  - [2.3. Explication du routage](#23-explication-du-routage)
  - [2.4. Validation technique](#24-validation-technique)
  - [2.5. Matrice de routage du réseau Bastion](#25-matrice-de-routage-du-réseau-bastion)
- [3. Installation de Docker et Docker Compose](#3-installation-de-docker-et-docker-compose)
  - [3.1. Mise à jour du système](#31-mise-à-jour-du-système)
  - [3.2. Installation de Docker Engine](#32-installation-de-docker-engine)
  - [3.3. Installation du plugin Docker Compose](#33-installation-du-plugin-docker-compose)
  - [3.4. Choix de sécurité : Docker en mode root](#34-choix-de-sécurité--docker-en-mode-root)
- [4. Installation de Docker et Docker Compose](#4-installation-de-docker-et-docker-compose)
  - [4.1. Mise à jour du système](#41-mise-à-jour-du-système)
  - [4.2. Installation de Docker Engine](#42-installation-de-docker-engine)
  - [4.3. Installation du plugin Docker Compose](#43-installation-du-plugin-docker-compose)
  - [4.4. Choix de sécurité : Docker en mode root](#44-choix-de-sécurité--docker-en-mode-root)
- [5. Déploiement d'Apache Guacamole](#5-déploiement-dapache-guacamole)
  - [5.1. Architecture de Guacamole](#51-architecture-de-guacamole)
  - [5.2. Création de la structure de répertoires](#52-création-de-la-structure-de-répertoires)
  - [5.3. Création du fichier docker-compose.yml](#53-création-du-fichier-docker-composeyml)
  - [5.4. Initialisation de la base de données PostgreSQL](#54-initialisation-de-la-base-de-données-postgresql)
  - [5.5. Lancement de Guacamole](#55-lancement-de-guacamole)
  - [5.6. Validation de la configuration](#56-validation-de-la-configuration)
- [6. Configuration du Reverse Proxy HTTPS avec Nginx](#6-configuration-du-reverse-proxy-https-avec-nginx)
  - [6.1. Contexte et choix architectural](#61-contexte-et-choix-architectural)
  - [6.2. Génération des certificats SSL](#62-génération-des-certificats-ssl)
  - [6.3. Configuration de Nginx](#63-configuration-de-nginx)
  - [6.4. Modification de la stack Docker](#64-modification-de-la-stack-docker)
  - [6.5. Relance de la stack](#65-relance-de-la-stack)
  - [6.6. Tests de validation](#66-tests-de-validation)
  - [6.7. Architecture finale](#67-architecture-finale)
- [7. Configuration DNS](#7-configuration-dns)
  - [7.1. Contexte et principe du moindre privilège](#71-contexte-et-principe-du-moindre-privilège)
  - [7.2. Architecture des flux](#72-architecture-des-flux)
  - [7.3. Règles sur l'interface BASTION (flux sortants)](#73-règles-sur-linterface-bastion-flux-sortants)
  - [7.4. Règles sur l'interface ADMIN (flux entrants)](#74-règles-sur-linterface-admin-flux-entrants)
  - [7.5. Création d'alias (bonne pratique)](#75-création-dalias-bonne-pratique)
  - [7.6. Tests de validation](#76-tests-de-validation)
  - [7.7. Matrice récapitulative des règles](#77-matrice-récapitulative-des-règles)
  - [7.8. Schéma des flux réseau finaux](#78-schéma-des-flux-réseau-finaux)
  - [7.9. Considérations de sécurité](#79-considérations-de-sécurité)
- [8. Synthèse globale](#8-synthèse-globale)
  - [8.1. Composants déployés](#81-composants-déployés)
  - [8.2. Flux de connexion complet](#82-flux-de-connexion-complet)
  - [8.3. Sécurité mise en place](#83-sécurité-mise-en-place)

---

## 1. Entrée de la VLAN 520 sur le réseau

### 1.1. Contexte et justification

Le serveur bastion nécessite un réseau isolé pour respecter le principe de séparation des responsabilités. Le VLAN 520 a été créé spécifiquement pour héberger cette infrastructure d'administration sécurisée.

**Caractéristiques du VLAN 520 :**
- Réseau : `10.50.20.0/28`
- Passerelle : `10.50.20.1` (VIP CARP haute disponibilité)
- Usage : Administration sécurisée des serveurs

Ce réseau est distinct de la DMZ publique (VLAN 500) pour éviter qu'une compromission des services exposés à Internet n'impacte les accès d'administration.

---

### 1.2. Configuration des interfaces sur le cluster pfSense

Le bastion étant un point d'accès critique, il bénéficie de la haute disponibilité du cluster pfSense (DX01 et DX02).

#### Ajout et configuration des interfaces BASTION

Dans l'interface web de pfSense, accéder à :
- Interfaces
  - Assignments

Puis ajouter la nouvelle interface réseau disponible.

| Paramètre | Valeur DX01 | Valeur DX02 |
|-----------|-------------|-------------|
| **Enable** | ✅ Activé | ✅ Activé |
| **Description** | `BASTION` | `BASTION` |
| **IPv4 Configuration Type** | `Static IPv4` | `Static IPv4` |
| **IPv4 Address** | `10.50.20.3 / 28` | `10.50.20.4 / 28` |
| **IPv6 Configuration Type** | `None` | `None` |

Sauvegarder et appliquer les changements sur chaque pare-feu. Les deux pare-feu possèdent désormais une interface dédiée sur le réseau du bastion, avec des IPs physiques distinctes.

---

### 1.3. Création de la VIP CARP

La VIP (Virtual IP) CARP permet aux deux pare-feu de partager une adresse IP virtuelle qui bascule automatiquement en cas de panne.

#### Configuration de la VIP CARP sur les deux pare-feu

Dans l'interface web de pfSense, accéder à :
- Firewall
  - Virtual IPs

Créer ou éditer la VIP CARP avec les paramètres suivants :

| Paramètre | Valeur commune | Valeur DX01 | Valeur DX02 |
|-----------|----------------|-------------|-------------|
| **Type** | `CARP` | - | - |
| **Interface** | `BASTION` | - | - |
| **Address** | `10.50.20.1 / 28` | - | - |
| **Virtual IP Password** | `[Mot de passe sécurisé]` | - | - |
| **VHID Group** | `2` | - | - |
| **Advertising Frequency - Base** | `1` | - | - |
| **Advertising Frequency - Skew** | - | `0` (MASTER) | `100` (BACKUP) |
| **Description** | `VIP CARP Bastion Gateway` | - | - |

**Note importante :** Grâce à la synchronisation XMLRPC, la VIP est automatiquement créée sur DX02 après sa configuration sur DX01. Seul le paramètre **Skew** doit être ajusté manuellement sur DX02 pour établir la priorité (BACKUP).

---

### 1.4. Création des règles de pare-feu

Par défaut, pfSense bloque tout trafic sur une nouvelle interface. Il est nécessaire de créer des règles explicites pour autoriser les flux légitimes.

**⚠️ Cette règle ne sert que pour la phase de configuration.**

Dans l'interface web de pfSense, accéder à :
- Firewall
  - Rules
    - BASTION

Créer une première règle pour valider la connectivité :

| Paramètre | Valeur |
|-----------|--------|
| **Action** | `Pass` |
| **Protocol** | `Any` |
| **Source** | `10.50.20.5` (IP du serveur Bastion) |
| **Destination** | `any` |
| **Description** | `Allow Bastion outbound traffic - TEMP TEST` |

---

### 1.5. Validation de la configuration

Une fois la configuration appliquée, les tests suivants s'effectuent sur le serveur Bastion et attestent une bonne configuration :
```bash
# Vérification de l'IP et de la route par défaut
ip addr show
ip route show

# Test de la passerelle (VIP CARP)
ping -c 3 10.50.20.1

# Test de sortie vers Internet
ping -c 3 8.8.8.8
```

**Résultats attendus :**

✅ IP du serveur : `10.50.20.5/28`  
✅ Passerelle par défaut : `10.50.20.1`  
✅ Ping vers la passerelle : **succès**  
✅ Ping vers Internet : **succès**

---

### 1.6. Synthèse de l'architecture réseau

| Équipement | Interface | IP | Rôle |
|------------|-----------|-----|------|
| **pfSense DX01** | BASTION | `10.50.20.3/28` | Pare-feu principal |
| **pfSense DX02** | BASTION | `10.50.20.4/28` | Pare-feu backup |
| **VIP CARP** | BASTION | `10.50.20.1/28` | Passerelle virtuelle HA |
| **Serveur Bastion** | eth0 | `10.50.20.5/28` | Serveur Guacamole |

---

## 2. Routage inter-VLAN vers le serveur Bastion

### 2.1. Vérification de la connectivité

Une fois l'infrastructure réseau du bastion configurée sur pfSense, des tests de connectivité ont été effectués depuis différents VLANs de l'infrastructure.

**Test depuis le serveur Active Directory (VLAN 220) :**
```bash
ping 10.50.20.5
traceroute 10.50.20.5
```

**Résultat :** La connectivité fonctionne dans les deux sens, avec un chemin de routage passant par VyOS puis pfSense.

---

### 2.2. Analyse du chemin réseau

Le traceroute révèle le cheminement suivant :
```
1  10.20.20.1      (VyOS - passerelle VLAN 220)
2  10.40.10.1      (VyOS - interface transit)
3  10.40.0.3       (pfSense DX01 - interface LAN)
4  10.50.20.5      (Serveur Bastion)
```

---

### 2.3. Explication du routage

Le routeur VyOS utilise sa **route par défaut** (`0.0.0.0/0`) pointant vers pfSense pour acheminer le trafic vers le réseau `10.50.20.0/28`.

**Flux aller (VLAN interne → Bastion) :**

1. Un serveur du VLAN 220 envoie un paquet vers `10.50.20.5`
2. VyOS consulte sa table de routage et ne trouve pas de route spécifique pour `10.50.20.0/28`
3. VyOS applique la **route par défaut** et transmet le paquet à pfSense
4. pfSense connaît le réseau `10.50.20.0/28` car il possède une interface directement connectée
5. pfSense transmet le paquet au serveur bastion

**Flux retour (Bastion → VLAN interne) :**

1. Le bastion répond en envoyant le paquet vers sa passerelle `10.50.20.1` (VIP CARP pfSense)
2. pfSense connaît les réseaux internes `10.20.0.0/16` via le routeur VyOS
3. pfSense transmet le paquet à VyOS
4. VyOS route le paquet vers le VLAN de destination

---

### 2.4. Validation technique

**Commande de vérification sur VyOS :**
```bash
show ip route 10.50.20.5
```

**Résultat obtenu :** Le routage s'effectue via la route par défaut (`0.0.0.0/0`) vers pfSense.

---

### 2.5. Matrice de routage du réseau Bastion

| Source | Destination | Routeur 1 (VyOS) | Routeur 2 (pfSense) | Résultat |
|--------|-------------|------------------|---------------------|----------|
| VLAN 220 (10.20.20.x) | Bastion (10.50.20.5) | Route par défaut → pfSense | Interface connectée → Bastion | ✅ Fonctionne |
| Bastion (10.50.20.5) | VLAN 220 (10.20.20.x) | Interface connectée | Route transit → VyOS | ✅ Fonctionne |

---

## 3. Installation de Docker et Docker Compose

### 3.1. Mise à jour du système

Pour éviter tout conflit de dépendances et les failles de sécurité connues, mise à jour des paquets du système :
```bash
apt update && apt upgrade -y
```

---

### 3.2. Installation de Docker Engine

Installation de Docker via le script officiel :
```bash
# Téléchargement du script officiel Docker
curl -fsSL https://get.docker.com -o get-docker.sh

# Exécution du script
sh get-docker.sh
```

**Explication des options curl :**

| Option | Description |
|--------|-------------|
| `-f` | Arrête si erreur HTTP |
| `-s` | Mode silencieux |
| `-S` | Affiche les erreurs malgré -s |
| `-L` | Suit les redirections |
| `-o` | Sauvegarde dans un fichier |

**Activation et démarrage de Docker :**
```bash
systemctl enable docker
systemctl start docker
```

**Vérification :**
```bash
docker --version
docker ps
```

---

### 3.3. Installation du plugin Docker Compose
```bash
apt install -y docker-compose-plugin
```

**Vérification :**
```bash
docker compose version
```

**Résultat attendu :** `Docker Compose version v5.0.2` (ou supérieure)

---

### 3.4. Choix de sécurité : Docker en mode root

Docker a été installé en mode root (par défaut) pour les raisons suivantes :

**Isolation multi-couches existante :**
- Le serveur bastion est isolé dans un VLAN dédié (520)
- Les règles de pare-feu pfSense limitent strictement les accès
- Le conteneur LXC fournit une première couche d'isolation
- Docker ajoute une isolation supplémentaire au niveau applicatif

**Justification technique :**
- Le mode rootless Docker est principalement recommandé pour les environnements multi-utilisateurs ou les postes de développement
- Sur un serveur dédié avec une fonction unique (bastion d'administration), l'isolation réseau et les règles de pare-feu offrent une protection suffisante
- Le mode rootless aurait complexifié la maintenance sans apport sécuritaire significatif dans ce contexte

**Mesures de sécurité prioritaires :**
- Terminaison SSL/TLS via Nginx (chiffrement des flux)
- Authentification centralisée via LDAP/Active Directory
- Traçabilité des sessions d'administration
- Principe du moindre privilège sur les règles de pare-feu

---

## 4. Installation de Docker et Docker Compose

### 4.1. Mise à jour du système

Avant toute installation, mise à jour des paquets système pour éviter les conflits de dépendances et corriger les vulnérabilités connues :
```bash
apt update && apt upgrade -y
```

---

### 4.2. Installation de Docker Engine

Installation de Docker via le script officiel maintenu par Docker Inc :
```bash
# Téléchargement du script officiel
curl -fsSL https://get.docker.com -o get-docker.sh

# Exécution du script d'installation
sh get-docker.sh
```

**Explication des options curl :**

| Option | Description |
|--------|-------------|
| `-f` | Arrête si erreur HTTP rencontrée |
| `-s` | Mode silencieux (pas de barre de progression) |
| `-S` | Affiche les erreurs malgré le mode silencieux |
| `-L` | Suit les redirections HTTP |
| `-o` | Sauvegarde la sortie dans un fichier |

Le script détecte automatiquement la distribution (Debian 12) et installe les composants nécessaires :
- `docker-ce` : Docker Community Edition
- `docker-ce-cli` : Interface en ligne de commande
- `containerd.io` : Runtime de conteneurs

**Activation et démarrage automatique :**
```bash
systemctl enable docker
systemctl start docker
```

**Vérification de l'installation :**
```bash
docker --version
docker ps
```

**Résultat attendu :** `Docker version 29.2.1` (ou supérieure)

---

### 4.3. Installation du plugin Docker Compose

Docker Compose permet de gérer des applications multi-conteneurs via un fichier de configuration YAML.
```bash
apt install -y docker-compose-plugin
```

**Vérification :**
```bash
docker compose version
```

**Résultat attendu :** `Docker Compose version v5.0.2` (ou supérieure)

**Note sur la syntaxe :** La commande moderne est `docker compose` (avec espace) et non l'ancienne syntaxe `docker-compose` (avec trait d'union).

---

### 4.4. Choix de sécurité : Docker en mode root

Docker a été installé en mode root (configuration par défaut) pour les raisons suivantes :

**Contexte d'isolation multi-couches :**
- Le serveur bastion est isolé dans un VLAN dédié (520)
- Les règles de pare-feu pfSense limitent strictement les accès entrants
- Le conteneur LXC fournit une première couche d'isolation au niveau système
- Docker ajoute une isolation supplémentaire au niveau applicatif

**Justification technique :**
- Le mode rootless Docker est principalement recommandé pour les environnements multi-utilisateurs où plusieurs développeurs partagent un même hôte
- Sur un serveur dédié avec une fonction unique (bastion d'administration), l'isolation réseau et les règles de pare-feu offrent une protection suffisante
- Le mode rootless aurait complexifié la maintenance (permissions, volumes, réseaux) sans apport sécuritaire significatif dans ce contexte

**Mesures de sécurité compensatoires :**
- Terminaison SSL/TLS via Nginx (chiffrement de bout en bout)
- Authentification locale avec mots de passe forts
- Principe du moindre privilège sur les règles de pare-feu
- Traçabilité complète des sessions d'administration via Guacamole

---

## 5. Déploiement d'Apache Guacamole

### 5.1. Architecture de Guacamole

Apache Guacamole est une passerelle d'accès à distance clientless qui permet d'accéder aux serveurs via un simple navigateur web, sans installation de client. L'application repose sur trois composants principaux :

| Composant | Type | Rôle |
|-----------|------|------|
| **guacd** | Daemon | Moteur de protocoles : traduit RDP/SSH/VNC en flux Guacamole (HTML5) |
| **postgres** | Base de données | Stocke la configuration, les utilisateurs, les connexions et l'historique |
| **guacamole** | Application web | Interface utilisateur accessible via navigateur |

Ces trois composants communiquent sur un réseau Docker interne isolé. Seul le port HTTP de Guacamole sera exposé (puis sécurisé via Nginx).

---

### 5.2. Création de la structure de répertoires
```bash
mkdir -p /opt/guacamole
cd /opt/guacamole
```

Ce répertoire contiendra tous les fichiers de configuration et données de la stack Guacamole.

---

### 5.3. Création du fichier docker-compose.yml
```bash
cd /opt/guacamole
nano docker-compose.yml
```

**Contenu du fichier :**
```yaml
version: "3.8"

services:
  # Daemon Guacamole - Gère les protocoles RDP/SSH/VNC
  guacd:
    container_name: guacd
    image: guacamole/guacd
    restart: unless-stopped
    networks:
      - guacamole_net

  # Base de données PostgreSQL
  postgres:
    container_name: postgres_guacamole
    image: postgres:15-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: guacamole_db
      POSTGRES_USER: guacamole_user
      POSTGRES_PASSWORD: [Mot_de_passe_sécurisé]
      PGDATA: /var/lib/postgresql/data/guacamole
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - guacamole_net

  # Interface web Guacamole
  guacamole:
    container_name: guacamole
    image: guacamole/guacamole
    restart: unless-stopped
    environment:
      GUACD_HOSTNAME: guacd
      GUACD_PORT: 4822
      POSTGRESQL_HOSTNAME: postgres
      POSTGRESQL_PORT: 5432
      POSTGRESQL_DATABASE: guacamole_db
      POSTGRESQL_USERNAME: guacamole_user
      POSTGRESQL_PASSWORD: [Mot_de_passe_sécurisé]
    depends_on:
      - guacd
      - postgres
    networks:
      - guacamole_net

networks:
  guacamole_net:
    driver: bridge

volumes:
  postgres_data:
    driver: local
```

**Explications des sections :**

**Service guacd :**
- Port 4822 interne (non exposé sur l'hôte)
- Traduit les protocoles natifs (RDP, SSH, VNC) en protocole Guacamole compréhensible par le navigateur

**Service postgres :**
- Image Alpine (légère)
- Port 5432 interne uniquement
- Volume persistant pour conserver les données en cas de redémarrage
- Stocke : utilisateurs, connexions configurées, permissions, historique des sessions

**Service guacamole :**
- Interface web sur port 8080 (sera exposé temporairement, puis sécurisé via Nginx)
- Se connecte à guacd et postgres via le réseau Docker interne
- `depends_on` garantit que guacd et postgres démarrent en premier

**Réseau :**
- `bridge` : Réseau isolé Docker, les conteneurs communiquent entre eux mais sont isolés de l'hôte

**Volume :**
- `local` : Stockage persistant sur l'hôte, survit aux redémarrages et recréations de conteneurs

---

### 5.4. Initialisation de la base de données PostgreSQL

Avant le premier démarrage de Guacamole, il est nécessaire d'initialiser le schéma de la base de données avec les tables requises.

**Génération du script SQL d'initialisation :**
```bash
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > initdb.sql
```

Cette commande exécute un conteneur temporaire (`--rm` le supprime après exécution) qui génère le script SQL et le redirige vers un fichier local.

**Démarrage de PostgreSQL seul :**
```bash
docker compose up -d postgres
sleep 10
docker compose logs postgres
```

Attendre la ligne : `database system is ready to accept connections`

**Injection du schéma dans la base :**
```bash
docker compose exec -T postgres psql -U guacamole_user -d guacamole_db < initdb.sql
```

**Résultat attendu :** Lignes `CREATE TABLE`, `ALTER TABLE`, `INSERT` confirmant la création de toutes les tables nécessaires.

---

### 5.5. Lancement de Guacamole

**Démarrage de tous les services :**
```bash
docker compose up -d
```

**Vérification de l'état :**
```bash
docker compose ps
```

**Résultat attendu :**
```
NAME                  IMAGE                    STATUS
guacd                 guacamole/guacd          Up
guacamole             guacamole/guacamole      Up
postgres_guacamole    postgres:15-alpine       Up
```

---

### 5.6. Validation de la configuration

**Test local depuis le CT :**
```bash
curl -I http://localhost:8080/guacamole
```

**Résultat attendu :** `HTTP/1.1 302` (redirection normale vers la page de login)

**Test distant depuis un poste admin (VLAN 210) :**

Navigateur : `http://10.50.20.5:8080/guacamole`

**Résultat attendu :** Page de login Apache Guacamole

**Identifiants par défaut :**
- Username : `guacadmin`
- Password : `guacadmin`

---

## 6. Configuration du Reverse Proxy HTTPS avec Nginx

### 6.1. Contexte et choix architectural

#### Problème initial : HAProxy sur pfSense

L'approche initiale consistait à installer HAProxy sur pfSense pour gérer la terminaison SSL/TLS. Cependant, lors de l'installation, une incompatibilité de version PHP a été détectée :
```
WARNING: Current pkg repository has a new PHP major version.
pfSense should be upgraded before installing any new package.
```

#### Solution retenue : Nginx en conteneur Docker

La décision a été prise d'intégrer Nginx directement dans la stack Docker du bastion.

**Avantages techniques :**
- **Isolation complète** : Le reverse proxy est contenu dans l'environnement Docker
- **Portabilité** : L'ensemble de la stack (Guacamole + Nginx) peut être migré facilement vers un autre hôte
- **Cohérence architecturale** : Tous les composants du bastion sont gérés par Docker Compose
- **Indépendance** : Aucune dépendance aux versions de packages pfSense

---

### 6.2. Génération des certificats SSL

#### Création de la structure de répertoires

Pour garantir la cohérence avec l'infrastructure existante (proxy Apache déjà déployé sur le réseau), la structure de certificats suit la même organisation :
```bash
cd /opt/guacamole
mkdir -p ssl/private
mkdir -p ssl/certs
```

#### Génération du certificat auto-signé
```bash
cd /opt/guacamole/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout private/bastion.key \
  -out certs/bastion.crt \
  -subj "/C=FR/ST=Gironde/L=Bordeaux/O=EcoTech/OU=IT/CN=bastion.ecotech.local"
```

**Explication des paramètres :**

| Paramètre | Valeur | Description |
|-----------|--------|-------------|
| `-x509` | - | Génère un certificat auto-signé (non signé par une CA) |
| `-nodes` | - | La clé privée n'est pas chiffrée (pas de passphrase requise) |
| `-days` | `365` | Validité d'un an |
| `-newkey` | `rsa:2048` | Crée une nouvelle clé RSA de 2048 bits |
| `-keyout` | `private/bastion.key` | Chemin de sortie de la clé privée |
| `-out` | `certs/bastion.crt` | Chemin de sortie du certificat |
| `-subj` | `/C=FR/ST=...` | Informations du certificat (évite les questions interactives) |

**Résultat :**

✅ `ssl/private/bastion.key` (1.7 Ko) - Clé privée RSA  
✅ `ssl/certs/bastion.crt` (1.4 Ko) - Certificat public X.509

*Note : En environnement de production, ce certificat devrait être signé par l'autorité de certification interne de l'entreprise (CA EcoTech) pour éviter les avertissements de sécurité dans les navigateurs. Dans le cadre de ce projet de formation, un certificat auto-signé est suffisant pour démontrer la mise en place du chiffrement.*

---

### 6.3. Configuration de Nginx

#### Création du fichier nginx.conf
```bash
cd /opt/guacamole
nano nginx.conf
```

**Contenu du fichier :**
```nginx
events {
    worker_connections 1024;
}

http {
    # Serveur HTTPS (port 443)
    server {
        listen 443 ssl;
        server_name bastion.ecotech.local;

        # Certificats SSL
        ssl_certificate /etc/nginx/ssl/certs/bastion.crt;
        ssl_certificate_key /etc/nginx/ssl/private/bastion.key;

        # Protocoles et chiffrements SSL recommandés
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Redirection automatique de / vers /guacamole/
        location = / {
            return 301 /guacamole/;
        }

        # Configuration du reverse proxy vers Guacamole
        location / {
            proxy_pass http://guacamole:8080;
            proxy_buffering off;
            proxy_http_version 1.1;
            
            # Headers nécessaires pour Guacamole
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            
            # Timeouts pour sessions longues (RDP/SSH persistantes)
            proxy_connect_timeout 7d;
            proxy_send_timeout 7d;
            proxy_read_timeout 7d;
        }
    }

    # Serveur HTTP (port 80) - Redirection vers HTTPS
    server {
        listen 80;
        server_name bastion.ecotech.local;
        return 301 https://$server_name$request_uri;
    }
}
```

#### Explication des directives principales

**Section events :**
- `worker_connections 1024` : Nombre maximum de connexions simultanées par processus worker Nginx

**Serveur HTTPS (port 443) :**
- `listen 443 ssl` : Nginx écoute sur le port 443 avec SSL activé
- `ssl_protocols TLSv1.2 TLSv1.3` : Seuls les protocoles sécurisés sont autorisés (TLS 1.0 et 1.1 sont obsolètes et vulnérables)
- `ssl_ciphers HIGH` : Utilise uniquement des algorithmes de chiffrement forts
- `proxy_pass http://guacamole:8080` : Le trafic est transmis au conteneur Guacamole en HTTP (connexion interne non chiffrée)
- `proxy_http_version 1.1` : **Requis** pour le support du protocole WebSocket utilisé par Guacamole
- Headers `Upgrade` et `Connection` : **Critiques** pour le bon fonctionnement des sessions RDP/SSH via WebSocket
- Timeouts de 7 jours : Permettent les sessions d'administration de longue durée sans déconnexion intempestive

**Serveur HTTP (port 80) :**
- `return 301` : Redirige automatiquement toutes les requêtes HTTP vers HTTPS (force le chiffrement)

---

### 6.4. Modification de la stack Docker

#### Ajout du service Nginx
```bash
cd /opt/guacamole
nano docker-compose.yml
```

**Ajouter le service nginx AU DÉBUT de la section `services` :**
```yaml
  # Reverse Proxy Nginx - Gère HTTPS
  nginx:
    container_name: nginx_reverse_proxy
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl/certs:/etc/nginx/ssl/certs:ro
      - ./ssl/private:/etc/nginx/ssl/private:ro
    depends_on:
      - guacamole
    networks:
      - guacamole_net
```

**Important :** Retirer l'exposition du port 8080 dans le service `guacamole` (supprimer ou commenter la section `ports`).

**Avant :**
```yaml
  guacamole:
    ports:
      - "8080:8080"
```

**Après :**
```yaml
  guacamole:
    # Port 8080 non exposé - accessible uniquement via Nginx sur le réseau Docker interne
```

**Explications :**
- Les ports 443 et 80 sont maintenant exposés uniquement sur Nginx
- Le port 8080 de Guacamole n'est plus accessible depuis l'extérieur
- Seul Nginx peut communiquer avec Guacamole via le réseau Docker `guacamole_net`
- Les volumes sont montés en lecture seule (`:ro`) pour des raisons de sécurité
- `depends_on: guacamole` garantit que Guacamole démarre avant Nginx

---

### 6.5. Relance de la stack
```bash
cd /opt/guacamole
docker compose down
docker compose up -d
```

**Vérification :**
```bash
docker compose ps
```

**Résultat attendu :**
```
NAME                  IMAGE                STATUS
nginx_reverse_proxy   nginx:alpine         Up
guacd                 guacamole/guacd      Up
guacamole             guacamole/guacamole  Up
postgres_guacamole    postgres:15-alpine   Up
```

**4 conteneurs opérationnels.**

**Vérification des logs Nginx :**
```bash
docker compose logs nginx --tail 20
```

Message attendu : `Configuration complete; ready for start up`

---

### 6.6. Tests de validation

**Test d'accès HTTPS depuis un poste admin (VLAN 210) :**

URL : `https://10.50.20.5/guacamole` ou `https://bastion.ecotech.local/guacamole`

**Résultat :**
- ⚠️ Avertissement de certificat auto-signé (comportement normal, accepter l'exception)
- ✅ Page de login Apache Guacamole affichée
- 🔒 Connexion chiffrée HTTPS (cadenas dans la barre d'adresse)

**Test de redirection HTTP → HTTPS :**

URL : `http://10.50.20.5`

**Résultat :** Redirection automatique vers `https://10.50.20.5/guacamole/`

---

### 6.7. Architecture finale

**Schéma de l'infrastructure :**

```
┌────────────────────────────────────────────────────────┐
│  Poste administrateur (VLAN 210)                       │
│  Navigateur : https://bastion.ecotech.local            │
└────────────────┬───────────────────────────────────────┘
                 │ HTTPS:443 (TLS 1.2/1.3)
                 ▼
┌────────────────────────────────────────────────────────┐
│  pfSense - Règles pare-feu BASTION                     │
│  Autorise : Port 443 depuis VLANs admin                │
└────────────────┬───────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│  CT Bastion (10.50.20.5) - Debian 12 LXC               │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Stack Docker Guacamole                          │  │
│  │                                                  │  │
│  │  ┌────────────┐  Port 443 (HTTPS)                │  │
│  │  │   nginx    │←────── Écoute externe            │  │
│  │  │  :443/80   │                                  │  │
│  │  └──────┬─────┘                                  │  │
│  │         │ Déchiffre SSL/TLS                      │  │
│  │         │ Proxy HTTP vers Guacamole              │  │
│  │         ▼                                        │  │
│  │  ┌────────────┐  Port 8080 (HTTP interne)        │  │
│  │  │ guacamole  │  NON exposé à l'extérieur        │  │
│  │  │   :8080    │                                  │  │
│  │  └──────┬─────┘                                  │  │
│  │         │                                        │  │
│  │    ┌────▼────┐        ┌──────────┐               │  │
│  │    │  guacd  │        │ postgres │               │  │
│  │    │  :4822  │        │  :5432   │               │  │
│  │    └─────────┘        └──────────┘               │  │
│  │                                                  │  │
│  │  Réseau Docker : guacamole_net (bridge)          │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

**Matrice des flux :**

| Source | Destination | Port | Protocole | Chiffrement | Description |
|--------|-------------|------|-----------|-------------|-------------|
| Poste admin (VLAN 210) | nginx (CT bastion) | 443 | HTTPS | TLS 1.2/1.3 | Accès web Guacamole |
| nginx | guacamole | 8080 | HTTP | Non chiffré | Proxy interne Docker |
| guacamole | guacd | 4822 | Guacamole | Non chiffré | Communication protocole |
| guacamole | postgres | 5432 | PostgreSQL | Non chiffré | Accès base de données |

**Note sur le chiffrement interne :**  
Les communications entre conteneurs Docker (nginx → guacamole → guacd/postgres) ne sont **pas chiffrées** car elles transitent uniquement sur le réseau virtuel Docker interne au CT. Le chiffrement SSL/TLS est assuré uniquement entre le navigateur et Nginx, ce qui est suffisant car le trafic interne ne sort jamais du serveur.

---

## 7. Configuration DNS

### 7.1. Création de l'enregistrement DNS

Pour permettre l'accès au bastion via un nom de domaine plutôt qu'une adresse IP, un enregistrement DNS a été créé dans Active Directory.

**Sur le contrôleur de domaine (ECO-BDX-AD01) :**

1. Ouvrir **DNS Manager**
2. Naviguer vers la zone `ecotech.local`
3. Créer un nouvel enregistrement **Host (A)** :
   - **Nom** : `bastion`
   - **Adresse IP** : `10.50.20.5`
   - ✅ Cocher "Create associated pointer (PTR) record"
4. Cliquer sur **Add Host**

**Résultat :** Le bastion est maintenant accessible via `https://bastion.ecotech.local/guacamole`

---

### 7.2. Validation

**Test de résolution DNS depuis un poste admin :**
```powershell
nslookup bastion.ecotech.local
```

**Résultat attendu :**
```
Serveur :   ECO-BDX-AD01.ecotech.local
Address:    10.20.20.5

Nom :    bastion.ecotech.local
Address: 10.50.20.5
```

---



## 7. Configuration des règles de pare-feu pfSense

### 7.1. Contexte et principe du moindre privilège

La configuration réseau et Docker du bastion étant finalisée, il est nécessaire de sécuriser les flux réseau selon le principe du moindre privilège. Les règles temporaires créées lors de l'installation doivent être remplacées par des règles spécifiques qui autorisent uniquement les flux légitimes.

**Objectifs :**
- Contrôler précisément ce que le bastion peut faire (connexions sortantes)
- Contrôler qui peut accéder au bastion (connexions entrantes)
- Tracer et auditer tous les flux via les logs pfSense

---

### 7.2. Architecture des flux

**Flux entrants vers le bastion :**
- Administrateurs (VLAN 210) → Bastion:443 (HTTPS)

**Flux sortants depuis le bastion :**
- Bastion → Serveurs:3389 (RDP vers Windows)
- Bastion → Serveurs:22 (SSH vers Linux)
- Bastion → Internet:80/443 (mises à jour Docker, APT)
- Bastion → DNS:53 (résolution de noms)
- Bastion → NTP:123 (synchronisation horaire)

---

### 7.3. Règles sur l'interface BASTION (flux sortants)

Ces règles définissent les connexions que le bastion est autorisé à initier vers d'autres systèmes.

#### 7.3.1. Suppression de la règle temporaire

La règle de test créée lors de l'installation (`Allow Bastion outbound traffic - TEMP TEST` avec protocole `Any` vers `any`) doit être supprimée car elle autorise TOUT le trafic, ce qui constitue une faille de sécurité majeure.

**Procédure :**
1. **Firewall** → **Rules** → **BASTION**
2. Repérer la règle temporaire
3. Cliquer sur l'icône 🗑️ (corbeille) pour la supprimer
4. **Apply Changes**

---

#### 7.3.2. Règle 1 : Résolution DNS

**Navigation :** Firewall → Rules → BASTION → Add ↑

| Paramètre | Valeur |
|-----------|--------|
| **Action** | `Pass` |
| **Interface** | `BASTION` |
| **Address Family** | `IPv4` |
| **Protocol** | `UDP` |
| **Source** | `BASTION net` |
| **Destination** | `any` |
| **Destination Port Range** | `DNS (53)` |
| **Description** | `Allow Bastion DNS queries` |

**Justification :** Le bastion doit pouvoir résoudre les noms de domaine pour :
- Accéder aux dépôts Docker (download.docker.com, registry-1.docker.io)
- Résoudre les noms de serveurs configurés dans Guacamole
- Mettre à jour le système via APT

---

#### 7.3.3. Règle 2 : Synchronisation horaire NTP

| Paramètre | Valeur |
|-----------|--------|
| **Action** | `Pass` |
| **Interface** | `BASTION` |
| **Address Family** | `IPv4` |
| **Protocol** | `UDP` |
| **Source** | `BASTION net` |
| **Destination** | `any` |
| **Destination Port Range** | `NTP (123)` |
| **Description** | `Allow Bastion NTP time sync` |

**Justification :** Une horloge système synchronisée est critique pour :
- La validité des certificats SSL/TLS
- Les timestamps précis des logs d'audit
- Le bon fonctionnement des sessions d'authentification

---

#### 7.3.4. Règle 3 : Mises à jour système et Docker

| Paramètre | Valeur |
|-----------|--------|
| **Action** | `Pass` |
| **Interface** | `BASTION` |
| **Address Family** | `IPv4` |
| **Protocol** | `TCP` |
| **Source** | `BASTION net` |
| **Destination** | `any` |
| **Destination Port Range** | From: `HTTP (80)`, To: `HTTPS (443)` |
| **Description** | `Allow Bastion updates (Docker, apt)` |

**Justification :** Accès Internet nécessaire pour :
- Téléchargement des images Docker (`docker pull`)
- Mises à jour de sécurité du système d'exploitation (`apt update && apt upgrade`)
- Téléchargement des dépendances applicatives

**Note sécurité :** Bien que cette règle autorise l'accès à Internet, elle est limitée aux ports HTTP/HTTPS. Les autres protocoles (FTP, SMTP, etc.) restent bloqués.

---

#### 7.3.5. Règle 4 : Connexions RDP vers serveurs Windows

| Paramètre | Valeur |
|-----------|--------|
| **Action** | `Pass` |
| **Interface** | `BASTION` |
| **Address Family** | `IPv4` |
| **Protocol** | `TCP` |
| **Source** | `BASTION net` |
| **Destination** | `10.20.0.0/16` |
| **Destination Port Range** | `MS RDP (3389)` |
| **Description** | `Allow Bastion RDP to internal servers` |

**Justification :** Permet à Guacamole d'établir des sessions RDP vers les serveurs Windows de l'infrastructure.

**Amélioration recommandée :** Limiter la destination à un alias contenant uniquement les IPs des serveurs Windows autorisés (principe du moindre privilège renforcé).

---

#### 7.3.6. Règle 5 : Connexions SSH vers serveurs Linux

| Paramètre | Valeur |
|-----------|--------|
| **Action** | `Pass` |
| **Interface** | `BASTION` |
| **Address Family** | `IPv4` |
| **Protocol** | `TCP` |
| **Source** | `BASTION net` |
| **Destination** | `10.20.0.0/16` |
| **Destination Port Range** | `SSH (22)` |
| **Description** | `Allow Bastion SSH to internal servers` |

**Justification :** Permet à Guacamole d'établir des sessions SSH vers les serveurs Linux de l'infrastructure.

**Note :** Si des serveurs utilisent des ports SSH non-standard (ex: 22222), il est nécessaire soit :
- De créer une règle supplémentaire pour ce port spécifique
- D'utiliser une plage de ports si plusieurs ports customs sont utilisés
- De créer un alias avec les ports autorisés

---

#### 7.3.7. Ordre des règles

pfSense évalue les règles **de haut en bas** et applique la première règle correspondante. L'ordre optimal est :

```
1. DNS (UDP:53)
2. NTP (UDP:123)
3. HTTP/HTTPS (TCP:80,443)
4. RDP (TCP:3389)
5. SSH (TCP:22)
```

**Réorganisation :** Utiliser les flèches ↑↓ à gauche de chaque règle pour modifier l'ordre, puis cliquer sur **Apply Changes**.

---

### 7.4. Règles sur l'interface ADMIN (flux entrants)

Ces règles définissent qui peut accéder au bastion depuis le réseau interne.

#### 7.4.1. Règle d'accès HTTPS au bastion

**Navigation :** Firewall → Rules → ADMIN (ou nom de l'interface VLAN 210)

| Paramètre | Valeur |
|-----------|--------|
| **Action** | `Pass` |
| **Interface** | `ADMIN` |
| **Address Family** | `IPv4` |
| **Protocol** | `TCP` |
| **Source** | `ADMIN net` |
| **Destination** | `Single host or alias` → `10.50.20.5` |
| **Destination Port Range** | `HTTPS (443)` |
| **Description** | `Allow Admin VLAN access to Bastion HTTPS` |

**Justification :** Autorise les postes d'administration du VLAN 210 à accéder à l'interface web Guacamole hébergée sur le bastion.

**Amélioration recommandée :** Si les comptes administrateurs sont rattachés à des postes spécifiques, limiter la source à ces IPs précises au lieu de `ADMIN net` complet.

---

### 7.5. Création d'alias (bonne pratique)

Les alias facilitent la maintenance des règles et améliorent la lisibilité de la configuration.

#### 7.5.1. Alias pour le bastion

**Navigation :** Firewall → Aliases → IP → Add

| Paramètre | Valeur |
|-----------|--------|
| **Name** | `Bastion_IP` |
| **Description** | `Serveur Bastion Apache Guacamole` |
| **Type** | `Host(s)` |
| **IP or FQDN** | `10.50.20.5` |

**Utilisation :** Remplacer `10.50.20.5` par `Bastion_IP` dans les règles. Si l'IP du bastion change, il suffit de modifier l'alias une seule fois.

---

#### 7.5.2. Alias pour les serveurs Windows

| Paramètre | Valeur |
|-----------|--------|
| **Name** | `Windows_Servers` |
| **Description** | `Serveurs Windows accessibles via RDP` |
| **Type** | `Host(s)` |
| **IP or FQDN** | `10.20.20.5` (cliquer sur **Add** pour ajouter d'autres IPs) |

**Utilisation :** Remplacer `10.20.0.0/16` par `Windows_Servers` dans la règle RDP du bastion pour limiter l'accès aux seuls serveurs Windows autorisés.

---

#### 7.5.3. Alias pour les serveurs Linux

| Paramètre | Valeur |
|-----------|--------|
| **Name** | `Linux_Servers` |
| **Description** | `Serveurs Linux accessibles via SSH` |
| **Type** | `Host(s)` |
| **IP or FQDN** | `10.20.20.7` (ajouter d'autres IPs si nécessaire) |

**Utilisation :** Remplacer `10.20.0.0/16` par `Linux_Servers` dans la règle SSH du bastion.

---

### 7.6. Tests de validation

#### Test 1 : Accès web au bastion depuis le VLAN Admin

**Depuis un poste administrateur (VLAN 210) :**

```powershell
# Test de connectivité réseau
Test-NetConnection -ComputerName 10.50.20.5 -Port 443
```

**Résultat attendu :**
```
TcpTestSucceeded : True
```

**Test navigateur :**
```
https://bastion.ecotech.local/guacamole
```

**Résultat attendu :** Page de login Guacamole affichée

---

#### Test 2 : Connexions RDP/SSH depuis le bastion

**Se connecter à Guacamole et tester :**
- Connexion RDP vers un serveur Windows (ex: ECO-BDX-EX01)
- Connexion SSH vers un serveur Linux (ex: ECO-BDX-EX07)

**Résultat attendu :** Les deux connexions s'établissent correctement

---

#### Test 3 : Mises à jour Docker

**SSH sur le bastion :**

```bash
# Test de résolution DNS
nslookup download.docker.com

# Test de connectivité HTTP/HTTPS
curl -I https://download.docker.com

# Test de mise à jour des images Docker
docker pull hello-world
```

**Résultat attendu :** Tous les tests réussissent

---

#### Test 4 : Vérification des logs pfSense

**Navigation :** Status → System Logs → Firewall

**Filtrer par interface :**
- Sélectionner `BASTION` dans le menu déroulant

**Observations :**
- Les connexions autorisées apparaissent avec une icône ✅ verte
- Aucune connexion légitime ne doit être bloquée (icône ❌ rouge)

**Exemple de log normal :**
```
BASTION  Pass  TCP  10.50.20.5:xxxxx → 10.20.20.5:3389  Allow Bastion RDP to internal servers
```

---

### 7.7. Matrice récapitulative des règles

#### Règles sur l'interface BASTION (sortant du bastion)

| # | Source | Destination | Port | Protocole | Description |
|---|--------|-------------|------|-----------|-------------|
| 1 | BASTION net | any | 53 | UDP | Résolution DNS |
| 2 | BASTION net | any | 123 | UDP | Synchronisation NTP |
| 3 | BASTION net | any | 80, 443 | TCP | Mises à jour (Docker, APT) |
| 4 | BASTION net | 10.20.0.0/16 | 3389 | TCP | RDP vers serveurs Windows |
| 5 | BASTION net | 10.20.0.0/16 | 22 | TCP | SSH vers serveurs Linux |

---

#### Règles sur l'interface ADMIN (accès au bastion)

| # | Source | Destination | Port | Protocole | Description |
|---|--------|-------------|------|-----------|-------------|
| 1 | ADMIN net | 10.50.20.5 | 443 | TCP | Accès HTTPS au bastion |

---

### 7.8. Schéma des flux réseau finaux

```
┌───────────────────────────────────────────────────────┐
│  Poste Administrateur (VLAN 210 - 10.10.10.x)         │
└──────────────────┬────────────────────────────────────┘
                   │ HTTPS:443
                   │ (Règle ADMIN: Pass)
                   ▼
┌───────────────────────────────────────────────────────┐
│  pfSense - Interface ADMIN                            │
│  Règle : ADMIN net → Bastion:443 ✅                  │
└──────────────────┬────────────────────────────────────┘
                   │
                   ▼
┌───────────────────────────────────────────────────────┐
│  pfSense - Interface BASTION (VIP 10.50.20.1)         │
│  Règles sortantes :                                   │
│    - DNS (53/UDP) ✅                                  │
│    - NTP (123/UDP) ✅                                 │
│    - HTTP/HTTPS (80,443/TCP) ✅                       │
│    - RDP (3389/TCP) ✅                                │
│    - SSH (22/TCP) ✅                                  │
└──────────────────┬────────────────────────────────────┘
                   │
                   ▼
┌───────────────────────────────────────────────────────┐
│  Bastion (10.50.20.5)                                 │
│  Stack Docker : Nginx + Guacamole + guacd + postgres  │
└──────────────────┬────────────────────────────────────┘
                   │
         ┌─────────┴─────────┬──────────────┐
         ▼                   ▼              ▼
    ┌─────────-┐        ┌─────────-┐   ┌─────────┐
    │ RDP:3389 │        │ SSH:22   │   │Internet │
    │ Windows  │        │ Linux    │   │  :80    │
    │10.20.20.5│        │10.20.20.7│   │  :443   │
    └─────────-┘        └─────────-┘   └─────────┘
```

---

### 7.9. Considérations de sécurité

#### Principe du moindre privilège appliqué

**Flux sortants :** Seuls les protocoles strictement nécessaires sont autorisés. Le bastion ne peut pas :
- Envoyer des emails (SMTP:25 bloqué)
- Accéder à des partages réseau (SMB:445 bloqué)
- Utiliser FTP (ports 20/21 bloqués)
- Initier des connexions sur d'autres ports non autorisés

**Flux entrants :** Seul le port 443 (HTTPS) est accessible depuis le VLAN Admin. Le bastion n'est pas accessible :
- Depuis Internet (sauf si NAT configuré explicitement)
- Via SSH direct (port 22 du CT non exposé)
- Via HTTP non chiffré (port 80 redirige vers 443)

---

#### Recommandations pour durcissement supplémentaire

**Restriction par adresse IP source :**
- Limiter l'accès HTTPS au bastion aux seules IPs des postes administrateurs (au lieu de `ADMIN net` complet)
- Créer des alias pour les groupes d'administrateurs (Admins-T0, Admins-T1)

**Limitation des destinations :**
- Remplacer les destinations `10.20.0.0/16` par des alias précis (`Windows_Servers`, `Linux_Servers`)
- Créer des règles séparées par serveur pour un audit plus fin

**Mise en place de quotas (avancé) :**
- Limiter le nombre de connexions simultanées par source
- Configurer des limiteurs de débit (Traffic Shaper) si nécessaire

---

## 8. Synthèse globale

### 8.1. Composants déployés

| Composant | Type | Version | Rôle |
| --- | --- | --- | --- |
| Docker Engine | Runtime | 29.2.1 | Plateforme de conteneurisation |
| Docker Compose | Orchestrateur | 5.0.2 | Gestion multi-conteneurs |
| Nginx | Reverse Proxy | Alpine | Terminaison SSL/TLS |
| Apache Guacamole | Application web | Latest | Interface d'administration |
| guacd | Daemon | Latest | Traduction protocoles |
| PostgreSQL | Base de données | 15-alpine | Stockage configuration |

---

### 8.2. Flux de connexion complet
```
1. Utilisateur admin ouvre son navigateur
   └─ https://bastion.ecotech.local/guacamole

2. Résolution DNS (AD)
   └─ bastion.ecotech.local → 10.50.20.5

3. Connexion HTTPS vers pfSense (port 443)
   └─ Règles firewall : autorisation VLAN 210 → BASTION:443

4. pfSense route vers le bastion
   └─ 10.50.20.5:443 (nginx conteneur Docker)

5. Nginx déchiffre SSL/TLS
   └─ Vérifie certificat bastion.crt

6. Nginx proxy vers Guacamole
   └─ http://guacamole:8080 (réseau Docker interne)

7. Guacamole authentifie l'utilisateur
   └─ Vérifie identifiants dans PostgreSQL

8. Utilisateur sélectionne une connexion RDP/SSH
   └─ Guacamole récupère les paramètres depuis PostgreSQL

9. Guacamole demande à guacd d'établir la connexion
   └─ guacd:4822 (protocole Guacamole)

10. guacd se connecte au serveur cible
    └─ RDP:3389 ou SSH:22 vers le serveur administré

11. guacd traduit le flux en WebSocket
    └─ Retour via Guacamole → Nginx → HTTPS → Navigateur

12. L'utilisateur interagit avec le serveur distant
    └─ Clavier/souris via HTML5 dans le navigateur
```

---

### 8.3. Sécurité mise en place

| Couche | Mécanisme | Niveau de protection |
|--------|-----------|---------------------|
| **Réseau** | VLAN 520 isolé | Segmentation niveau 2 |
| **Pare-feu** | Règles pfSense restrictives | Filtrage par source/destination |
| **Transport** | TLS 1.2/1.3 | Chiffrement de bout en bout |
| **Application** | Authentification Guacamole | Contrôle d'accès utilisateur |
| **Autorisation** | Permissions granulaires | RBAC par groupe |
| **Traçabilité** | Historique PostgreSQL | Audit des connexions |
| **Conteneurisation** | Docker isolation | Limitation blast radius |

---

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
