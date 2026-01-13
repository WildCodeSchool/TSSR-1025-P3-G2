## Ce fichier sert à la nomenclature du projet

## Sommaire

- [1. Nomeclature Documentation](#nomenclature-doc)
    - [1.1 Noms de Fichiers](#noms-fichiers) 
    - [1.2 Noms de Dossiers](#noms-dossiers)
    - [1.3 Noms de Services/Composants](#noms-services-composants)
 
- [2 Règles de Formatage Markdown](#regles-markdown)
    - [2.1 Titres](#titres)
    - [2.2 Liens Internes](#liens-internes)
    - [2.3 Images et Ressources](#images-ressources)
    - [2.4 Tableaux](#tableaux)
    - [2.5 Code et Commandes](#code-commandes)

- [3 Nomenclature Réseau](#nomenclature-reseau)
    - [3.1 Structure OU (Unités d’Organisation)](#ou)
    - [3.2 Groupes de sécurités](#groupes-securites)
    - [3.3 Utilisateurs](#utilisateurs)
    - [3.4 Ordinateurs](#ordinateurs)
    - [3.5 Politique de Groupe (GPO)](#gpo)
    - [3.6 Serveurs](#serveurs)
- [4. Récapitulatif](#recapitulatif)


## 1. Nomenclature Documentation
<span id="nomenclature-doc"></span>

### 1.1 Noms de Fichiers
<span id="nomenclature-doc"></span>

**Règles générales :**

- ✓ Utiliser la **casse snake_case** : ip_configuration.md
- ✓ Noms en **anglais** pour les fichiers techniques
- ✓ Extensions en minuscules : .md, .png, .pdf
- 🗙 Éviter les caractères spéciaux : é, à, ç, etc.

**Exemples corrects :**

- overview.md
- ip_configuration.md
- active_directory.md
- schema_reseau_global.png

**Exemples incorrects :**

- 🗙 Vue d'ensemble.md (espaces, accent)
- 🗙 Image1.png (nom non descriptif)
- 🗙 copie-ecran-17.png (nom non explicite)

### 1.2 Noms de Dossiers
<span id="noms-fichiers"></span>

**Règles générales :**

- ✓ Noms en **minuscules**
- ✓ Utiliser des **tirets** - pour séparer les mots
- ✓ Noms descriptifs et concis
- ✓ Un dossier ressources/ dans chaque section principale

**Exemples corrects :**

- architecture/
- components/
- active-directory/
- sprint-01/

**Exemples incorrects :**

- 🗙 Architecture/ (majuscule)
- 🗙 Active Directory/ (espace)
- 🗙 AD/ (acronyme non explicite)

### 1.3 Noms de Services/Composants
<span id="nomenclature-doc"></span>

Pour les services dans le dossier components/, utiliser le format :

- active-directory/
- dns-server/
- dhcp-server/
- web-server/
- firewall-pfsense/

---
## 2. Règles de Formatage Markdown
<span id="nomenclature-doc"></span>

### 2.1 Titres
<span id="nomenclature-doc"></span>

markdown

```markdown
# Titre de niveau 1 (titre principal)
## Titre de niveau 2 (sections principales)
### Titre de niveau 3 (sous-sections)
```

### 2.2 Liens Internes
<span id="nomenclature-doc"></span>

Pour référencer d'autres documents du projet :

markdown

```markdown
Voir la [documentation réseau](../architecture/network.md)
Consulter le [guide d'installation AD](../components/active-directory/installation.md)
```

### 2.3 Images et Ressources
<span id="nomenclature-doc"></span>

Stocker dans le dossier ressources/ et référencer ainsi :

markdown

```markdown
![Schéma réseau global](ressources/schema_reseau_global.png)
```

**Nomenclature des images :**

- Format : nom_descriptif_clair.extension
- Exemples :
    - schema_reseau_global.png
    - topologie_vlan.png
    - capture_config_dhcp.png

### 2.4 Tableaux
<span id="nomenclature-doc"></span>

markdown

```markdown
| Colonne 1 | Colonne 2 | Colonne 3 |
|-----------|-----------|-----------|
| Donnée 1  | Donnée 2  | Donnée 3  |
```

### 2.5 Code et Commandes
<span id="nomenclature-doc"></span>

Pour les commandes ou extraits de configuration :

markdown

````markdown
```bash
# Commande shell
sudo systemctl restart service
```

```powershell
# Commande PowerShell
Get-ADUser -Filter *
```
````

---
## 3. Nomenclature Réseau
<span id="nomenclature-doc"></span>

### 3.1 Structure OU (Unités d’Organisation)
<span id="nomenclature-doc"></span>

- **Critères hiérarchiques** : Société > Site > Département > Service
- **Exemple de hiérarchie** :  
- **Nommage** : Sans accent, sans espace (exemple : **EcoTechSolutions_Bordeaux_Developpement**)
  
### 3.2 Groupes de sécurités
<span id="nomenclature-doc"></span>

- **Convention** :
  - **GRP_[Type]_[Fonction]_[Localisation]_[Portée]**
  - Types : Usr (Utilisateur), PC (Ordinateur), SRV (Serveur), FCT (Fonction)
  - Portée : Local (L) ou Global (G)
- **Exemples** :
  - **GRP_Usr_Developpeurs_Bordeaux_G**
  - **GRP_PC_Portables_Finance_L**
  
### 3.3 Utilisateurs
<span id="nomenclature-doc"></span>

- **Convention** : **prénom.nom** en minuscules, sans accent
- **Gestion des homonymes** : Ajout d’un chiffre (exemple : **adil.abbassi1, adil.abbassi2**)
- **Emplacement** : Selon l’OU du département/service
- **Exemple** : adil.abbassi → OU : **EcoTechSolutions_Bordeaux_DRH_Formation**

### 3.4 Ordinateurs
<span id="nomenclature-doc"></span>

- **Convention** :
  - **[Type]-[Marque]-[Numéro]-[Site]**
  - Types : PC (Poste client), SRV (Serveur), LAP (Portable), VM (Machine virtuelle)
- **Exemples** :
  - **PC-HP-PA66782-BOR**
  - **SRV-DC-01-BOR**
  - **LAP-DELL-PA90183-BOR**

### 3.5 Politique de Groupe (GPO)
<span id="nomenclature-doc"></span>

- **Convention** :
  - **GPO_[Cible]_[Portée]_[Fonction]_[Version]**
  - Cible : **USR, PC, SRV**
  - Portée : **DOM (Domaine), SITE, OU**
  - Version : **V1, V2, etc.**
- **Exemples** :
  - **GPO_USR_DOM_Securite_V1**
  - **GPO_PC_OU_Developpement_Config_V2**

### 3.6 Serveurs
<span id="nomenclature-doc"></span>

- **Nommage unique** : **SRV-[Rôle]-[Numéro]-[Site]**
- **Exemples** :
  - **SRV-DC-01-BOR**
  - **SRV-DHCP-01-BOR**
  - **SRV-FILE-01-BOR**

---

### 4. Récapitulatif :
<span id="nomenclature-doc"></span>

- **Société** : **EcoTechSolutions, UBIHard**
- **Site** : **Bordeaux, Paris, Nantes**
- **Département/Service** : (ex : **Developpement, Finance_Comptabilite)**
- **Marque PC** : **HP, DELL, LENOVO, TOSHIBA**
- **Types de postes** : **PC, LAP, SRV, VM**

Cette nomenclature respecte les règles de nommage et s’adapte aux données du fichier **s01_EcoTechSolutions.xlsx**.
