# Table des matieres :

# [Automatisation du Déploiement Active Directory](#automatisation-du-deploiement-active-directory-)

- [1. Logique du script (Pseudo-code)](#1-logique-du-script-pseudo-code-)
- [2. Quelques points techniques.](#2-quelques-points-techniques)
  - [2.1. Normalisations des Données](#21-normalisations-des-données)
  - [2.2. Gestion Automatique des doublons](#22-gestion-automatique-des-doublons-)
  - [2.3. Construction Dynamique des Groupes](#23-construction-dynamique-des-groupes)
- [3. Conclusion](#3-conclusion)

# Automatisation du Déploiement Active Directory

Ce document détaille le fonctionnement du script Synchro-Ecotech.ps1.  
IL assure le déploiement automatisé de l'infrastructure (OUs), la création des comptes utilisateurs et la gestion des groupes de sécurité à partir d'un fichier source "Fiche_Personnel.csv"  
Il respecte la nomenclature établie dans le fichier [naming](/naming.md).

## 1. Logique du script (Pseudo-code) :

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

## 2. Quelques points techniques.

Le script intègre plusieurs mécanismes de sécurité et de standardisation pour gérer les cas limites (accents, doublons, structure dynamique).

### 2.1. Normalisations des Données

La fonction Get-CleanString est utilisée sur toutes les entrées textuelles avant d'interroger l'Active Directory.

``` PowerShell

# Fonction de nettoyage des chaînes de caractères
# Transforme "Hélène & François" en "helenefrancois"
$Text = $Text.ToLower().Normalize([System.Text.NormalizationForm]::FormD) -replace '\p{Mn}', ''
return $Text -replace '[^a-z0-9]', ''

``` 

L'Active Directory tolère mal les accents ou les caractères spéciaux.  
La normalisation des caractères permet que le domaine se retrouve avec la même écriture.  

### 2.2. Gestion Automatique des doublons :

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

Le script prend en compte les utilsateurs.  
Il les analyse, si l'ID est déjà pris.
Un suffixe numérique est rajouté.  
Exemple :  
- adabbassi devient adabbassi1 ou adabbassi2. (Le chiffre augmente jusqu'à trouver un ID libre).

### 2.3. Construction Dynamique des Groupes

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

## 3. Conclusion

Le script permet de passer du "Fichier_Personnel.csv" à une infrastructure Active Directory complète et conforme.
