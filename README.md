<h2 id="haut-de-page">Table des matières</h2>

- [1. Présentation du projet](#1-présentation-du-projet)
- [2. Objectifs finaux](#2-objectifs-finaux)
- [3. Vue d'ensemble des composants](#3-vue-densemble-des-composants)
- [4. Services déployés](#4-services-déployés)
- [5. Documentation du projet](#5-documentation-du-projet)
- [6. Contacts et informations](#6-contacts-et-informations)

## 1. Présentation du projet
<span id="1-présentation-du-projet"></span>

**Contexte :**  
ÉcoTech Solutions est une entreprise innovante basée à Bordeaux, spécialisée dans les solutions IoT pour la gestion intelligente de l'énergie et la transition écologique. Avec 251 collaborateurs répartis en 7 départements, l'entreprise nécessite une infrastructure réseau professionnelle pour soutenir sa croissance et ses ambitions.

**Problématique :**  
L'infrastructure actuelle repose sur une Box FAI standard, un réseau plat sans segmentation, des comptes locaux non centralisés, et des pratiques de sauvegarde inadéquates. Cette situation présente des risques majeurs de sécurité et de continuité d'activité.

**Mission :**  
Ce projet vise à concevoir, déployer et documenter une infrastructure réseau complète et sécurisée répondant aux standards professionnels, dans le cadre de la formation TSSR (Technicien Supérieur en Systèmes Réseaux).

**Périmètre :**
- Durée : 10 semaines (6 sprints)
- Équipe : 4 personnes
- Méthodologie : Agile/Scrum
- Entreprise : ÉcoTech Solutions

## 2. Objectifs finaux
<span id="2-objectifs-finaux"></span>

### 2.1. Objectifs techniques
- **Centralisation des identités** via Active Directory Domain Services
- **Segmentation réseau** avec 12 VLANs dédiés par département/fonction
- **Services socles** opérationnels (DNS, DHCP, NTP, fichiers)
- **Sécurisation** complète (pare-feu, DMZ, VPN, MFA, durcissement)
- **Supervision** et monitoring de l'infrastructure
- **Sauvegarde automatisée** avec stratégie 3-2-1
- **Documentation** complète (DAT, HLD, LLD, DEX)

### 2.2. Objectifs fonctionnels
- Améliorer la **sécurité** des données et des accès
- Simplifier l'**administration** et la gestion des utilisateurs
- Assurer la **continuité d'activité** avec plans de reprise
- Permettre l'**évolutivité** pour la croissance future
- Faciliter la **collaboration** entre départements
- Réduire les **temps d'indisponibilité**

### 2.3. Critères de succès
- Infrastructure 100% opérationnelle
- Tous les services validés par tests fonctionnels
- Documentation complète et à jour
- Présentation finale avec démonstration
- Validation par le formateur sur les 8 critères d'évaluation

## 3. Vue d'ensemble des composants
<span id="3-vue-densemble-des-composants"></span>

### 3.1. Architecture globale


### 3.2. Composants principaux

#### Infrastructure physique/virtuelle
- **Hyperviseur** : Hyper-V/VMware
- **Serveurs virtuels** : 10+ VMs (Windows Server, Linux)
- **Stockage** : SAN/NAS partagé
- **Réseau** : Commutateurs managés Layer 3

#### Services critiques
- **Active Directory** : Authentification centralisée
- **DNS/DHCP** : Services réseau de base
- **Services fichiers** : Stockage centralisé
- **Supervision** : Monitoring 24/7
- **Sauvegarde** : Stratégie 3-2-1

#### Sécurité
- **Pare-feu** : Filtrage et inspection approfondie
- **DMZ** : Zone démilitarisée pour services exposés
- **VPN** : Accès distant sécurisé
- **MFA** : Authentification multi-facteurs

## 4. Services déployés
<span id="4-services-déployés"></span>

### 4.1. Services d'infrastructure
| Service | Description | Criticité |
|---------|-------------|-----------|
| **Active Directory** | Annuaire centralisé, GPO, authentification | Critique |
| **DNS** | Résolution de noms interne/externe | Critique |
| **DHCP** | Attribution automatique d'adresses IP | Essentiel |
| **NTP** | Synchronisation horaire | Essentiel |
| **Services fichiers** | Stockage centralisé avec quotas | Essentiel |

### 4.2. Services métier
| Service | Description | Département cible |
|---------|-------------|-------------------|
| **Messagerie**          | Exchange/alternative        | Tous                      |
| **VoIP**                | Téléphonie IP               | Département Commercial    |
| **Applications métier** | CRM, ERP, Gestion de projet | Développement, Commercial |
| **Collaboration**       | Partage de documents        | Tous                      |

### 4.3. Services sécurité
| Service | Description | Couverture |
|---------|-------------|------------|
| **Pare-feu**             | Filtrage réseau, IPS, antivirus | Périmètre              |
| **DMZ**                  | Isolation services exposés      | Services publics       |
| **VPN**                  | Accès distant sécurisé          | Télétravail            |
| **Supervision sécurité** | SIEM, détection d'intrusion     | Infrastructure entière |

### 4.4. Services support
| Service | Description | Fréquence |
|---------|-------------|-----------|
| **Sauvegarde**    | Backup automatisé          | Quotidienne |
| **Monitoring**    | Supervision services       | Temps réel  |
| **Documentation** | Procédures opérationnelles | À jour      |
| **Support**       | Niveaux 1, 2, 3            | 9h-18h      |

## 5. Documentation du projet
<span id="5-documentation-du-projet"></span>

### 5.1. Structure de la documentation

📁 TSSR-1025-P3-G2/  
├── 📄 **README.md** ← VOUS ÊTES ICI (DAT)  
├── 📄 **naming.md** ← Nomenclature du projet  

├── 📁 **architecture/** ← Documentation HLD  
│ ├── 📄 **overview.md** ← Vue d'ensemble  
│ ├── 📄 **context.md** ← Contexte et besoins  
│ ├── 📄 **scope.md** ← Périmètre du projet  
│ ├── 📄 **network.md** ← Architecture réseau  
│ ├── 📄 **ip_configuration.md** ← Plan d'adressage  
│ ├── 📄 **security.md** ← Stratégie sécurité  
│ └── 📄 **services.md** ← Services déployés  
├── 📁 components/ ← Documentation LLD  
│ ├── 📄 **hardware.md** ← Matériels  
│ ├── 📄 **software.md** ← Logiciels  
│ └── 📁 [service]/ ← Dossiers par service  
├── 📁 operations/ ← Documentation DEX  
│ ├── 📄 **overview.md** ← Vue exploitation  
│ └── 📁 [procédures]/ ← Procédures opérationnelles  
├── 📁 sprints/ ← Suivi projet  
│ ├── 📄 **planning.md** ← Planning chronologique  
│ └── 📁 sprint-xx/ ← Dossiers par sprint  
└── 📁 ressources/ ← Ressources annexes  

### 5.2. Accès aux documents
| Type | Chemin | Description |
|------|--------|-------------|
| **DAT**   | [README.md](./README.md)         | Document actuel - Vue globale |
| **HLD**   | [architecture/](./architecture/) | Conception haute niveau       |
| **LLD**   | [components/](./components/)     | Conception bas niveau         |
| **DEX**   | [operations/](./operations/)     | Documentation exploitation    |
| **Suivi** | [sprints/](./sprints/)           | Planning et suivi projet      |

### 5.3. Documents clés
1. **[Architecture réseau](./architecture/network.md)** - Schémas et flux
2. **[Configuration IP](./architecture/ip_configuration.md)** - Plan d'adressage détaillé
3. **[Stratégie sécurité](./architecture/security.md)** - Politiques et procédures
4. **[Services déployés](./architecture/services.md)** - Catalogue des services
5. **[Planning projet](./sprints/planning.md)** - Chronologie et tâches

### 5.4. Convention de documentation
- **Format** : Markdown (.md)
- **Langue** : Français technique
- **Images** : Captures d'écran légendées
- **Code** : Commandes formatées et expliquées
- **Structure** : Table des matières obligatoire
- **Liens** : Références internes fonctionnelles
## 6. Contacts et informations
<span id="6-contacts-et-informations"></span>

### 6.1. Équipe projet (composition fixe)
|        Membre        | Rôles possibles    |      Compétences principales      |
|----------------------|--------------------|-----------------------------------|
|  **Anis BOUTALEB**   | PO, SM, Technicien | AD, GPO, administration Windows   |
| **Frédérick FLAVIL** | PO, SM, Technicien | Documentation, sécurité, services |
|  **Romain GENOUD**   | PO, SM, Technicien | Réseau, VLANs, commutateurs       |
| **Nicolas JOUVEAUX** | PO, SM, Technicien | Virtualisation, Linux, stockage   |

### 6.2. Rotation des rôles par sprint
*Les rôles PO et SM tournent à chaque sprint suivant le planning :*

|    Sprint     | Product Owner (PO)| Scrum Master (SM) |           Techniciens           |
|---------------|-------------------|-------------------|---------------------------------|
| **Sprint 01** |   Anis BOUTALEB   | Frédérick FLAVIL  | Romain GENOUD, Nicolas JOUVEAUX |
| **Sprint 02** | Nicolas JOUVEAUX  |   Romain GENOUD   | Frédérick FLAVIL, Anis BOUTALEB |
| **Sprint 03** |  Frédérick FLAVIL |   Anis BOUTALEB   | Romain GENOUD, Nicolas JOUVEAUX |
| **Sprint 04** |   Romain GENOUD   | Nicolas JOUVEAUX  | Frédérick FLAVIL, Anis BOUTALEB |
| **Sprint 05** |   Anis BOUTALEB   | Frédérick FLAVIL  | Romain GENOUD, Nicolas JOUVEAUX |
| **Sprint 06** | Nicolas JOUVEAUX  |   Romain GENOUD   | Frédérick FLAVIL, Anis BOUTALEB |

**Note importante :** Le formateur a comme seul interlocuteur du projet le **PO en cours** de chaque sprint.

### 6.3. Responsabilités par rôle
| Rôle | Responsabilités principales | Interlocuteur |
|------|----------------------------|---------------|
| **Product Owner (PO)** | - Priorisation des tâches<br>- Interface avec le formateur<br>- Validation des livrables<br>- Définition des besoins | Formateur, équipe |
| **Scrum Master (SM)** | - Animation des réunions<br>- Suivi du backlog<br>- Application méthodologie Scrum<br>- Résolution des blocages | Équipe |
| **Technicien** | - Réalisation des tâches techniques<br>- Documentation<br>- Tests et validation<br>- Support aux autres membres | SM, PO |

### 6.4. Contacts permanents
| Contact | Rôle fixe | Domaine d'expertise | Disponibilité |
|---------|-----------|---------------------|---------------|
| **Équipe complète** | -         | Tous les domaines du projet   | Heures de formation  |
| **Formateur**       | Encadrant | Validation, conseil technique | Selon planning cours |

### 6.5. Communication
- **Daily** : 15 min chaque matin (animé par le SM)
- **Fin de sprint** : Présentation 10-20 min avec démo (PO présente)
- **Fin de semaine intermédiaire** : Point d'étape 3-5 min
- **Canal principal** : Discussions en présentiel + dépôt Github
- **Documents officiels** : Tous dans le dépôt Github

### 6.6. Informations techniques
- **Domaine** : ecotech.local
- **Plage IP** : 172.16.0.0/16
- **VLANs** : 12 VLANs (10-120)
- **Serveurs** : 10+ machines virtuelles
- **Systèmes** : Windows Server 2022, Debian/Ubuntu

### 6.7. Dépôt Github
- **Nom** : TSSR-xxxx-P3-Gy
- **Accès** : Membres équipe + formateur
- **Branche principale** : main
- **Workflow** : Pull requests pour modifications
- **Structure** : Documentation markdown organisée

### 6.8. Suivi du projet
- **Durée** : 10 semaines (6 sprints)
- **Livrables** : Documentation + VMs à chaque sprint
- **Évaluation** : 8 critères validés hebdomadairement
- **Présentation finale** : 15-30 min avec démo obligatoire

## 7. État du projet
**Dernière mise à jour :** [Date]  
**Sprint en cours :** Sprint 01 - Analyse et documentation  
**Prochain jalon :** Fin Sprint 01 - Présentation documentation  
**Statut global :** En cours

### 7.1. Prochaines étapes
1. **Sprint 01** (Terminé) : Documentation initiale
2. **Sprint 02** : Infrastructure virtualisation
3. **Sprint 03** : Services AD, DNS, DHCP
4. **Sprint 04** : Services fichiers, supervision
5. **Sprint 05** : Sécurité, DMZ, VPN
6. **Sprint 06** : Tests, documentation finale

### 7.2. Accès rapide
- [Planning détaillé](./sprints/planning.md)
- [Architecture réseau](./architecture/network.md)
- [Sécurité](./architecture/security.md)
- [Services](./architecture/services.md)
- [Suivi sprints](./sprints/)

*Document DAT - Point d'entrée du système d'information*  
*Ce document est maintenu par l'équipe projet*  

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
