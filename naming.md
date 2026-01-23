
Ce document définit les standards de nommage pour l'ensemble de l'infrastructure. L'objectif est d'assurer la cohérence technique tout en évitant de divulguer explicitement le rôle des machines aux yeux d'un utilisateur non autorisé.
## 1. Nom de Domaine

- **Domaine racine** : ecotech.local
- **Suffixe externe** : ecotechsolutions.fr
- **NetBIOS** : ECOTECH

## 2. Unités d'Organisation (OU)

### Structure de l'arborescence

L'arborescence respecte une hiérarchie à 4 niveaux permettant de classer les objets par société, localisation, type et département.

- **Niveau 1 (Société)** : **ECOTECH** (Racine de l'organisation).
- **Niveau 2 (Localisation)** : **BDX** (Code pour le site de Bordeaux).
- **Niveau 3 (Type d'objet)** : Utilisation de codes neutres pour l'obfuscation :
    - **GX** : Administration et Tiering.
    - **UX** : Comptes utilisateurs.
    - **RX** : Groupes et ressources partagées.
    - **WX** : Postes de travail fixes et portables.
- **Niveau 4 (Département)** : Situés sous UX et RX, identifiés par les codes **D01 à D07** (ex: D04 pour la Direction).

### Sous-structures des départements (dans UX et RX)

Pour masquer l'organigramme de la société, les départements sont identifiés par des codes numériques :

- **D01** : Ressources Humaines (RH)
- **D02** : Développement (DEV)
- **D03** : Communication (COM)
- **D04** : Direction (DIR)
- **D05** : Service Après-Vente (SAV)
- **D06** : Logistique (LOG)
- **D07** : Comptabilité (CPTA)
- **D08** : DSI (DSI)

**Exemple de chemin (Distinguished Name) :** **ECOTECH > BDX > UX > D04 > anboutaleb** (Utilisateur de la Direction).

**Justification : Modèle de Tiering (Sécurité)**

Cette structure applique le modèle de Tiering recommandé par l'ANSSI pour garantir une isolation stricte des privilèges.  
En séparant la branche **GX** des utilisateurs standards **(UX)**, nous empêchons techniquement les comptes à hauts privilèges de s'authentifier sur des postes de travail vulnérables (OU **WX**).  
Cette segmentation constitue la défense la plus efficace contre le vol d'identifiants et les mouvements latéraux d'un attaquant au sein de l'infrastructure.  

## 3. Groupes de Sécurité

**Format** : **ECO-BDX-TYPE-PORTEE-CODENUM-DROIT**
- **TYPE** : **U** (Utilisateurs), **C** (Ordinateurs).
- **PORTEE** : **G** (Global), **L** (Local de domaine).
- **CODE** : Utilisation exclusive des codes neutres définis en section 4 (AX, BX, GX, DX, etc.).
- **NUM** : Numérotation séquentielle correspondant à la ressource.
- **DROIT** (Optionnel pour les groupes locaux) : **L** (Lecture), **M** (Modification), **F** (Full/Contrôle total).

| **Nom du groupe**      | **Description (Attribut AD)**         | **Logique de sécurité**       |
| ---------------------- | ------------------------------------- | ----------------------------- |
| **ECO-BDX-U-G-AX01-L** | Accès lecture ressources Serveur AX01 | Groupe Global (utilisateurs)  |
| **ECO-BDX-U-L-AX01-L** | Permission lecture sur AX01           | Groupe Local (ressource)      |
| **ECO-BDX-U-G-DX01**   | Accès administration Firewall         | Groupe Global (admins réseau) |

**Justification : Nomenclature hybride**

1. **Sécurité par obfuscation** : L'utilisation des codes neutres (**AX**, **DX**) empêche l'identification immédiate des services ciblés par les groupes.
2. **Rigueur technique (AGDLP)** : Le maintien des indicateurs de portée (**G** / **L**) est indispensable pour garantir une réplication correcte des objets et une gestion des droits conforme aux standards professionnels du métier.

## 4. Ordinateurs

- **Format** : **ECO-CodeSite-CodeTypeNumero**
- **CodeSite** : **BDX** (Bordeaux)
- **CodeType** : Codes neutres de 2 lettres pour masquer la fonction :
    - Switch (virtuel) : **AX**
    - Poste fixe : **BX**
    - Portable : **CX**
    - Pare-feu / routeur : **DX**
    - Serveur (tout rôle) : **EX**
    - Appliance de sauvegarde : **FX**
    - Station d’administration : **GX**

**Exemples**

- **ECO-BDX-EX01** : Premier serveur (rôle non révélé)
- **ECO-BDX-EX02** : Deuxième serveur de l'infrastructure.
- **ECO-BDX-DX01** : Premier équipement de type pare-feu ou routeur.
- **ECO-BDX-BX42** : Poste fixe utilisateur numéro 42.
- **ECO-BDX-GX01** : Première station d'administration.

**Règles d'inventaire**

Afin de maintenir l'obfuscation, le rôle réel de la machine ne doit jamais apparaître dans son nom d'hôte. L'identification de la fonction se fait exclusivement via :

- La documentation technique **LLD** (dossier **components/**).
- Les notes de configuration dans l'hyperviseur Proxmox.
- L'inventaire de parc (GLPI ou équivalent).

**Justification : Sécurité par obfuscation**

L'utilisation de codes neutres (**AX**, **DX**, etc.) au lieu de noms explicites (AD, SRV, FW) vise à ralentir la phase de reconnaissance d'un attaquant. Sans information directe sur la fonction du serveur dans son nom, l'identification des cibles critiques (comme les contrôleurs de domaine) devient plus complexe, renforçant ainsi la posture de sécurité globale de l'infrastructure.

## 5. Comptes Utilisateurs

### 5.1. Comptes Standards

Les comptes standards sont utilisés pour les tâches quotidiennes (messagerie, bureautique, navigation web).

- **Emplacement (OU)** : **ECOTECH > BDX > UX > Dxx**
- **Convention de nommage** : Afin de maintenir la cohérence avec le service de messagerie existant, l'identifiant (SamAccountName et UPN) suit une règle stricte :
	- **Format** : **<2 premières lettres du prénom><nom\>**
	- **Casse** : Minuscule uniquement.
	- **Exemple** : Anis BOUTALEB devient **anboutaleb**.
- **Gestion des homonymes** : En cas de doublon, un chiffre incrémental est ajouté à la fin de l'identifiant (ex : **anboutaleb**, **anboutaleb1**).

### 5.2. Comptes d'Administration

Pour garantir le respect du principe du moindre privilège et masquer les comptes critiques, nous utilisons le code neutre **GX** (lié aux stations d'administration) suivi d'une lettre de fonction.

- **Emplacement (OU)** : **ECOTECH > BDX > GX**
- **Format** : **GX-Lettre-IdentifiantStandard**

**Détail des fonctions (Tiering) :**

**Tier 0 : Administration de l'Identité**

- **P (Privileged)** : Administration totale du domaine (Schéma, Domain Admins).
- **I (Identity)** : Gestion des objets (Utilisateurs, Groupes, OU).
- **G (Governance)** : Gestion des stratégies de groupe (GPO) et audit.

**Tier 1 : Administration des Serveurs et Services**

- **S (Services)** : Administration des OS serveurs et services réseau (DNS, DHCP).
- **A (Applications)** : Administration des applications métier et bases de données.
- **N (Network)** : Administration des équipements réseau (Firewall, VLAN).
- **B (Backup)** : Gestion des sauvegardes et du plan de reprise d'activité.
- **M (Monitoring)** : Gestion des outils de supervision.

**Exemples concrets :**

- Usage standard : **anboutaleb**
- Administration réseau (Tier 1) : **GX-N-anboutaleb**
- Administration totale AD (Tier 0) : **GX-P-anboutaleb**

**5.3. Justification : Ergonomie et Sécurité Avancée**

L'alignement des comptes standards sur le format de messagerie assure une adoption simple par les 251 collaborateurs.  
Pour les administrateurs, l'utilisation du préfixe **GX** couplé à une segmentation fonctionnelle (**P, I, N, B...**) permet d'appliquer strictement le principe du moindre privilège.  
Cette approche réduit le rayon d'exposition en cas de compromission d'un compte et empêche l'identification des cibles critiques par simple énumération de l'annuaire, tout en garantissant une traçabilité nominative totale.

## 6. Stratégies de Groupe (GPO)

Le nom de chaque GPO doit permettre d'identifier immédiatement sa cible, sa portée et sa version, tout en suivant un index unique pour le suivi documentaire.

**Format** : **[Cible][Type]-[Portee]-[ID]-[Description]-[Version]**

- **Cible et Type (2 lettres)** :
	- **CR** : Computer Restriction (Paramètres de sécurité ordinateur)
	- **CP** : Computer Preference (Configuration/Confort ordinateur)
	- **UR** : User Restriction (Paramètres de sécurité utilisateur)
	- **UP** : User Preference (Configuration/Confort utilisateur)
- **Portée (Code Site ou Global)** :
	- **G** : Global (S'applique à tout le domaine)
	- **BDX** : Bordeaux (S'applique uniquement au site de Bordeaux)
	- **ADM** : S'applique uniquement à l'OU ADMIN (Tier 0/Tier 1)
- **Identifiant (ID)** : Numéro séquentiel sur 3 chiffres (ex : 001, 002) correspondant à l'entrée dans le registre des GPO.
- **Description (But)** : Nom court en anglais ou français sans espace (ex : FirewallRules, MapDrives, DisableUSB).
- **Version** : Indication de la version pour le suivi des modifications (ex : v1.0).

**Exemples de GPO**

|**Nom de la GPO**|**Cible**|**Portée**|**But / Destination**|**Version**|
|---|---|---|---|---|
|**CR-G-001-PasswordPolicy-v1.2**|Ordinateur|Domaine (G)|Stratégie de mots de passe|v1.2|
|**UR-BDX-010-DesktopWallpaper-v1.0**|Utilisateur|Bordeaux|Fond d'écran entreprise|v1.0|
|**CR-ADM-005-RestrictedLogon-v2.1**|Ordinateur|OU Admin|Restriction de connexion Tiering|v2.1|
|**UP-G-022-DriveMapping-v1.1**|Utilisateur|Domaine (G)|Montage des lecteurs réseaux|v1.1|

**Cycle de vie et révision**

- **Modification** : Toute modification majeure d'une GPO entraîne l'incrémentation de la version (v1.0 vers v2.0). Une modification mineure incrémente la décimale (v1.0 vers v1.1).
- **Historique** : Les détails des changements pour chaque version doivent être consignés dans le fichier de suivi des GPO situé dans le dossier **operations/** de la documentation.
- **Désactivation** : Une GPO qui n'est plus utilisée doit être déliée, puis préfixée par **OLD-** avant sa suppression définitive après une période de test.

**Justification : Traçabilité et Audit**

L'intégration d'un **ID unique** et d'un **numéro de version** directement dans le nom de la GPO répond aux exigences d'audit et de conformité.  
Cette rigueur permet d'éviter les conflits lors de déploiements complexes et facilite grandement le dépannage (troubleshooting) en permettant de corréler une modification technique avec une date et un auteur dans le journal de bord du projet.  
Le préfixe cible/type (**CR, CP, UR, UP**) permet de visualiser instantanément sur quelle partie de la ruche (ordinateur ou utilisateur) la stratégie agit, optimisant ainsi le temps d'administration.

## 7. Tags Proxmox (Gestion Lab)

L'utilisation des tags est obligatoire pour la gestion de l'inventaire dans l'hyperviseur :

- **Environnement** : **env-prod** ou **env-test**.
- **Criticité** : **priority-critical**, **priority-high**, **priority-medium**, **priority-low**.

| **Élément à traiter**               | **Statut** | **Détails de la convention choisie**                                         |
| ----------------------------------- | ---------- | ---------------------------------------------------------------------------- |
| **Nom des ordinateurs (VM/CT)**     | ✅          | **ECO-BDX-CodeTypeNum** (ex: AX01, DX01). Couvre serveurs et postes.         |
| **Utilisateurs (Active Directory)** | ✅          | **2 premières lettres prénom + nom** (Standard) et **GX-Lettre-ID** (Admin). |
| **Groupes (Active Directory)**      | ✅          | **ECO-BDX-TYPE-PORTEE-CODENum-DROIT** (Stratégie AGDLP).                     |
| **Unités d'Organisation**           | ✅          | **GX, UX, RX, WX** avec sous-niveaux **D01-D07**.                            |
| **Stratégies de groupe**            | ✅          | **[CibleType]-[Portee]-[ID]-[Description]-[Version]**.                       |
| **Nom des matériels**               | ⚠️         | **À préciser légèrement.**                                                   |
