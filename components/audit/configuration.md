# Installation de l'outils PingCastle sur ECO-BDX-EX02

- Dans ce document sera expliqué les étapes pour corriger les vulnérabilités détéctées suite à l'audit de sécurité.
- De préference les ajustement seront fait dans l'ordre de priorité via GPO, sinon via PowerShell et pour finir via Interface Graphique.

---

## Table des matières 

- [1. Désactivation du service Print Spooler sur les DCs](#1-désactivation-du-service-print-spooler-sur-les-dcs)
  - [Résultat](#résultat)
- [2. Déploiement de Windows LAPS (GPO)](#2-déploiement-de-windows-laps-gpo)
  - [Résultat](#résultat-1)

---

## 1. Désactivation du service Print Spooler sur les DCs

---

### Description de la faille

Le service **Print Spooler** est un service Windows qui gère les travaux d'impression.
Lorsqu'il est actif sur un contrôleur de domaine, il expose le serveur à la vulnérabilité **PrintNightmare (CVE-2021-34527)**.

Cette faille permet à un attaquant d'effectuer une élévation de privilèges jusqu'au niveau **SYSTEM** sur le DC, ce qui représente une compromission totale du domaine.

Un contrôleur de domaine ne devant pas gérer d'impression, ce service doit être désactivé.

---

## Correction

La correction a été appliquée via une GPO liée à l'OU **Domain Controllers**.

**Nom de la GPO :** `CR-DC-01-DisablePrintSpooler-v1.0`

---

### Etape 1 - Création de la GPO

```
- Ouvrir la console GPMC (gpmc.msc)
- Se positionner sur l'OU Domain Controllers
- Clic droit - "Create a GPO in this domain and link it here"
- Nommer la GPO : CR-DC-01-DisablePrintSpooler-v1.0
```

### Etape 2 - Configuration de la GPO

```
- Clic droit sur la GPO - Edit
- Computer Configuration
  - Windows Settings
    - Security Settings
      - System Services
        - Print Spooler
          - Cocher "Define this policy setting"
          - Sélectionner "Disabled"
```

### Etape 3 - Security Filtering

```
- Onglet Scope de la GPO
- Section Security Filtering
- Supprimer les entrées existantes
- Ajouter le groupe "Domain Controllers"
```

### Etape 4 - Application et vérification

```
- Lancer gpupdate /force sur les DCs concernés
- Vérifier le statut du service avec la commande suivante :

Get-Service -Name Spooler
```

**Résultat attendu :**

```
Status     Name       DisplayName
------     ----       -----------
Stopped    Spooler    Print Spooler
```

---

### Résultat

| Elément | Avant | Après |
| --- | --- | --- |
| Statut du service Spooler | Running | Stopped |
| GPO appliquée | Non | Oui |
| Vulnérabilité PrintNightmare | Exposé | Corrigé |

---

## 2. Déploiement de Windows LAPS (GPO)

---

### Description de la faille

Sans LAPS, le compte **Administrateur local** de chaque machine du domaine partage généralement le même mot de passe.
Si un attaquant compromet une machine, il peut utiliser ce mot de passe pour se connecter en administrateur local sur toutes les autres machines du domaine.

**Windows LAPS** (Local Administrator Password Solution) résout ce problème en générant automatiquement un mot de passe unique par machine, en le stockant chiffré dans l'AD et en le renouvelant à intervalles réguliers.

---

## Correction

### Etape 1 - Extension du schéma AD

A effectuer une seule fois sur le domaine depuis le DC détenant le rôle **Schema Master**.

```
- Vérifier quel DC détient le rôle Schema Master :
  netdom query fsmo

- Etendre le schéma AD pour Windows LAPS :
  Update-LapsADSchema
```

**Vérification :**

```
Get-ADObject -SearchBase (Get-ADRootDSE).SchemaNamingContext -Filter {name -like "ms-LAPS*"}
```

Les attributs suivants doivent apparaitre :

```
ms-LAPS-EncryptedDSRMPassword
ms-LAPS-EncryptedDSRMPasswordHistory
ms-LAPS-EncryptedPassword
ms-LAPS-EncryptedPasswordHistory
ms-LAPS-Password
ms-LAPS-PasswordExpirationTime
```

---

### Etape 2 - Délégation des permissions sur les OUs

Chaque machine doit avoir le droit d'écrire son propre mot de passe dans l'AD.
La commande suivante est à répéter sur chaque OU contenant des machines :

```
Set-LapsADComputerSelfPermission -Identity "OU=XX,OU=XX,DC=ecotech,DC=local"
```

---

### Etape 3 - Configuration de la GPO LAPS

**Nom de la GPO :** `CR-BDX-001-LAPS-v1.0`

```
- Ouvrir la console GPMC (gpmc.msc)
- Lier la GPO à l'OU contenant les machines
- Clic droit sur la GPO - Edit
- Computer Configuration
  - Policies
    - Administrative Templates
      - System
        - LAPS
```

**Parametre 1 - Configure password backup directory**

```
- Enabled
- Backup directory : Active Directory
```

**Parametre 2 - Password Settings**

```
- Enabled
- Password complexity : Large letters + small letters + numbers + special characters
- Password length : 14
- Password age (days) : 30
```

**Parametre 3 - Enable password encryption**

```
- Enabled
```

---

### Etape 4 - Application et vérification

```
- Lancer gpupdate /force sur les machines cibles
- Vérifier la génération du mot de passe depuis un DC :

  Get-LapsADPassword -Identity "NOM-DE-LA-MACHINE" -AsPlainText
```

**Résultat attendu :**

```
ComputerName     : NOM-DE-LA-MACHINE
Account          : Administrateur
Password         : xxxxxxxxxxxxxxx
Source           : EncryptedPassword
DecryptionStatus : Success
AuthorizedDecryptor : ECOTECH\Domain Admins
```

---

## Résultat

| Element | Avant | Après |
| --- | --- | --- |
| Mot de passe admin local | Identique sur toutes les machines | Unique par machine |
| Stockage du mot de passe | Non géré | Chiffré dans l'AD |
| Renouvellement | Manuel | Automatique tous les 30 jours |
| Accès au mot de passe | Non contrôlé | Réservé aux Domain Admins |