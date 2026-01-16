<h2 id="haut-de-page">Table des matières</h2>

- [1. Vue globale des services](#1-vue-globale-des-services)
- [2. Services d'infrastructure](#2-services-dinfrastructure)
- [3. Services métier et applicatifs](#3-services-métier-et-applicatifs)
- [4. Services réseau](#4-services-réseau)
- [5. Services de sécurité](#5-services-de-sécurité)
- [6. Services de supervision et administration](#6-services-de-supervision-et-administration)
- [7. Interdépendances entre services](#7-interdépendances-entre-services)
- [8. Ordre logique de mise en place](#8-ordre-logique-de-mise-en-place)
- [9. Matrice de responsabilité](#9-matrice-de-responsabilité)
- [10. Niveaux de service (SLA)](#10-niveaux-de-service-sla)

## <span id="1-vue-globale-des-services">**1. Vue globale des services**</span>

### **1.1. Philosophie de déploiement**
- **Services critiques** : Haute disponibilité (cluster, redondance)
- **Services standards** : Disponibilité élevée (sauvegardes fréquentes)
- **Services de support** : Disponibilité standard
- **Services expérimentaux** : Environnement isolé

### **1.2. Répartition par environnement**

| Environnement | Objectif | Services hébergés | Accès |
|---------------|----------|-------------------|-------|
| **Production** | Services opérationnels | Tous les services critiques | Utilisateurs finaux |
| **Pré-production** | Tests de validation | Copie des services critiques | Équipes IT et métier |
| **Développement** | R&D et tests | Nouveaux services, versions beta | Développeurs |
| **Laboratoire** | Expérimentations | Services en évaluation | Administrateurs |

### **1.3. Exposition des services**

| Exposition | Services | VLAN | Accès | Protection |
|------------|----------|------|-------|------------|
| **Interne uniquement** | AD, DNS interne, DHCP, Fichiers | 100, 80 | Réseau interne | Pare-feu interne |
| **DMZ** | Web public, VPN, Mail externe | 110 | Internet + Interne | Pare-feu DMZ |
| **Hybride** | Supervision, Sauvegarde | 100 + Internet | Interne + Cloud | Authentification forte |

## <span id="2-services-dinfrastructure">**2. Services d'infrastructure**</span>

| Service | Serveur (Hostname) | Adresse IP | VLAN |
| :--- | :--- | :--- | :--- |
| **Active Directory / DNS** | SRV-AD-01 | 172.16.100.2 | 100 (Serveurs) |
| **DHCP** | SRV-DHCP-01 | 172.16.100.3 | 100 (Serveurs) |
| **Messagerie** | SRV-MAIL-01 | 172.16.100.4 | 100 (Serveurs) |
| **Stockage (Fichiers)** | SRV-FS-01 | 172.16.100.5 | 100 (Serveurs) |
| **Hyperviseur** | SRV-PVE-01 | 172.16.100.6 | 100 (Serveurs) |
| **Supervision** | SRV-MON-01 | 172.16.100.7 | 100 (Serveurs) |
| **VPN / Firewall** | FW-PFSENSE-01 | 172.16.110.1 | 110 (DMZ) |

*Note : Pour le détail complet des masques et passerelles, se référer au document* [**ip_configuration.md**](./ip_configuration.md).

### **2.1. Active Directory Domain Services (AD DS)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Authentification centralisée, gestion des identités |
| **Serveur(s)** | 2 serveurs en haute disponibilité |
| **VLAN** | 100 (Serveurs) |
| **Ports** | 389 (LDAP), 636 (LDAPS), 88 (Kerberos), 135-139, 445 (SMB) |
| **Dépendances** | DNS, NTP |
| **Haute disponibilité** | Réplication multi-maître, DFSR |
| **Sauvegarde** | Quotidienne (état système), sauvegarde AD hebdomadaire |
| **Monitoring** | Santé des réplications, authentifications échouées |

### **2.2. DNS (Domain Name System)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Résolution de noms interne/externe |
| **Serveur(s)** | 2 serveurs DNS internes + 1 DNS DMZ |
| **VLAN** | 100 (Interne), 110 (DMZ) |
| **Ports** | 53 (TCP/UDP) |
| **Dépendances** | AD (intégration), NTP |
| **Zones** | ecotech.local (interne), ecotech-solutions.fr (externe) |
| **Sécurité** | DNSSEC, filtrage des requêtes récursives |
| **Monitoring** | Temps de réponse, échecs de résolution |

### **2.3. DHCP (Dynamic Host Configuration Protocol)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Attribution automatique d'adresses IP |
| **Serveur(s)** | 2 serveurs avec failover |
| **VLAN** | 100 (Serveurs) |
| **Ports** | 67, 68 (UDP) |
| **Dépendances** | DNS, AD pour l'authentification |
| **Scope par VLAN** | Un scope par VLAN utilisateur (10-90) |
| **Réservations** | Équipements critiques (imprimantes, téléphones IP) |
| **Monitoring** | Utilisation des pools, adresses disponibles |

### **2.4. NTP (Network Time Protocol)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Synchronisation horaire de tous les équipements |
| **Serveur(s)** | 3 serveurs strate 2 |
| **VLAN** | 100 (Serveurs), 110 (DMZ) |
| **Ports** | 123 (UDP) |
| **Sources** | pool.ntp.org + serveurs temps.fr |
| **Hiérarchie** | Serveurs internes → Clients |
| **Sécurité** | Authentification NTP où supporté |
| **Monitoring** | Dérive temporelle, indisponibilité des sources |

## <span id="3-services-métier-et-applicatifs">**3. Services métier et applicatifs**</span>

### **3.1. Serveur de fichiers**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Stockage centralisé des données |
| **Serveur(s)** | Cluster 2 nœuds avec stockage partagé |
| **VLAN** | 100 (Serveurs) |
| **Ports** | 445 (SMB), 2049 (NFS pour Linux) |
| **Structure** | Par département avec quotas |
| **Permissions** | Basées sur groupes AD, héritage contrôlé |
| **Redondance** | RAID 10, snapshots horaires |
| **Sauvegarde** | Incrémentielle toutes les 4 heures |
| **Monitoring** | Espace disque, performances, accès |

### **3.2. Service de messagerie**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Courriel interne et externe |
| **Serveur(s)** | 2 serveurs Exchange en DAG |
| **VLAN** | 100 (Interne), 110 (DMZ pour SMTP) |
| **Ports** | 25 (SMTP), 587 (SMTP soumission), 993 (IMAPS), 995 (POP3S) |
| **Antispam/Antivirus** | Gateway en DMZ |
| **Archivage** | Politique de rétention conforme RGPD |
| **Haute disponibilité** | Database Availability Group |
| **Sauvegarde** | Transaction logs toutes les 15 minutes |
| **Monitoring** | File d'attente, délivrabilité, performances |

### **3.3. Service VoIP (Téléphonie IP)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Communications téléphoniques unifiées |
| **Serveur(s)** | Serveur VoIP avec redondance |
| **VLAN** | 10 (VoIP dédié) |
| **Ports** | 5060-5061 (SIP), 10000-20000 (RTP) |
| **Qualité de Service** | Priorité VLAN 20 sur les switches |
| **Téléphones** | Provisioning automatique |
| **Intégration** | AD pour l'annuaire, Exchange pour la messagerie unifiée |
| **Monitoring** | Qualité d'appel, disponibilité, utilisation |

### **3.4. Serveur d'applications métier**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Applications internes (CRM, ERP, Gestion de projet) |
| **Serveur(s)** | Environnement virtualisé avec load balancing |
| **VLAN** | 100 (Serveurs) |
| **Ports** | 80, 443 (HTTP/HTTPS), ports applicatifs |
| **Authentification** | SSO via AD |
| **Base de données** | Cluster SQL Server séparé |
| **Sauvegarde** | Transaction logs + sauvegarde complète nocturne |
| **Monitoring** | Temps de réponse, erreurs, connexions utilisateurs |

## <span id="4-services-réseau">**4. Services réseau**</span>

### **4.1. Services de commutation (VLANs)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Segmentation réseau et gestion des VLANs |
| **Équipements** | Commutateurs managés Layer 3 |
| **VLANs** | 12 VLANs définis (10-120) |
| **Protocoles** | 802.1Q (VLAN tagging), STP/MSTP |
| **Qualité de Service** | Priorisation VoIP (VLAN 20), données critiques |
| **Sécurité** | Port security, DHCP snooping, ACLs |
| **Monitoring** | SNMP, flux NetFlow, erreurs de port |

### **4.2. Service Wi-Fi**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Accès sans fil sécurisé |
| **Équipements** | Points d'accès managés + contrôleur |
| **SSIDs** | 3 réseaux (Entreprise, Invités, IoT) |
| **Authentification** | 802.1X/EAP-TLS (Entreprise), portail captif (Invités) |
| **VLAN mapping** | SSID → VLAN selon politique |
| **Sécurité** | WPA3-Enterprise, isolation clients, détection d'intrusion |
| **Monitoring** | Couverture, clients connectés, interférences |

### **4.3. Service VPN**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Accès distant sécurisé |
| **Serveur(s)** | Gateway VPN en DMZ |
| **VLAN** | 110 (DMZ) |
| **Protocoles** | IKEv2/IPsec, SSL-VPN |
| **Authentification** | AD + 2FA obligatoire |
| **Client** | Built-in (Windows/Mac), client dédié (mobile) |
| **Sécurité** | Split tunneling désactivé, inspection approfondie |
| **Monitoring** | Sessions actives, bande passante, échecs d'authentification |

### **4.4. Service DNS externe**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Résolution DNS pour les services publics |
| **Serveur(s)** | Serveurs en DMZ + service cloud redondant |
| **VLAN** | 110 (DMZ) |
| **Zones** | ecotech-solutions.fr, sous-domaines |
| **Sécurité** | DNSSEC, anycast, protection DDoS |
| **Haute disponibilité** | Anycast + failover cloud |
| **Monitoring** | Temps de réponse, disponibilité, requêtes |

## <span id="5-services-de-sécurité">**5. Services de sécurité**</span>

### **5.1. Pare-feu (Firewall)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Filtrage des flux réseau |
| **Équipements** | Pare-feu nouvelle génération (NGFW) |
| **Zones** | WAN, LAN, DMZ, Administration |
| **Fonctionnalités** | IPS, antivirus réseau, filtrage web, contrôle applicatif |
| **Politiques** | Par défaut "deny all", règles spécifiques par service |
| **Haute disponibilité** | Cluster actif/passif |
| **Monitoring** | Tentatives bloquées, règles utilisées, performances |
| **Sauvegarde** | Configuration quotidienne, historique des changements |

### **5.2. IDS/IPS (Détection/Prévention d'intrusion)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Surveillance du trafic réseau |
| **Déploiement** | Network-based et Host-based |
| **Emplacements** | Périmètre, DMZ, zones critiques |
| **Signatures** | Mises à jour quotidiennes |
| **Alertes** | Classées par criticité, corrélation avec SIEM |
| **Mode** | Surveillance (IDS) + blocage (IPS) pour zones critiques |
| **Monitoring** | Alertes par jour, faux positifs, couverture |

### **5.3. Antivirus/EDR (Endpoint Detection and Response)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Protection des terminaux |
| **Couverture** | Tous les serveurs et postes clients |
| **Fonctionnalités** | Antivirus, anti-malware, contrôle périphériques, EDR |
| **Management** | Console centrale avec reporting |
| **Mises à jour** | Quotidiennes (signatures), hebdomadaires (moteur) |
| **Isolation** | Mise en quarantaine automatique des menaces |
| **Monitoring** | États de protection, menaces bloquées, postes vulnérables |

## <span id="6-services-de-supervision-et-administration">**6. Services de supervision et administration**</span>

### **6.1. Plateforme de supervision**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Monitoring de l'infrastructure |
| **Solution** | Nagios/Icinga + Grafana pour les dashboards |
| **VLAN** | 100 (Serveurs) |
| **Couverture** | Serveurs, services, équipements réseau, applications |
| **Alertes** | Email, SMS, Slack selon criticité |
| **Tableaux de bord** | Par service, par équipe, global |
| **Rétention** | Métriques : 1 an, Logs : conformément à la politique |
| **Monitoring** | Disponibilité de la plateforme elle-même |

### **6.2. SIEM (Security Information and Event Management)**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Centralisation et analyse des logs de sécurité |
| **Solution** | ELK Stack (Elasticsearch, Logstash, Kibana) |
| **VLAN** | 100 (Serveurs) |
| **Sources** | Tous les équipements et applications |
| **Corrélations** | Règles de détection d'attaques, comportements anormaux |
| **Alertes** | Priorisation selon risque |
| **Rétention** | 1 an pour les logs de sécurité |
| **Reporting** | Quotidien, hebdomadaire, mensuel |

### **6.3. Service de sauvegarde**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Protection des données |
| **Solution** | Veeam Backup & Replication |
| **VLAN** | 100 (Serveurs) |
| **Cibles** | Disque local, NAS dédié, cloud (object storage) |
| **Rétention** | Selon politique (30/90/365 jours) |
| **Tests** | Restauration automatique mensuelle |
| **Chiffrement** | Données au repos et en transit |
| **Monitoring** | Taux de réussite, espace utilisé, durée des sauvegardes |

### **6.4. Console d'administration**

| Caractéristique | Détail |
|-----------------|--------|
| **Rôle** | Gestion centralisée |
| **Serveur(s)** | Station d'administration dédiée |
| **VLAN** | 80 (Administration) |
| **Outils** | RSAT, PowerShell, Ansible, outils fabricants |
| **Accès** | Via VPN ou poste dédié en VLAN 80 |
| **Journalisation** | Toutes les actions administratives |
| **Sécurité** | Authentification à deux facteurs, session limitée |
| **Monitoring** | Activités administratives, accès, modifications |

## <span id="7-interdépendances-entre-services">**7. Interdépendances entre services**</span>

### **7.1. Dépendances critiques**

AD DS ← DNS (pour la résolution des contrôleurs de domaine)
DNS ← NTP (pour la synchronisation des horodatages)
Tous les services ← AD (pour l'authentification)
Services métier ← Base de données (pour le stockage des données)


### **7.2. Ordre de démarrage**

1. **NTP** → Synchronisation horaire
2. **DNS** → Résolution des noms
3. **AD DS** → Authentification centrale
4. **DHCP** → Attribution IP (après DNS/AD)
5. **Services de base** → Fichiers, impression
6. **Services métier** → Applications
7. **Services exposés** → Web, Mail, VPN

### **7.3. Scénarios d'impact**

| Service défaillant | Impact sur... | Solution de contournement |
|--------------------|---------------|---------------------------|
| **AD DS** | Tous les services authentifiés | Comptes locaux d'urgence |
| **DNS** | Résolution des noms | Fichier hosts local, DNS secondaire |
| **Pare-feu** | Connectivité Internet/Interne | Mode fail-safe (autoriser le minimum) |
| **Stockage** | Services de fichiers, bases de données | Snapshots, réplication synchrone |

## <span id="8-ordre-logique-de-mise-en-place">**8. Ordre logique de mise en place**</span>

### **8.1. Phase 1 : Fondations**
1. Infrastructure physique (commutateurs, baies)
2. Serveurs de virtualisation (Hyper-V/VMware)
3. Services de base : NTP, DNS initial
4. Active Directory (forêt, domaines, OUs)
5. DHCP avec réservations pour équipements critiques

### **8.2. Phase 2 : Services internes**
1. Services AD complémentaires (GPO, certificats)
2. Serveur de fichiers avec quotas et permissions
3. Services d'impression centralisés
4. Supervision de base (serveurs, services critiques)
5. Sauvegarde initiale de tous les systèmes

### **8.3. Phase 3 : Services métier**
1. Applications métier (CRM, ERP, etc.)
2. Service de messagerie (Exchange/alternatives)
3. VoIP et téléphonie unifiée
4. Wi-Fi professionnel avec authentification AD
5. Services de collaboration (Teams, SharePoint)

### **8.4. Phase 4 : Sécurité et optimisation**
1. Sécurité avancée (IDS/IPS, EDR, DLP)
2. DMZ et services exposés (Web, VPN)
3. Automatisation (déploiement, configurations)
4. Optimisation des performances
5. Documentation finale et procédures opérationnelles

## <span id="9-matrice-de-responsabilité">**9. Matrice de responsabilité**</span>

| Service | Équipe responsable | Support niveau 1 | Support niveau 2 | Fournisseur |
|---------|-------------------|------------------|------------------|-------------|
| **AD, DNS, DHCP** | Infrastructure | Helpdesk | Admins systèmes | Microsoft |
| **Services de fichiers** | Infrastructure | Helpdesk | Admins stockage | Dell/HP |
| **Messagerie** | Applications | Helpdesk | Admins messagerie | Microsoft |
| **VoIP** | Télécoms | Helpdesk | Admins téléphonie | Fournisseur VoIP |
| **Réseau** | Réseau | Helpdesk | Admins réseau | Cisco/Aruba |
| **Sécurité** | Sécurité | SOC | Analistes sécurité | Multiple |
| **Sauvegarde** | Infrastructure | Helpdesk | Admins sauvegarde | Veeam |
| **Supervision** | Infrastructure | Monitoring | Admins monitoring | Communauté/Commercial |

## <span id="10-niveaux-de-service-sla">**10. Niveaux de service (SLA)**</span>

### **10.1. Disponibilité cible**

| Catégorie de service | Disponibilité cible | RTO (Recovery Time) | RPO (Recovery Point) |
|----------------------|---------------------|---------------------|----------------------|
| **Services critiques** | 99.95% | < 4 heures | < 1 heure |
| **Services essentiels** | 99.9% | < 8 heures | < 4 heures |
| **Services standards** | 99.5% | < 24 heures | < 24 heures |
| **Services de support** | 99% | < 48 heures | < 72 heures |

### **10.2. Classification des services**

- **Critiques** : AD, DNS, Pare-feu, Connectivité Internet
- **Essentiels** : Messagerie, Fichiers, Applications métier principales
- **Standards** : Impression, VoIP, Wi-Fi, Supervision
- **Support** : Sauvegarde, Testing, Développement

### **10.3. Fenêtres de maintenance**
- **Planifiées** : Vendredi 20h-00h (notification 7 jours à l'avance)
- **Urgentes** : Sur approbation du responsable infrastructure
- **Critiques** : 24/7 avec procédure d'urgence

## <span id="11-annexes">**11. Annexes**</span>

### **11.1. Ports et protocoles par service**
- [Voir document dédié](./ressources/ports-protocols.md)

### **11.2. Procédures opérationnelles**
- [Déploiement de nouveaux services](./operations/deploiement-procedures.md)
- [Incidents et résolution](./operations/incident-procedures.md)
- [Maintenance planifiée](./operations/maintenance-procedures.md)

### **11.3. Contacts et escalade**
- [Liste des contacts d'urgence](./resources/emergency-contacts.md)
- [Procédure d'escalade](./operations/escalation-procedure.md)

---

*Ce document des services est maintenu par l'équipe infrastructure et sera mis à jour à chaque modification significative de l'environnement. *
*Pour toute modification, créer un ticket de changement avec impact sur la documentation.*

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>


