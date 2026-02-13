# Table des matieres :

## [Automatisation du Déploiement Active Directory](#automatisation-du-deploiement-active-directory)
- [1. Logique du script (Pseudo-code)](#logique-du-script)
- [2. Quelques points techniques.](#points-techniques)
  - [2.1. Normalisations des Données](#normalisations)
  - [2.2. Gestion Automatique des doublons](#gestion-automatique)
  - [2.3. Construction Dynamique des Groupes](#construction-dynamique)
- [3. Conclusion](#conclusion)

## [Configuration de la Gouvernance (GPO)](#configuration-gpo)
  - [4. Structure des Unités d'Organisation (OU)](#4-structure-des-ou)
  - [5. Stratégies de Sécurité (GPO de Restriction)](#5-strategies-securite)
  - [6. Stratégies de Configuration (GPO Standard)](#6-strategies-confort)
  - [7. Validation du Modèle de Tiering](#7-validation-tiering)

## [Mappage des lecteurs I, J, K](#mappage)
  - [8. Création des Partages et Sécurisation](#8-creation-des-partages)
  - [9. Configuration de la GPO de Mappage](#9-configuration-gpo)
  - [10. Détails des Lecteurs (I, J, K)](#10-details-lecteurs)
  - [11. Sécurisation et Isolation](#11-securisation)


---


# Automatisation du Déploiement Active Directory
<span id="automatisation-du-deploiement-active-directory"></span>

Ce document détaille le fonctionnement du script Synchro-Ecotech.ps1.  
IL assure le déploiement automatisé de l'infrastructure (OUs), la création des comptes utilisateurs et la gestion des groupes de sécurité à partir d'un fichier source "Fiche_Personnel.csv"  
Il respecte la nomenclature établie dans le fichier [naming](/naming.md).

---

## 1. Logique du script (Pseudo-code) :
<span id="logique-du-script"><span/>

Le script suit une logique séquentielle :
    - Vérification des droits de l'utilsateur (Administrateur uniquement)
    - Lecture et compréhension du fichier "Fiche_personnel.csv"
    - Création du squelette du domaine
    - Synchronisation des utilisateurs et des groupes
    - Synchronisation des manageurs

``` markdown

## 1. INITIALISATION

    DÉBUT
        ### Note : La vérification des droits Admin est actuellement désactivée (commentée)
        
        ### CONFIGURATION

        MODE_SIMULATION = VRAI (Par défaut)
        DOMAINE = "ecotech.local"
        CHEMIN_LOG = "C:\Logs\EcoTech_Deploy_Date.log"
        FICHIER_CSV = ".\Fiche_personnels.csv"
        
        ### MAPPING (Départements RH -> Codes Dxx)

        CARTE_DEPT = {
            "Ressources Humaines" -> "D01",
            "Finance"             -> "D02",
            ... (jusqu'à D07)
        }
    FIN

## 2. FONCTION : Build-ServiceMap (Cartographie)

    ### Sert à générer dynamiquement les codes S01, S02...

    DÉBUT
        LIRE tout le CSV
        POUR CHAQUE Département :
            LISTER les Services uniques
            TRIER par ordre alphabétique
            ATTRIBUER un code incrémental (S01, S02, S03...)
            STOCKER la correspondance "Dxx-NomService" -> "Sxx"
        FIN POUR
    FIN

## 3. FONCTION : New-InfraStructure (Architecture)

    DÉBUT
        AFFICHER "Vérification Infrastructure..."
        
        ### Construction étage par étage (Si dossier inexistant -> Créer)

        1. RACINE "ECOTECH"
        2. SITE "BDX"
        3. TYPES "GX", "UX", "RX", "WX"
        
        ### Création des Départements

        POUR CHAQUE Conteneur ("UX", "RX")
            POUR CHAQUE CodeDept ("D01" à "D07")
                VERIFIER et CRÉER le dossier "Dxx" dans le Conteneur
            FIN POUR
        FIN POUR
    FIN


## 4. FONCTION : Sync-Users (Le Cœur du script)

    DÉBUT
        LIRE le CSV
        LANCER Build-ServiceMap (Pour préparer les codes Sxx)
        INITIALISER Compteurs (OK, KO, Skip)

        POUR CHAQUE Ligne du CSV :
            
            // A. CALCULS & NETTOYAGE
            PRÉNOM/NOM = Nettoyer (Espaces, Accents)
            ID_BASE    = 2 premières lettres Prénom + Nom
            CODE_DEPT  = Trouver Code Dxx via Carte_Dept

            // B. GESTION SERVICE & GROUPE (Si service renseigné)
            CODE_SVC = Trouver Code Sxx (ex: S01)
            SI Code_Svc existe :
                // 1. Création OU Service
                CHEMIN_CIBLE = "OU=[Sxx],OU=[Dxx],OU=UX..."
                SI OU "Sxx" manque : CRÉER OU (Description = Nom Réel Service)
                
                // 2. Création Groupe Service (Dans RX)
                NOM_GROUPE = "GRP-UX-[Dxx]-[Sxx]"
                SI Groupe manque : CRÉER Groupe de Sécurité
                AJOUTER Groupe à la liste "A Ajouter"

            // C. GESTION DOUBLONS (Homonymes)
            LOGIN_FINAL = ID_BASE
            COMPTEUR = 1
            TANT QUE (Compte AD [LOGIN_FINAL] existe déjà) :
                LOGIN_FINAL = ID_BASE + COMPTEUR
                INCREMENTER COMPTEUR
            FIN TANT QUE

            // D. CRÉATION UTILISATEUR
            SI Mode Simulation :
                JOURNALISER "Simulation création [LOGIN_FINAL]"
            SINON :
                ESSAYER :
                    CRÉER Utilisateur AVEC :
                        - SamAccountName = LOGIN_FINAL
                        - Tel Bureau     = Colonne "Telephone fixe"
                        - Chemin         = CHEMIN_CIBLE
                        - MotDePasse     = "EcoTech2026!" (Change à la connexion)
                    
                    AJOUTER Utilisateur au(x) Groupe(s) [NOM_GROUPE]
                    INCREMENTER Compteur OK
                SI ERREUR :
                    JOURNALISER l'erreur
                    INCREMENTER Compteur KO
            FIN SI
        FIN POUR
        
        AFFICHER Bilan (Succès / Erreurs)
    FIN

## 5. FONCTION : Sync-Managers (Hiérarchie)

    DÉBUT
        POUR CHAQUE Ligne du CSV :
            SI Colonne Manager remplie :
                RECHERCHER Compte de l'Employé (Via Login calculé)
                RECHERCHER Compte du Manager (Via Prénom + Nom)
                
                SI Les deux existent :
                    LIER l'objet Manager sur la fiche de l'Employé
                FIN SI
        FIN POUR
    FIN

## 6. MENU PRINCIPAL (Interface)

    BOUCLE INFINIE
        AFFICHER En-tête Graphique ("Synchro-Ecotech")
        AFFICHER État Mode Simulation (ACTIF / INACTIF)
        
        CHOIX UTILISATEUR :
            "s" -> Basculer Mode Simulation (Vrai/Faux)
            "1" -> Lancer New-InfraStructure
            "2" -> Lancer Sync-Users
            "3" -> Lancer Sync-Managers
            "4" -> Quitter
    FIN BOUCLE

```

---

## 2. Quelques points techniques.
<span id="points-techniques"><span/>

Le script intègre plusieurs mécanismes de sécurité et de standardisation pour gérer les cas limites (accents, doublons, structure dynamique).

---

### 2.1. Normalisations des Données
<span id="normalisations"><span/>

La fonction Get-CleanString est utilisée sur toutes les entrées textuelles avant d'interroger l'Active Directory.

``` PowerShell

# Fonction de nettoyage des chaînes de caractères
# Transforme "Hélène & François" en "helenefrancois"
$Text = $Text.ToLower().Normalize([System.Text.NormalizationForm]::FormD) -replace '\p{Mn}', ''
return $Text -replace '[^a-z0-9]', ''

``` 

L'Active Directory tolère mal les accents ou les caractères spéciaux.  
La normalisation des caractères permet que le domaine se retrouve avec la même écriture.  

---

### 2.2. Gestion Automatique des doublons :
<span id="gestion-automatique"><span/>

Pour éviter des erreurs de doublons qui pourraient bloquer le script, les homonymes sont gèrés automatiquement.

``` PowerShell

# Gestion automatique des homonymes
$SamAccountName = $IdBase
$Counter = 1

# Tant que le compte existe déjà dans l'AD, on incrémente (ex: tmartin1, tmartin2...)
while (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue) { 
    $SamAccountName = "$IdBase$Counter"
    $Counter++ 
}

```

---

Le script prend en compte les utilsateurs.  
Il les analyse, si l'ID est déjà pris.
Un suffixe numérique est rajouté.  
Exemple :  
- adabbassi devient adabbassi1 ou adabbassi2. (Le chiffre augmente jusqu'à trouver un ID libre).

---

### 2.3. Construction Dynamique des Groupes
<span id="construction-dynamique"><span/>

Le script applique la nomenclature définie dans le document [naming](/naming.md).

``` PowerShell

# Création dynamique du Groupe de Sécurité lié au Service
# Nomenclature : GRP-UX-[CodeDept]-[CodeService]
$GrpName = "GRP-UX-$DeptCode-$SCode"
# Le groupe est rangé dans l'OU de Ressources (RX) correspondante
$GrpPath = "OU=$DeptCode,OU=RX,OU=$SiteName,OU=$RootName,$DomainDN"

if (!(Get-ADGroup -Filter "Name -eq '$GrpName'")) {
     New-ADGroup -Name $GrpName -GroupScope Global -Path $GrpPath
}

```

Le script n'utilise pas de noms de groupes statiques. Il assemble dynamiquement le nom en combinant le code Département (Dxx) et le code Service (Sxx) généré lors de l'analyse du CSV. Le groupe est ensuite automatiquement rangé dans l'OU RX (Ressources), séparant proprement les utilisateurs des droits d'accès.

---

## 3. Conclusion
<span id="conclusion"><span/>

Le script permet de passer du "Fichier_Personnel.csv" à une infrastructure Active Directory complète et conforme.

---

# Configuration de la Gouvernance (GPO)
<span id="configuration-gpo"></span>

Cette section détaille la mise en œuvre des politiques de groupe nécessaires à la sécurisation et à l'administration de l'infrastructure `ecotech.local`.

---

### 4. Structure des Unités d'Organisation (OU)

<span id="4-structure-des-ou"></span>

L'arborescence Active Directory a été structurée sur 4 niveaux pour permettre une application précise des GPO et respecter le modèle de Tiering de l'ANSSI.

* **Niveau 3 (Obfuscation)** : Utilisation de codes neutres pour masquer la fonction des objets : **GX** (Admin), **UX** (Utilisateurs), **RX** (Groupes/Ressources) et **WX** (Postes de travail).
* **Niveau 4 (Départements)** : Segmentation sous **UX** et **RX** utilisant les codes **D01 à D07**.

---

### 5. Stratégies de Sécurité (GPO de Restriction)

<span id="5-strategies-securite"></span>

Conformément aux objectifs de sécurité, 7 GPO de restriction ont été identifiées, dont la gestion du pare-feu, le blocage du registre et la politique PowerShell.

#### Exemple détaillé : Politique de sécurité PowerShell

La GPO `CR-ADM-001-PowerShellSecurity-v1.0` assure que seuls les scripts autorisés s'exécutent sur les machines d'administration.

## **Étape 1** : Ouverture de la console **Group Policy Management**.

![Etape 1](ressources/6_GPO_ECO_BDX_EX02_1.png)

## **Étape 2** : Création

![Etape 2](ressources/6_GPO_ECO_BDX_EX02_2.png)

## **Étape 3** : Configuration

![Etape 3](ressources/6_GPO_ECO_BDX_EX02_3.png)
![Etape 3](ressources/6_GPO_ECO_BDX_EX02_4.png)
![Etape 3](ressources/6_GPO_ECO_BDX_EX02_5.png)

## **Étape 4** : Validation de la création et de la liaison sur l'OU **GX** (Tiering).

![Etape 4](ressources/6_GPO_ECO_BDX_EX02_6.png)

---

### 6. Stratégies de Configuration (GPO Standard)

<span id="6-strategies-confort"></span>

Au moins 3 GPO standards ont été déployées pour uniformiser l'environnement de travail.

| Nom de la GPO | Cible | Objectif |
| --- | --- | --- |
| **UR-BDX-010-DesktopWallpaper-v1.0** | Utilisateur | Application du fond d'écran institutionnel. |
| **UP-G-022-DriveMapping-v1.1** | Utilisateur | Mappage automatique des lecteurs réseaux départementaux. |
| **UR-BDX-013-FolderRedirection-v1.0** | Utilisateur | Redirection des dossiers Bureau et Documents vers le serveur. |

---

### 7. Validation du Modèle de Tiering

<span id="7-validation-tiering"></span>

Le respect du modèle de Tiering est assuré par l'isolation de l'OU **GX**. La GPO `CR-ADM-005-RestrictedLogon-v1.0 interdit aux comptes d'administration (Tier 0/1) de se connecter sur des postes utilisateurs standards (OU **WX**) afin de prévenir le vol d'identifiants.

Toute modification de ces restrictions s'effectue par l'édition directe de l'objet lié :

Cette configuration garantit qu'une compromission sur un poste de travail `BX` ou `CX` ne pourra pas s'étendre aux comptes privilégiés du domaine.

---

## [Mappage des lecteurs I, J, K](#mappage)
<span id="mappage"></span>

## 8. Création des Partages et Sécurisation
<span id="8-creation-des-partages"></span>

Pour les lecteurs **I** **J** **K**, nous utilisons PowerShell pour créer une structure dont la visibilité est limitée par l'**Access-Based Enumeration (ABE)**.

### Étape 1 : Création du répertoire local

Nous créons les dossiers racine sur le serveur de fichiers.

```powershell
New-Item -Path "C:\Prive" -ItemType Directory
```

### Étape 2 : Partage avec énumération basée sur l'accès

Le paramètre `-FolderEnumerationMode AccessBased` garantit qu'un utilisateur ne verra que son propre dossier dans le partage.

```powershell
New-SmbShare -Name "Prive$" -Path "C:\Prive" -FullAccess "Administrators", "SYSTEM" -ReadAccess "Users" -FolderEnumerationMode AccessBased

```

## 9. Configuration de la GPO de Mappage
<span id="9-configuration-gpo"></span>

Le mappage automatique est géré par la GPO.

### Emplacement de la stratégie

La configuration se situe dans : `Configuration utilisateur` > `Préférences` > `Paramètres Windows` > `Drive Maps`.

> Capture d'écran

## 10. Détails des Lecteurs (I, J, K)
<span id="10-details-lecteurs"></span>

### Configuration du Lecteur K (Département)

Chaque lecteur utilise l'action **Update** pour assurer la persistance de la connexion.

> Capture d'écran

### Ciblage par Groupe (Item-Level Targeting)

Pour respecter la consigne "les autres utilisateurs ne voient pas ce dossier", chaque mappage est filtré par le groupe de sécurité AD correspondant.

> Capture d'écran

---

## 11. Sécurisation et Isolation
<span id="11-securisation"></span>

### Blocage de l'héritage

Pour les dossiers, l'héritage est désactivé au niveau de l'Unité d'Organisation (OU) ou du dossier pour isoler strictement les flux de données.

> Capture d'écran

### Matrice de correspondance des lecteurs

| Lettre | Dossier | Accès | Visibilité |
| --- | --- | --- | --- |
| **I:** | **Privé** | Utilisateur uniquement | Masqué pour les autres (ABE) |
| **J:** | **Service** | Membres du Service (Sxx) | Masqué pour les autres services |
| **K:** | **Département** | Membres du Département (Dxx) | Masqué pour les autres départements |

---

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
