# Configuration du Serveur Bastion - Apache Guacamole

Dans ce fichier se trouvent les étapes de la configuration du serveur Bastion. De la configuration de son réseau dédié à l'installation et la sécurisation du serveur en lui-même.

---

## Table des matières

- [Configuration du Serveur Bastion - Apache Guacamole](#configuration-du-serveur-bastion---apache-guacamole)
  - [Table des matières](#table-des-matières)
  - [1. Entrée de la VLAN 520 sur le réseau](#1-entrée-de-la-vlan-520-sur-le-réseau)
    - [1.1. Contexte et justification](#11-contexte-et-justification)
    - [1.2. Configuration des interfaces sur le cluster pfSense](#12-configuration-des-interfaces-sur-le-cluster-pfsense)
      - [Ajout et configuration des interfaces BASTION](#ajout-et-configuration-des-interfaces-bastion)
    - [1.3. Création de la VIP CARP](#13-création-de-la-vip-carp)
      - [Configuration de la VIP CARP sur les deux pare-feu](#configuration-de-la-vip-carp-sur-les-deux-pare-feu)
    - [1.4. Création des règles de pare-feu](#14-création-des-règles-de-pare-feu)
    - [1.5. Validation de la configuration](#15-validation-de-la-configuration)
    - [1.6. Synthèse de l'architecture réseau](#16-synthèse-de-larchitecture-réseau)
  - [2. Routage inter-VLAN vers le serveur Bastion](#2-routage-inter-vlan-vers-le-serveur-bastion)
    - [2.1. Vérification de la connectivité](#21-vérification-de-la-connectivité)
    - [2.2. Analyse du chemin réseau](#22-analyse-du-chemin-réseau)
    - [2.3. Explication du routage](#23-explication-du-routage)
    - [2.4. Bonne pratique vs implémentation](#24-bonne-pratique-vs-implémentation)
    - [2.5. Validation technique](#25-validation-technique)
    - [2.6. Matrice de routage du réseau Bastion](#26-matrice-de-routage-du-réseau-bastion)
  - [3. Installation de Docker et Docker Compose](#3-installation-de-docker-et-docker-compose)
    - [3.1. Mise à jour du système](#31-mise-à-jour-du-système)
    - [3.2. Installation de Docker Engine](#32-installation-de-docker-engine)
    - [3.3. Installation du plugin Docker Compose](#33-installation-du-plugin-docker-compose)
    - [3.4. Choix de sécurité : Docker en mode root](#34-choix-de-sécurité--docker-en-mode-root)
  - [4. Déploiement d'Apache Guacamole](#4-déploiement-dapache-guacamole)
    - [4.1. Création de la structure de répertoires](#41-création-de-la-structure-de-répertoires)
    - [4.2. Création du fichier docker-compose.yml](#42-création-du-fichier-docker-composeyml)
    - [4.3. Initialisation de la base de données PostgreSQL](#43-initialisation-de-la-base-de-données-postgresql)
    - [4.4. Lancement de Guacamole](#44-lancement-de-guacamole)
    - [4.5. Architecture déployée](#45-architecture-déployée)
  - [5. Configuration du Reverse Proxy HTTPS avec Nginx](#5-configuration-du-reverse-proxy-https-avec-nginx)
    - [5.1. Génération des certificats SSL](#51-génération-des-certificats-ssl)
      - [Création de la structure de répertoires](#création-de-la-structure-de-répertoires)
      - [Génération du certificat auto-signé](#génération-du-certificat-auto-signé)
    - [5.2. Configuration de Nginx](#52-configuration-de-nginx)
      - [Création du fichier nginx.conf](#création-du-fichier-nginxconf)
      - [Explication des directives principales](#explication-des-directives-principales)
    - [5.3. Modification de la stack Docker](#53-modification-de-la-stack-docker)
      - [Ajout du service Nginx dans docker-compose.yml](#ajout-du-service-nginx-dans-docker-composeyml)
    - [5.4. Relance de la stack et validation](#54-relance-de-la-stack-et-validation)
    - [5.5. Architecture finale avec HTTPS](#55-architecture-finale-avec-https)
  - [6. Configuration DNS](#6-configuration-dns)
    - [6.1. Création de l'enregistrement DNS](#61-création-de-lenregistrement-dns)
    - [6.2. Validation](#62-validation)
  - [7. Synthèse globale](#7-synthèse-globale)
    - [7.1. Flux de communication](#71-flux-de-communication)
    - [7.2. Points de vigilance et maintenance](#72-points-de-vigilance-et-maintenance)
      - [Renouvellement du certificat](#renouvellement-du-certificat)
      - [Monitoring](#monitoring)
      - [Mise à jour des conteneurs](#mise-à-jour-des-conteneurs)

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

### 2.4. Bonne pratique vs implémentation

**Bonne pratique recommandée :**

Ajouter une route statique explicite sur VyOS :
```bash
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

---

### 2.5. Validation technique

**Commande de vérification sur VyOS :**
```bash
show ip route 10.50.20.5
```

**Résultat obtenu :** Le routage s'effectue via la route par défaut (`0.0.0.0/0`) vers pfSense.

---

### 2.6. Matrice de routage du réseau Bastion

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

## 4. Déploiement d'Apache Guacamole

### 4.1. Création de la structure de répertoires
```bash
# Création du répertoire principal
mkdir -p /opt/guacamole

# Se placer dedans
cd /opt/guacamole
```

---

### 4.2. Création du fichier docker-compose.yml

Architecture adaptée du tutoriel IT-Connect, définissant les trois conteneurs qui composent le serveur :
- **guacd** : Gère les protocoles RDP/SSH/VNC (le moteur)
- **PostgreSQL** : Gère la base de données (la mémoire)
- **guacamole** : Gère la partie web (la vitrine)
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
      POSTGRESQL_USER: guacamole_user
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

---

### 4.3. Initialisation de la base de données PostgreSQL

Avant de lancer Guacamole, il faut créer le schéma de la base de données.

**Génération du script SQL d'initialisation :**
```bash
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > initdb.sql
```

**Démarrage de PostgreSQL seul :**
```bash
docker compose up -d postgres
```

**Attente que PostgreSQL soit prêt :**
```bash
sleep 10
docker compose logs postgres
```

Vérifier la présence de la ligne : `database system is ready to accept connections`

**Injection du schéma dans la base :**
```bash
docker compose exec -T postgres psql -U guacamole_user -d guacamole_db < initdb.sql
```

**Résultat attendu :** Création de toutes les tables nécessaires (`CREATE TABLE`, `ALTER TABLE`, `INSERT`).

---

### 4.4. Lancement de Guacamole

**Démarrage de tous les services :**
```bash
docker compose up -d
```

**Vérification de l'état des conteneurs :**
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

### 4.5. Architecture déployée

| Composant | Type | Port | Rôle |
|-----------|------|------|------|
| **guacd** | Conteneur Docker | 4822 (interne) | Daemon de protocoles RDP/SSH/VNC |
| **postgres** | Conteneur Docker | 5432 (interne) | Base de données (configuration + historique) |
| **guacamole** | Conteneur Docker | 8080 (initialement exposé) | Interface web HTML5 |
| **guacamole_net** | Réseau Docker | - | Réseau bridge isolé entre les conteneurs |
| **postgres_data** | Volume Docker | - | Persistance des données |

---

## 5. Configuration du Reverse Proxy HTTPS avec Nginx

### 5.1. Génération des certificats SSL

#### Création de la structure de répertoires

Pour garantir la cohérence avec l'infrastructure existante (proxy Apache déjà déployé), la structure de certificats suit la même organisation :
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
| `-x509` | - | Génère un certificat auto-signé |
| `-nodes` | - | La clé privée n'est pas chiffrée (pas de passphrase) |
| `-days` | `365` | Validité d'un an |
| `-newkey` | `rsa:2048` | Crée une nouvelle clé RSA de 2048 bits |
| `-keyout` | `private/bastion.key` | Chemin de la clé privée |
| `-out` | `certs/bastion.crt` | Chemin du certificat |
| `-subj` | `/C=FR/ST=Gironde/...` | Informations du certificat |

**Résultat :**

✅ `ssl/private/bastion.key` (1.7 Ko) - Clé privée RSA  
✅ `ssl/certs/bastion.crt` (1.4 Ko) - Certificat public

*Note : En production, ce certificat devrait être signé par l'autorité de certification interne de l'entreprise (CA EcoTech) pour éviter les avertissements de sécurité dans les navigateurs.*

---

### 5.2. Configuration de Nginx

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
- `worker_connections 1024` : Nombre maximum de connexions simultanées par processus worker

**Serveur HTTPS (port 443) :**
- `listen 443 ssl` : Nginx écoute sur le port 443 avec SSL activé
- `ssl_protocols TLSv1.2 TLSv1.3` : Seuls les protocoles sécurisés sont autorisés
- `proxy_pass http://guacamole:8080` : Le trafic est transmis au conteneur Guacamole en HTTP interne
- `proxy_http_version 1.1` et headers `Upgrade/Connection` : **Critiques** pour le support WebSocket de Guacamole
- Timeouts de 7 jours : Permettent les sessions RDP/SSH de longue durée sans déconnexion

**Serveur HTTP (port 80) :**
- `return 301` : Redirige automatiquement toutes les requêtes HTTP vers HTTPS

---

### 5.3. Modification de la stack Docker

#### Ajout du service Nginx dans docker-compose.yml
```bash
cd /opt/guacamole
nano docker-compose.yml
```

**Ajout du service nginx (au début de la section `services`) :**
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

**Modification du service guacamole :**

Le port 8080 n'est **plus exposé** à l'extérieur du réseau Docker. Seul Nginx peut y accéder.

Supprimer ou commenter la ligne `ports:` dans le service `guacamole` :
```yaml
  guacamole:
    container_name: guacamole
    image: guacamole/guacamole
    restart: unless-stopped
    # ports:
    #   - "8080:8080"  ← Port non exposé, accessible uniquement via Nginx
    environment:
      ...
```

---

### 5.4. Relance de la stack et validation

**Arrêt et relance de tous les conteneurs :**
```bash
cd /opt/guacamole
docker compose down
docker compose up -d
```

**Vérification de l'état des conteneurs :**
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

Aucune erreur ne doit apparaître. Le message `Configuration complete; ready for start up` confirme le bon démarrage de Nginx.

**Test d'accès HTTPS depuis un poste du VLAN 210 :**

URL : `https://10.50.20.5/guacamole`

**Résultat :**
- ⚠️ Avertissement de certificat auto-signé (attendu)
- ✅ Page de login Apache Guacamole affichée
- 🔒 Connexion chiffrée (HTTPS)

**Test de redirection HTTP → HTTPS :**

URL : `http://10.50.20.5`

**Résultat :** Redirection automatique vers `https://10.50.20.5/guacamole/`

---

### 5.5. Architecture finale avec HTTPS

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

---

## 6. Configuration DNS

### 6.1. Création de l'enregistrement DNS

Pour permettre l'accès au bastion via un nom de domaine plutôt qu'une adresse IP, un enregistrement DNS a été créé dans Active Directory.

**Sur le contrôleur de domaine (ECO-BDX-AD01) :**

1. Ouvrir **DNS Manager**
2. Naviguer vers la zone `ecotech.local`
3. Créer un nouvel enregistrement **Host (A)** :
   - **Nom** : `bastion`
   - **Adresse IP** : `10.50.20.5`
   - ✅ Cocher "Create associated pointer (PTR) record"

**Résultat :** Le bastion est maintenant accessible via `https://bastion.ecotech.local/guacamole`

---

### 6.2. Validation

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

**Test d'accès via le nom de domaine :**

URL : `https://bastion.ecotech.local/guacamole`

✅ La page de login Guacamole s'affiche

---

## 7. Synthèse globale

### 7.1. Flux de communication

**Matrice des flux :**

| Source | Destination | Port | Protocole | Chiffrement | Description |
|--------|-------------|------|-----------|-------------|-------------|
| Poste admin (VLAN 210) | nginx (CT bastion) | 443 | HTTPS | TLS 1.2/1.3 | Accès web Guacamole |
| nginx | guacamole | 8080 | HTTP | Non chiffré | Proxy interne Docker |
| guacamole | guacd | 4822 | Guacamole | Non chiffré | Communication protocole |
| guacamole | postgres | 5432 | PostgreSQL | Non chiffré | Accès base de données |

**Note sur le chiffrement interne :**  
Les communications entre conteneurs Docker (nginx → guacamole → guacd/postgres) ne sont **pas chiffrées** car elles transitent uniquement sur le réseau virtuel Docker interne au CT. Le chiffrement SSL/TLS est assuré uniquement entre le navigateur et nginx.

---

### 7.2. Points de vigilance et maintenance

#### Renouvellement du certificat

Le certificat auto-signé généré a une validité de **365 jours**. Il devra être renouvelé avant expiration.

**Commande de renouvellement :**
```bash
cd /opt/guacamole/ssl

# Sauvegarder l'ancien certificat
mv certs/bastion.crt certs/bastion.crt.old
mv private/bastion.key private/bastion.key.old

# Générer un nouveau certificat
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout private/bastion.key \
  -out certs/bastion.crt \
  -subj "/C=FR/ST=Gironde/L=Bordeaux/O=EcoTech/OU=IT/CN=bastion.ecotech.local"

# Redémarrer nginx
docker compose restart nginx
```

#### Monitoring

**Vérifier l'état des conteneurs :**
```bash
docker compose ps
```

**Consulter les logs :**
```bash
docker compose logs nginx -f
docker compose logs guacamole -f
```

**Tester l'accès HTTPS :**
```bash
curl -k -I https://10.50.20.5/guacamole
```

#### Mise à jour des conteneurs
```bash
cd /opt/guacamole
docker compose pull
docker compose up -d
```

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>