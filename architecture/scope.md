<h2 id="haut-de-page">Table des matières</h2>

- [1. Éléments inclus dans le projet (In Scope)](#1-éléments-inclus-dans-le-projet-in-scope)
- [2. Éléments hors scope (Out of Scope)](#2-éléments-hors-scope-out-of-scope)
- [3. Périmètre Réseau couvert](#3-périmètre-réseau-couvert)
- [4. Périmètre Temporel](#4-périmètre-temporel)

```text
Le périmètre décrit dans ce document n’est pas définitif et pourra être ajusté en fonction des besoins du client,
des contraintes identifiées et des décisions validées durant les différentes phases du projet.
Ce document définit les limites du projet "Build Your Infra".
```

## <span id="1-éléments-inclus-dans-le-projet-in-scope">1. Éléments inclus dans le projet (In Scope)</span>

Le projet couvre la mise en œuvre, la configuration et la documentation d'une infrastructure système et réseau complète, hébergée localement (**On-Premise**).

### 1.1. Services Réseau & Sécurité
* **Virtualisation :** Déploiement (Proxmox).
* **Routage & Segmentation :** Configuration du routage inter-VLAN et segmentation stricte des flux par départements.
* **Pare-feu (Firewall) :** Filtrage des flux, NAT, et sécurisation périmétrique (pfSense).
* **Accès Distant (VPN) :** Mise en place d'un tunnel VPN sécurisé pour l'administration et le futur partenariat.

### 1.2. Services d'Infrastructure (Socle)
* **Gestion des Identités :** Mise en place d'un annuaire Active Directory (Windows Server) pour centraliser les utilisateurs et ordinateurs.
* **Services IP :** DNS (Résolution de noms Split-DNS) et DHCP (Distribution d'adresses).
* **Gestion de Parc (GLPI) :** Inventaire et gestion des tickets incidents.

### 1.3. Services Collaboratifs & Métier
* **Messagerie (Refonte complète) :**
    * Remplacement de la messagerie Cloud par une autre solution.
    * Mise en place des rôles MTA/MDA (Postfix / Dovecot).
    * Mise en place d'un Webmail moderne pour les utilisateurs (Snappy Mail).
* **Fichiers & Stockage :** Serveur de fichiers Windows sécurisé (FSRM) avec gestion des quotas et droits d'accès.
* **Téléphonie :** Serveur VoIP (FreePBX) pour la gestion des communications internes.

## <span id="2-éléments-hors-scope-out-of-scope">2. Éléments hors scope (Out of Scope)</span>

Les éléments suivants sont explicitement exclus du périmètre de réalisation technique du groupe :

* **Installation physique :** Le câblage, le brassage des baies et le montage matériel sont simulés (environnement virtualisé).
* **Développement applicatif :** Nous hébergeons les services web/métier mais nous ne modifions pas leur code source.
* **Migration des données historiques :** La reprise de l'historique des emails de l'ancien système Cloud vers le nouveau système local n'est pas incluse dans ce sprint (uniquement la mise en service de la nouvelle plateforme).
* **Support Utilisateur niveau 1 :** Le projet se concentre sur l'ingénierie ("Build") et l'administration niveau 2/3.

## <span id="3-périmètre-réseau-couvert">3. Périmètre Réseau couvert</span>

L'infrastructure repose sur une segmentation réseau stricte (Zone-Based Security).
Le détail technique (numéros de VLAN, IP) est disponible dans le fichier [**ip_configuration.md**](./ip_configuration.md).

### Infrastructure IP
* **Réseau interne global :** **172.16.0.0/18**
* **Découpage standard :** **172.16.X.0/24** (sauf zones spécifiques Serveurs).

### Zonage Logique
* **Zone Métier (LAN) :** Réseaux dédiés aux postes de travail utilisateurs, segmentés par départements (RH, Dev, IoT, etc.).
* **Zone Direction (VLAN_80) :** Zone VIP nécessitant des accès transverses aux données de l'entreprise.
* **Zone Administration (VLAN_90) :** Réseau réservé au service informatique, regroupant les postes d'administration et les outils de supervision.
* **Zone Serveurs (VLAN_100) :** Hébergement des services critiques et de l'infrastructure :
    * Contrôleur de domaine (AD/DNS/DHCP).
    * Serveurs de fichiers et bases de données.
    * Hyperviseur (Proxmox).
* **Zone DMZ (VLAN_110) :** Zone tampon sécurisée contenant les services accessibles depuis Internet :
    * Interface Webmail (Snappy Mail).
    * Relais de messagerie (SMTP).
* **Zone WAN (VLAN_120) :** Zone de connexion vers le fournisseur d'accès Internet (Box/Routeur FAI).

## <span id="4-périmètre-temporel">4. Périmètre Temporel</span>

* **Méthodologie :** Gestion de projet Agile / Scrum.
* **Découpage :** Le projet est rythmé par des Sprints (itérations) avec des livrables définis à chaque fin de cycle.

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>






