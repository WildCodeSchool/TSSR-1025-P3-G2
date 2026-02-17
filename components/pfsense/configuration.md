# pfSense configuration du pare-feu et du VPN

pfSense constitue la barrière périmétrique d'**EcoTech Solutions**. Son rôle est d'assurer l'étanchéité entre le monde extérieur et l'infrastructure interne, tout en gérant le routage de la zone exposée (DMZ).

# Table des matières :

- [pfSense configuration du pare-feu et du VPN](#pfsense-configuration-du-pare-feu-et-du-vpn)
- [Table des matières :](#table-des-matières-)
- [1. Affectation des Interfaces et VLANs](#1-affectation-des-interfaces-et-vlans)
  - [2. Services Réseau de Base](#2-services-réseau-de-base)
    - [2.1. DNS Resolver (Unbound)](#21-dns-resolver-unbound)
    - [2.2. NAT (Network Address Translation)](#22-nat-network-address-translation)
  - [3. Règles de Pare-feu (Firewall Rules)](#3-règles-de-pare-feu-firewall-rules)
    - [3.1. Règles sur l'interface WAN](#31-règles-sur-linterface-wan)
    - [3.2. Règles sur l'interface DMZ (Sortant)](#32-règles-sur-linterface-dmz-sortant)
- [4. Accès Distants (OpenVPN)](#4-accès-distants-openvpn)
  - [4.1. Architecture et Cryptographie (PKI)](#41-architecture-et-cryptographie-pki)
    - [1. Autorité de Certification](#1-autorité-de-certification)
    - [2. Certificats Serveur et Utilisateurs](#2-certificats-serveur-et-utilisateurs)
  - [4.2. Configuration du Serveur OpenVPN](#42-configuration-du-serveur-openvpn)
    - [1. Paramétrage du Tunnel](#1-paramétrage-du-tunnel)
    - [2. Configuration Réseau et DNS](#2-configuration-réseau-et-dns)
  - [4.3. Gestion des Utilisateurs et Privilèges](#43-gestion-des-utilisateurs-et-privilèges)
    - [1. Création des utilisateurs](#1-création-des-utilisateurs)
    - [2. Surcharge Administrateur (CSO)](#2-surcharge-administrateur-cso)
  - [4.4. Déploiement Client et Export](#44-déploiement-client-et-export)
  - [4.5. Stratégie de Sécurité (Pare-feu)](#45-stratégie-de-sécurité-pare-feu)
  - [4.6. Validation fonctionnelle](#46-validation-fonctionnelle)
- [5. Journalisation et Monitoring (Log Management)](#5-journalisation-et-monitoring-log-management)
- [6. Supervision sur pfSense](#6-supervision-sur-pfsense)
  - [6.1. Configuration de l'affichage](#61-configuration-de-laffichage)
    - [1. Nettoyage et Mise en page](#1-nettoyage-et-mise-en-page)
    - [6.2. Sélection des Widgets (Indicateurs)](#62-sélection-des-widgets-indicateurs)
  - [6.3. Organisation du Tableau de Bord](#63-organisation-du-tableau-de-bord)
  - [6.4. Validation fonctionnelle](#64-validation-fonctionnelle)

# 1. Affectation des Interfaces et VLANs

pfSense est configuré avec plusieurs interfaces virtuelles pour segmenter les flux selon leur niveau de confiance.

- **WAN** : Connexion vers l'extérieur (Internet).
- **LAN / Transit** : Lien vers le routeur interne (VyOS).
- **DMZ** : Zone accueillant le serveur Web et le Proxy.

> **[Menu Interfaces > Assignments]**

## 2. Services Réseau de Base

### 2.1. DNS Resolver (Unbound)

Pour garantir la résolution des noms au sein de la forêt **ecotech.local** tout en permettant la navigation externe, le service **Unbound** est configuré en mode hybride.

- **DNS Query Forwarding** : Activé pour rediriger les requêtes inconnues vers des DNS publics sécurisés (ex: Cloudflare 1.1.1.1).
- **Domain Overrides** : Une règle spécifique est créée pour le domaine interne.
    - **Domaine** : **ecotech.local**
    - **IP Cibles** : **10.20.20.5** (AD-01) et **10.20.20.6** (AD-02).

### 2.2. NAT (Network Address Translation)

Pour permettre aux serveurs de la DMZ (ex: Serveur Web) d'être accessibles depuis l'extérieur, des règles de **Port Forwarding** sont appliquées.

- **Règle HTTP/HTTPS** : Redirection des ports 80/443 vers l'IP du serveur Web.
- **Port SSH personnalisé** : Redirection du port 22222 pour l'administration distante.

> **[Menu Firewall > NAT > Port Forward]**

## 3. Règles de Pare-feu (Firewall Rules)

La politique de sécurité appliquée est le **"Default Deny"** : tout ce qui n'est pas explicitement autorisé est bloqué.

### 3.1. Règles sur l'interface WAN

La surface d'attaque est réduite au strict minimum. Seuls les flux destinés à être publiés sont ouverts.

- **Block RFC1918** : Activé pour rejeter tout trafic provenant d'IP privées sur le port WAN (anti-spoofing).
- **ICMP** : Autorisé avec limitation (Rate Limit) pour permettre les tests de diagnostic depuis l'extérieur.

### 3.2. Règles sur l'interface DMZ (Sortant)

La DMZ est une zone à risque car elle est exposée. Son accès vers l'interne est donc strictement interdit.

- **Accès Internet** : Autorisé sur les ports **80** (HTTP), **443** (HTTPS) et **123** (NTP) pour les mises à jour système.
- **Isolation Interne** : Une règle de blocage "Any" est placée vers les réseaux **10.20.10.0/29** (Admin) et **10.60.20.0/16** (Infra) pour empêcher tout rebond d'un attaquant vers le cœur du réseau.

Le serveur Web est autorisé à contacter les serveurs de mise à jour, mais ne peut pas initier de connexion vers le VLAN Admin (VLAN 210).

> **[Menu Firewall > Rules (par interface)]**

# 4. Accès Distants (OpenVPN)

pfSense fait office de serveur VPN pour les collaborateurs sur les sites distants.

## 4.1. Architecture et Cryptographie (PKI)
<span id="1-architecture-et-cryptographie"><span/>

La sécurité du VPN repose sur une infrastructure à clés publiques (PKI) gérée directement par le pfSense. L'authentification est à double facteur : Certificat numérique + Identifiants utilisateur.

### 1. Autorité de Certification

Création de l'autorité racine interne qui signera tous les certificats de l'infrastructure.

* **Nom :** `EcoTech-CA`
* **Algorithme :** RSA 2048 bits / SHA256.
* **Rôle :** Garantir la chaîne de confiance.

### 2. Certificats Serveur et Utilisateurs

Un certificat serveur est généré pour identifier le pfSense :

* **Nom :** `EcoTech-VPN-Server-Cert`
* **Type :** Server Certificate.
* **CN (Common Name) :** `vpn.ecotech-solutions.fr`

Chaque utilisateur (Prestataire ou Admin) disposera également de son propre certificat personnel généré lors de la création de son compte.

---

## 4.2. Configuration du Serveur OpenVPN
<span id="2-configuration-du-serveur-openvpn"><span/>

Le service a été configuré via l'assistant (Wizard) pour assurer une conformité rapide, puis affiné manuellement.

### 1. Paramétrage du Tunnel

Les paramètres suivants définissent le "tuyau" chiffré :

| Paramètre | Valeur | Description |
| --- | --- | --- |
| **Interface** | WAN | Écoute sur l'IP publique (`10.0.0.3` Lab). |
| **Protocole** | UDP / 1194 | Standard OpenVPN pour la performance. |
| **Mode Crypto** | AES-256-GCM | Chiffrement haut niveau. |
| **Topology** | Subnet | Un seul sous-réseau pour tous les clients. |

### 2. Configuration Réseau et DNS

C'est ici que l'intégration avec le réseau local est définie :

* **IPv4 Tunnel Network :** `10.60.80.0/24`
* C'est le réseau virtuel dédié aux clients VPN. Il est totalement distinct des VLANs internes.

* **Redirect Gateway :** ✅ **Activé**
* Force tout le trafic du client (même Internet) à passer par le tunnel pour être filtré par le pare-feu.

* **DNS Servers :** `10.20.20.5` (AD Principal)
* Indispensable pour la résolution des noms internes (`ecotech.local`).

---

## 4.3. Gestion des Utilisateurs et Privilèges
<span id="3-gestion-des-utilisateurs"><span/>

La gestion des droits ne se fait pas par groupe, mais par une distinction technique entre Administrateurs et Utilisateurs standards.

### 1. Création des utilisateurs


Les comptes sont créés manuellement dans le **User Manager** local de pfSense.

* **Exemple Prestataire :** `zara_fernandez` (Certificat créé, IP dynamique).

### 2. Surcharge Administrateur (CSO)

Pour permettre les tests de la connection VPN, nous utilisons un **Client Specific Override**.

* **Menu :** VPN > OpenVPN > Client Specific Overrides.
* **Cible (Common Name) :** `ecotech_test`
* **Configuration forcée :**

``` markdown
IPv4 Tunnel Network : 10.60.80.200/24
```

* **Objectif :** L'utilistaeur test récupérera *toujours* l'IP `10.60.80.200`, ce qui servira d'identifiant pour le pare-feu.

---

## 4.4. Déploiement Client et Export
<span id="4-deploiement-client-et-export"><span/>

L'installation du paquet **openvpn-client-export** permet de générer des installeurs tout-en-un.

* **Configuration de l'export :**
* **Host Name Resolution :** `Interface IP Address` (Garantit que le client pointe bien vers l'IP WAN `10.0.0.3`).


* **Logiciel Client :** OpenVPN Connect.

---

## 4.5. Stratégie de Sécurité (Pare-feu)
<span id="5-strategie-de-securite"><span/>

Le filtrage est strict et suit le principe du moindre privilège. Les règles sont appliquées sur l'interface **OpenVPN** dans l'ordre suivant (Haut vers Bas) :

| Ordre | Action | Source | Destination | Port | Description |
| --- | --- | --- | --- | --- | --- |
| **1** | ✅ **Pass** | `10.60.80.200` (Test) | Any | Any | **FULL ACCESS TEST** (Règle temporaire). |
| **2** | ✅ **Pass** | `10.60.80.0/24` | `IP_AD_DNS_DHCP` | `PORTS_ADDS` | **Auth & DNS** (Vital pour l'ouverture de session). |
| **3** | ✅ **Pass** | `10.60.80.0/24` | `10.20.30.5` (Fichiers) | `PORT_SMB` | **Accès SMB** (Partages réseaux uniquement). |
| **4** | ✅ **Pass** | `10.60.80.0/24` | `10.20.20.7` (Web) | `PORTS_WEB` | **Intranet** (Consultation Web). |
| **5** | ✅ **Pass** | `10.60.80.0/24` | Any (WAN) | `PORTS_WEB` | **Internet** (Navigation Web sécurisée via le tunnel). |
| **6** | 🚫 **Block** | Any | Any | Any | **Deny All** (Tout le reste est interdit). |

---

## 4.6. Validation fonctionnelle
<span id="4.6-validation-fonctionnelle"><span/>

Les tests suivants valident la conformité de l'installation :

1. **Test Super-Utilisateur :**
* Connexion VPN établie.
* Vérification IP : `ipconfig` retourne bien `10.60.80.200`.
* Accès complet à l'infrastructure (Ping serveurs, accès Firewall).

2. **Test Prestataire :**
* Connexion VPN établie.
* Accès au partage `\\10.20.20.10` : **OK** (Pop-up d'authentification demandée).
* Accès Intranet `http://10.20.20.7` : **OK**.
* Tentative de Ping vers un poste client : **ÉCHEC** (Bloqué par la règle finale).

La solution est opérationnelle et sécurisée.  

*Apres les tests de configuration, l'utilisateur Test avec le "FULL ACCES" a été supprimé pour ne pas laisser une potentielle faille de sécurité sur notre réseau VPN*

# 5. Journalisation et Monitoring (Log Management)

Pour assurer la traçabilité des accès, la journalisation est activée sur les règles de rejet (Drop).

- **System Logs** : Consultation régulière via **Status > System Logs > Firewall**.
- **Analyse de trafic** : Utilisation de l'outil de diagnostic "Packet Capture" sur l'interface WAN pour valider les tentatives de connexion sur le port personnalisé **22222**.

# 6. Supervision sur pfSense

La supervision du pare-feu est une étape critique pour l'administration réseau. Elle permet d'obtenir une visibilité en temps réel sur l'état de santé de l'infrastructure et l'activité des utilisateurs.
L'objectif est de configurer le **Dashboard** (Tableau de bord) natif de pfSense pour afficher les indicateurs clés de performance (KPI) dès la connexion de l'administrateur.

## 6.1. Configuration de l'affichage

### 1. Nettoyage et Mise en page

L'affichage par défaut a été réorganisé pour optimiser la lisibilité.

* **Action :** Configuration du "Layout" en **2 colonnes**.
* **Chemin :** Icône 🔧 (Settings) > *Dashboard Columns* > *2 Columns*.

### 6.2. Sélection des Widgets (Indicateurs)

Nous avons sélectionné les sondes les plus pertinentes pour notre architecture :

| Widget | Rôle et Utilité |
| --- | --- |
| **System Information** | **Santé globale.** Affiche le CPU, la RAM, l'utilisation disque et la version du système. |
| **Interfaces** | **État des ports.** Permet de voir instantanément si une interface (WAN, LAN, VLANs) est active (Up) ou déconnectée (Down). |
| **Gateways** | **Qualité Internet.** Surveille la latence (Ping) et la perte de paquets vers la passerelle du FAI. |
| **Services Status** | **État des services.** Affiche le statut (Vert/Rouge) des démons critiques (DNS, DHCP, OpenVPN). Permet de relancer un service planté en un clic. |
| **OpenVPN** | **Utilisateurs distants.** Affiche la liste des clients connectés au VPN en temps réel (Nom, IP source, Heure de connexion). |
| **Traffic Graphs** | **Bande passante.** Graphiques de débit entrant/sortant pour repérer les saturations. |
| **Thermal Sensors** | **Température CPU.** *Note : Dans notre environnement virtualisé (Proxmox), ce widget peut rester inactif si les sondes matérielles ne sont pas exposées à la VM.* |

## 6.3. Organisation du Tableau de Bord

Les widgets ont été disposés logiquement pour séparer l'état du système (Hardware/Logiciel) de l'activité réseau (Flux/Utilisateurs).

| Colonne GAUCHE (Système) | Colonne DROITE (Réseau) |
| --- | --- |
| 1. System Information | 1. Interfaces |
| 2. Thermal Sensors | 2. Gateways |
|(3. Services Status)| 3. OpenVPN |
|             | 4. Traffic Graphs |

## 6.4. Validation fonctionnelle

Pour valider la bonne mise en place de la supervision :

1. **Action :** Connexion d'un utilisateur (ex: Admin) via le client VPN.
2. **Observation Dashboard :**
* Le widget **OpenVPN** affiche une nouvelle ligne avec l'identifiant de l'utilisateur.
* Le widget **Traffic Graphs** montre un pic d'activité sur l'interface WAN correspondant à l'établissement du tunnel.
* Le widget **Gateways** reste au vert (Indique que le VPN ne sature pas la connexion Internet).