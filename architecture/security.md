<h2 id="haut-de-page">Table des matières</h2>

- [1. Principes de sécurité retenus](#1-principes-de-sécurité-retenus)
- [2. Segmentation réseau et zones de sécurité](#2-segmentation-réseau-et-zones-de-sécurité)
- [3. Politiques d'accès](#3-politiques-daccès)
- [4. Gestion des identités et authentification](#4-gestion-des-identités-et-authentification)
- [5. Sécurité des équipements et systèmes](#5-sécurité-des-équipements-et-systèmes)
- [6. Journalisation et monitoring](#6-journalisation-et-monitoring)
- [7. Sauvegardes et continuité d'activité](#7-sauvegardes-et-continuité-dactivité)
- [8. Conformité et audit](#8-conformité-et-audit)
- [9. Procédures d'urgence](#9-procédures-durgence)
- [10. Formation et sensibilisation](#10-formation-et-sensibilisation)
  
## <span id="1-principes-de-sécurité-retenus">**1. Principes de sécurité retenus**</span>

### **1.1. Défense en profondeur (Defense in Depth)**
- Implémentation de multiples couches de sécurité
- Protection à chaque niveau : réseau, système, application, données
- Aucune confiance implicite (Zero Trust approche)

### **1.2. Principe du moindre privilège**
- Accès limité au strict nécessaire pour chaque rôle
- Révision régulière des permissions
- Séparation des droits entre environnements

### **1.3. Segmentation stricte**
- Isolation des zones par fonctionnalité et criticité
- Contrôle des flux inter-VLANs
- DMZ dédiée pour les services exposés

### **1.4. Journalisation complète**
- Traçabilité de toutes les actions significatives
- Centralisation des logs
- Conservation conforme aux exigences légales
  
## <span id="2-segmentation-réseau-et-zones-de-sécurité">**2. Segmentation réseau et zones de sécurité**</span>

### **2.1. Zones de sécurité définies**
  
| Zone | VLAN | Description | Niveau de sécurité | Accès depuis/vers |
|------|------|-------------|-------------------|-------------------|
| **IoT** | 10 | Capteurs et dispositifs IoT | Basse-Moyenne | IoT → Supervision |
| **VoIP** | 20 | Téléphonie IP | Moyenne | VoIP ↔ Serveurs téléphonie |
| **Développement** | 30 | Équipe R&D | Moyenne | Dev ↔ Labo + Git |
| **Commercial** | 40 | Équipe commerciale | Moyenne | Commercial ↔ CRM + Internet |
| **Communication** | 50 | Marketing/Communication | Moyenne | Communication ↔ Serveurs Web |
| **DRH** | 60 | Ressources humaines | Moyenne-Haute | DRH ↔ AD + Fichiers RH |
| **Finance/Comptabilité** | 70 | Données financières | Haute | Finance ↔ Serveurs spécifiques |
| **Administration/DSI** | 80 | Équipes IT / Département SI | Haute | Admin/DSI ↔ Toutes zones (contrôlé) |
| **Direction** | 90 | Direction générale | Moyenne-Haute | Direction ↔ Serveurs + Internet |
| **Serveurs** | 100 | Infrastructure critique | Haute | Admin ↔ Serveurs |
| **DMZ** | 110 | Services exposés (Web, VPN, Mail) | Moyenne-Haute | Périmètre ↔ DMZ ↔ Interne (contrôlé) |
| **Invités** | 120 | Visiteurs et partenaires | Basse | Invités → Internet uniquement |
| **Zone Périmètre** | - | Interface Internet/Firewall | Haute | Internet ↔ DMZ |
  
### **2.2. Règles de filtrage principales par flux**

#### **Flux entrant (depuis Internet)**
```
Internet → [Firewall] → DMZ
   ↓
Accès autorisé uniquement sur les ports spécifiques nécessaires
   ↓
Chaque service exposé (Web, VPN, Mail) n'accepte que les protocoles requis
```

#### **Flux DMZ → Réseau interne**
```
DMZ → Réseau interne
   ↓
Accès minimal et strictement contrôlé
   ↓
Exemple : Serveur Web DMZ → Base de données interne
         (uniquement sur le port SQL, avec authentification forte)
```

#### **Flux sortant (vers Internet)**
```
Zones internes → Internet
   ↓
Filtrage par politique de sécurité
   ↓
- Postes utilisateurs : Web (HTTP/HTTPS), Mail (SMTP/IMAP)
- Serveurs : Mises à jour uniquement depuis sources autorisées
- Supervision : Accès aux services de monitoring cloud
```

#### **Flux Zone Administration**
```
VLAN Admin (80) → Toutes zones
   ↓
Accès autorisé mais strictement contrôlé
   ↓
- Journalisation complète de toutes les sessions
- Authentification à deux facteurs obligatoire
- Limitation aux seules tâches administratives nécessaires
```

#### **Flux entre zones non-privilégiées et zones critiques**
```
Zones non-privilégiées → Zones critiques
   ↓
Accès généralement interdit par défaut
   ↓
Exceptions uniquement :
- Sur justification métier documentée
- Via règles de pare-feu spécifiques
- Avec monitoring renforcé
- Pour une durée limitée
```
  
### **2.3. Contrôle des flux inter-VLANs**
- ACLs sur les commutateurs
- Pare-feu interne entre zones critiques
- Monitoring des tentatives d'accès non autorisées

## <span id="3-politiques-daccès">**3. Politiques d'accès**</span>

### **3.1. Accès physique**
- **Centre de données** : Accès badge
- **Salles techniques** : Accès badge + journalisation
- **Baies serveurs** : Fermetures à clé avec traçabilité
- **Postes de travail** : Verrouillage automatique après 5 minutes d'inactivité

### **3.2. Accès réseau**
- **Wi-Fi Entreprise** : 802.1X avec certificats/EAP-TLS
- **Wi-Fi Invités** : Portail captif avec limitation de bande passante
- **VPN** : SSL-VPN avec 2FA pour accès distant
- **Accès administrateur** : Via VLAN Admin (80) uniquement

### **3.3. Contrôle d'accès aux ressources**
- **Fichiers** : Permissions NTFS basées sur groupes AD
- **Applications** : Authentification unique (SSO) où possible
- **Bases de données** : Accès par compte de service dédié
- **API/Services** : Authentification par token
  
## <span id="4-gestion-des-identités-et-authentification">**4. Gestion des identités et authentification**</span>

### **4.1. Active Directory Structure**
```
ecotech.local (Forêt racine)
├── Administrators (OU)
├── Service Accounts (OU)
├── Users (OU)
│   ├── Direction
│   ├── DSI
│   ├── Finance
│   ├── Commercial
│   ├── Communication
│   ├── Développement
│   └── DRH
└── Computers (OU)
    ├── Servers
    ├── Workstations
    ├── Laptops
    └── IoT_Devices
```

### **4.2. Politiques de mot de passe**
- **Longueur minimale** : 12 caractères
- **Complexité** : Majuscules, minuscules, chiffres, caractères spéciaux
- **Historique** : 24 mots de passe mémorisés
- **Expiration** : 90 jours
- **Verrouillage compte** : 4 tentatives échouées, déverrouillage auto après 30 min
- **Mots de passe admin** : 15 caractères minimum, changement tous les 180 jours

### **4.3. Authentification multi-facteur (MFA)**
- **Obligatoire pour** : 
  - Tous les comptes administrateurs
  - Accès VPN
  - Accès aux applications critiques
  - Accès à distance aux serveurs
- **Méthodes supportées** : Application mobile (Microsoft Authenticator), SMS, Token matériel

### **4.4. Gestion des comptes de service**
- Comptes dédiés par application/service
- Mots de passe longs (25+ caractères)
- Rotation automatique des mots de passe
- Monitoring des activités
 
## <span id="5-sécurité-des-équipements-et-systèmes">**5. Sécurité des équipements et systèmes**</span>

### **5.1. Durcissement des systèmes**
- **Windows Server** : Baseline de sécurité Microsoft, désactivation services inutiles
- **Linux** : CIS Benchmarks, SELinux/AppArmor activé
- **Équipements réseau** : Accès SSH uniquement (pas de Telnet), authentification RADIUS/TACACS+
- **Configuration standard** : Images durcies déployées via PXE

### **5.2. Gestion des correctifs**
- **Cycle de patch** : 
  - Critique : Déploiement sous 72h
  - Important : Déploiement sous 7 jours
  - Modéré : Déploiement sous 30 jours
- **Fenêtres de maintenance** : Vendredi soir 20h-00h
- **Testing** : Environnement de pré-production obligatoire

### **5.3. Protection des terminaux**
- **Antivirus/EDR** : Solution nouvelle génération avec protection cloud
- **Chiffrement** : BitLocker pour Windows, LUKS pour Linux
- **Application whitelisting** : Liste des applications autorisées
- **USB Control** : Blocage des périphériques non autorisés

### **5.4. Sécurité des applications**
- **Développement** : Secure coding guidelines, analyse de code statique
- **Déploiement** : Scans de vulnérabilités pré-déploiement
- **WAF** : Web Application Firewall pour applications web
- **Conteneurs** : Images signées, runtime protection
  
## <span id="6-journalisation-et-monitoring">**6. Journalisation et monitoring**</span>

### **6.1. Sources de logs collectées**
- Équipements réseau (firewalls, switches, routeurs)
- Serveurs (système, application, sécurité)
- Postes clients (événements significatifs)
- Active Directory (authentification, modifications)
- Applications métier

### **6.2. SIEM (Security Information and Event Management)**
- **Solution** : Elastic Stack (ELK) ou équivalent
- **Rétention** : 
  - Logs de sécurité : 1 an minimum
  - Logs système : 6 mois
  - Logs réseau : 3 mois
- **Alertes configurées** :
  - Tentatives de connexion échouées multiples
  - Accès hors heures normales
  - Modifications de privilèges
  - Accès à des données sensibles

### **6.3. Monitoring de sécurité**
- **Vulnérabilités** : Scans hebdomadaires, rapports de priorités
- **Comportements anormaux** : Machine learning pour détection d'anomalies
- **Intégrité des fichiers** : Monitoring des fichiers système critiques
- **Trafic réseau** : Analyse des flux pour détection de menaces
  
## <span id="7-sauvegardes-et-continuité-dactivité">**7. Sauvegardes et continuité d'activité**</span>

### **7.1. Stratégie de sauvegarde 3-2-1**
- **3 copies** des données
- **2 supports** différents (disque + bande/cloud)
- **1 copie hors site**

### **7.2. Plan de sauvegarde**

| Données | Fréquence | Rétention | Support | Localisation |
|---------|-----------|-----------|---------|--------------|
| **AD/DNS/DHCP** | Quotidienne (incrémentielle) + Hebdomadaire (complète) | 30 jours | Disque + Cloud | Site principal + Cloud |
| **Fichiers utilisateurs** | Quotidienne (incrémentielle) | 90 jours | Disque + Bande | Site principal + Coffre |
| **Bases de données** | Toutes les 4 heures (transaction logs) | 30 jours | Disque + Cloud | Site principal + Cloud |
| **Configuration systèmes** | Hebdomadaire | 1 an | Disque + Git | Multiple sites |
| **Logs de sécurité** | Quotidienne | 1 an | Disque + WORM | Site principal + Archivage |

### **7.3. Tests de restauration**
- **Mensuel** : Fichiers individuels
- **Trimestriel** : Système complet
- **Semestriel** : Scénario de reprise après sinistre
- **Documentation** : Procédures de restauration à jour

### **7.4. Plan de Continuité d'Activité (PCA)**
- **RTO (Recovery Time Objective)** : 
  - Services critiques : < 4 heures
  - Services standards : < 24 heures
- **RPO (Recovery Point Objective)** :
  - Données critiques : < 1 heure
  - Données standards : < 24 heures
  
## <span id="8-conformité-et-audit">**8. Conformité et audit**</span>

### **8.1. Cadres réglementaires appliqués**
- **RGPD** : Protection des données personnelles
- **Loi de sécurité numérique** : Obligations de sécurité
- **Normes sectorielles** : Bonnes pratiques énergétiques

### **8.2. Audits programmés**
- **Interne** : Trimestriel (vérification configurations)
- **Externe** : Annuel (audit complet)
- **Pénétration testing** : Semestriel (tests d'intrusion)

### **8.3. Documentation obligatoire**
- Politiques de sécurité
- Procédures opérationnelles
- Rapports d'incidents
- Preuves de conformité
  
## <span id="9-procédures-durgence">**9. Procédures d'urgence**</span>

### **9.1. Gestion des incidents de sécurité**
- **Niveau 1 (Critique)** : Réponse immédiate, équipe dédiée 24/7
- **Niveau 2 (Majeur)** : Résolution sous 4 heures
- **Niveau 3 (Mineur)** : Résolution sous 48 heures

### **9.2. Contacts d'urgence**
- **Responsable sécurité** : [Nom] - [Téléphone]
- **Administrateurs** : Liste dédiée avec disponibilités
- **Prestataires** : Contacts supports critiques
- **Autorités** : ANSSI, CNIL si nécessaire

### **9.3. Communication de crise**
- Template de communication pré-préparé
- Canaux dédiés (hors infrastructure compromise)
- Échelle de communication selon gravité
  
## <span id="10-formation-et-sensibilisation">**10. Formation et sensibilisation**</span>

### **10.1. Programmes de formation**
- **Nouveaux employés** : Module sécurité obligatoire
- **Administrateurs** : Formation avancée trimestrielle
- **Utilisateurs** : Rappels mensuels, phishing tests

### **10.2. Campagnes de sensibilisation**
- **Phishing** : Tests mensuels avec feedback
- **Mots de passe** : Conseils réguliers
- **Bons réflexes** : Affiches, newsletters, intranet

### **10.3. Charte d'utilisation acceptable**
- Signée par tous les employés
- Révision annuelle
- Sanctions claires en cas de violation
  
## <span id="11-annexes">**11. Annexes**</span>

### **11.1. Matrice des risques principaux**

| Risque | Impact | Probabilité | Mesures de mitigation |
|--------|--------|-------------|----------------------|
| **Attaque ransomware** | Élevé | Moyenne | Sauvegardes isolées, EDR, segmentation |
| **Fuites de données** | Élevé | Moyenne | DLP, chiffrement, monitoring accès |
| **Compromission compte admin** | Très élevé | Faible | MFA, comptes dédiés, journalisation renforcée |
| **Déni de service** | Moyen | Faible | Protection DDoS, redondance |

### **11.2. Références réglementaires**
- RGPD (Règlement Général sur la Protection des Données)
- Loi n° 2018-133 du 26 février 2018
- Norme ISO 27001 (référentiel)
- Guides ANSSI

### **11.3. Glossaire**
- **IDS/IPS** : Système de détection/prévention d'intrusion
- **SIEM** : Plateforme de gestion des événements de sécurité
- **EDR** : Détection et réponse sur les terminaux
- **DLP** : Prévention des pertes de données
- **WAF** : Pare-feu d'application web
  
*Cette politique de sécurité est un document vivant qui sera révisé au minimum annuellement ou après tout incident significatif.*

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>


