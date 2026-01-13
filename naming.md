## 1. Nomenclature Documentation

### 1.1 Noms de Fichiers

**Règles générales :**

- ✅ Utiliser la **casse snake_case** : `ip_configuration.md`
- ✅ Noms en **anglais** pour les fichiers techniques
- ✅ Extensions en minuscules : `.md`, `.png`, `.pdf`
- ❌ Éviter les caractères spéciaux : `é`, `à`, `ç`, etc.

**Exemples corrects :**

- `overview.md`
- `ip_configuration.md`
- `active_directory.md`
- `schema_reseau_global.png`

**Exemples incorrects :**

- ❌ `Vue d'ensemble.md` (espaces, accent)
- ❌ `Image1.png` (nom non descriptif)
- ❌ `copie-ecran-17.png` (nom non explicite)

### 1.2 Noms de Dossiers

**Règles générales :**

- ✅ Noms en **minuscules**
- ✅ Utiliser des **tirets** `-` pour séparer les mots
- ✅ Noms descriptifs et concis
- ✅ Un dossier `ressources/` dans chaque section principale

**Exemples corrects :**

- `architecture/`
- `components/`
- `active-directory/`
- `sprint-01/`

**Exemples incorrects :**

- ❌ `Architecture/` (majuscule)
- ❌ `Active Directory/` (espace)
- ❌ `AD/` (acronyme non explicite)

### 1.3 Noms de Services/Composants

Pour les services dans le dossier `components/`, utiliser le format :

- `active-directory/`
- `dns-server/`
- `dhcp-server/`
- `web-server/`
- `firewall-pfsense/`

---
## 2. Règles de Formatage Markdown

### 2.1 Titres

markdown

```markdown
# Titre de niveau 1 (titre principal)
## Titre de niveau 2 (sections principales)
### Titre de niveau 3 (sous-sections)
```

### 2.2 Liens Internes

Pour référencer d'autres documents du projet :

markdown

```markdown
Voir la [documentation réseau](../architecture/network.md)
Consulter le [guide d'installation AD](../components/active-directory/installation.md)
```

### 2.3 Images et Ressources

Stocker dans le dossier `ressources/` et référencer ainsi :

markdown

```markdown
![Schéma réseau global](ressources/schema_reseau_global.png)
```

**Nomenclature des images :**

- Format : `nom_descriptif_clair.extension`
- Exemples :
    - `schema_reseau_global.png`
    - `topologie_vlan.png`
    - `capture_config_dhcp.png`

### 2.4 Tableaux

markdown

```markdown
| Colonne 1 | Colonne 2 | Colonne 3 |
|-----------|-----------|-----------|
| Donnée 1  | Donnée 2  | Donnée 3  |
```

### 2.5 Code et Commandes

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
