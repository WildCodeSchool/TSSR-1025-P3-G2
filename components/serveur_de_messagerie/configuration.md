<span id="haut-de-page"></span>

# Configuration iRedMail

Ce document décrit les étapes essentielles après l'installation et le redémarrage d'un serveur **iRedMail open source** sur Debian.

## Table des matières

## [Vérifications et accès de base](#vérifications-et-accès-de-base)
  - [1. Vérifications de base](#1-vérifications-de-base)
    - [1.1. Vérification des services et ports](#11-vérification-des-services-et-ports)
    - [1.2. Fichier iRedMail.tips](#12-fichier-iredmailtips)
  - [2. Accès aux interfaces web](#2-accès-aux-interfaces-web)
    - [2.1. Webmail Roundcube](#21-webmail-roundcube)
    - [2.2. Interface admin iRedAdmin](#22-interface-admin-iredadmin)
    - [2.3. Monitoring Netdata](#23-monitoring-netdata)

## [Gestion des utilisateurs et administrateurs](#gestion-des-utilisateurs-et-administrateurs)
  - [3. Connexion administrateur global initial](#4-connexion-administrateur-global-initial)
  - [4. Gestion des domaines](#5-gestion-des-domaines)
    - [4.1. Ajouter un nouveau domaine](#51-ajouter-un-nouveau-domaine)
  - [5. Création et gestion des utilisateurs](#6-création-et-gestion-des-utilisateurs)
    - [5.1. Créer un nouvel utilisateur / boîte mail](#61-créer-un-nouvel-utilisateur--boîte-mail)
    - [5.2. Changer un mot de passe utilisateur](#62-changer-un-mot-de-passe-utilisateur)
  - [6. Différence Global Admin vs Domain Admin](#7-différence-global-admin-vs-domain-admin)
  - [7. Bonnes pratiques et résumé des accès](#8-bonnes-pratiques-et-résumé-des-accès)
    - [7.1. Bonnes pratiques rapides](#81-bonnes-pratiques-rapides)
    - [7.2. Résumé des accès](#82-résumé-des-accès)

---

## <span id="vérifications-et-accès-de-base"></span>Vérifications et accès de base

### <span id="1-vérifications-de-base"></span>1. Vérifications de base

#### <span id="11-vérification-des-services-et-ports"></span>1.1. Vérification des services et ports

Connectez-vous en root et exécutez :

```bash
# État des services principaux
systemctl status postfix dovecot nginx mariadb fail2ban

# Ports en écoute (25, 465, 587, 993, 995, 80, 443)
ss -ltn | grep -E ':25|:465|:587|:993|:995|:80|:443'
```

#### <span id="12-fichier-iredmailtips"></span>1.2. Fichier iRedMail.tips

Ce fichier contient toutes les informations critiques (URLs, mots de passe, etc.) :

```bash
# Afficher le fichier (adaptez le chemin si nécessaire)
cat /root/iRedMail-1.7.4/iRedMail.tips
```

**Important :** Copiez ce fichier en lieu sûr **immédiatement** (clé USB chiffrée, gestionnaire de mots de passe, etc.). Ne le laissez pas sur le serveur exposé.

### <span id="2-accès-aux-interfaces-web"></span>2. Accès aux interfaces web

Testez ces adresses dans un navigateur (remplacez `10.50.0.7` par votre IP publique ou FQDN) :

#### <span id="21-webmail-roundcube"></span>2.1. Webmail Roundcube
https://10.50.0.7/mail/  
Identifiant exemple : `postmaster@ecotech-solutions.com`

![iRedMail](ressources/01_roundcube_mail.png)

#### <span id="22-interface-admin-iredadmin"></span>2.2. Interface admin iRedAdmin
https://10.50.0.7/iredadmin/  
Identifiant exemple : `postmaster@ecotech-solutions.com`

![iRedMail](ressources/02_iredmail.png)

#### <span id="23-monitoring-netdata"></span>2.3. Monitoring Netdata
https://10.50.0.7/netdata/

![iRedMail](ressources/03_netdata.png)

## <span id="gestion-des-utilisateurs-et-administrateurs"></span>Gestion des utilisateurs et administrateurs

### <span id="3-connexion-administrateur-global-initial"></span>4. Connexion administrateur global initial

- **URL** : https://10.50.0.7/iredadmin/
- **Identifiant** : `postmaster@ecotech-solutions.com` (ou le domaine choisi à l’installation)
- **Mot de passe** : celui défini pendant l’installation (voir `iRedMail.tips`)

### <span id="4-gestion-des-domaines"></span>5. Gestion des domaines

#### <span id="41-ajouter-un-nouveau-domaine"></span>5.1. Ajouter un nouveau domaine

1. Connectez-vous en tant que global admin
2. Cliquez sur **Add** → **Domain**
3. Remplissez :
   - Domain name : ex. `ecotech-solutions.com`
   - Company / Organisation : (optionnel)
   - Description : (optionnel)
   - Quota : vide ou `0` = illimité
4. **Save** / **Ajouter**

→ Le domaine doit exister **avant** de créer des boîtes mail.

### <span id="5-création-et-gestion-des-utilisateurs"></span>6. Création et gestion des utilisateurs

#### <span id="51-créer-un-nouvel-utilisateur--boîte-mail"></span>6.1. Créer un nouvel utilisateur / boîte mail

1. Dans iRedAdmin → **Add** → **User**
2. Remplissez :
   - Mail Address : `jean@ecotech-solutions.com`
   - Password : fort ou généré
   - Name / Display name : Jean Dupont
   - Quota : ex. `2G`, `5G`, `0` = illimité
   - Options avancées : forwarding, auto-réponse… (facultatif)
3. **Save** / **Ajouter**

#### <span id="52-changer-un-mot-de-passe-utilisateur"></span>6.2. Changer un mot de passe utilisateur

- Via iRedAdmin : Users → sélectionnez l’utilisateur → changez le mot de passe
- Via Roundcube (par l’utilisateur lui-même) : Settings → Password

### <span id="6-différence-global-admin-vs-domain-admin"></span>7. Différence Global Admin vs Domain Admin

| Type                   | iRedMail open source (gratuit) | Droits typiques                              |
|------------------------|--------------------------------|----------------------------------------------|
| **Global Admin**       | Oui (plusieurs possibles)      | Gère tous les domaines et utilisateurs       |
| **Domain Admin**       | Non (non disponible)           | —                                            |
| **Utilisateur normal** | Oui                            | Accède uniquement à son webmail Roundcube    |

Pour créer un second **Global Admin** :
1. Créez un utilisateur normal
2. Éditez-le → onglet **General** ou **Profile**
3. Cochez **Global Admin**
4. Sauvegardez

### <span id="7-bonnes-pratiques-et-résumé-des-accès"></span>8. Bonnes pratiques et résumé des accès

#### <span id="71-bonnes-pratiques-rapides"></span>8.1. Bonnes pratiques rapides

- Ne partagez **jamais** les accès root MySQL/MariaDB ou root système
- Créez immédiatement un second compte global admin
- Utilisez des quotas raisonnables au début (2–5 Go par utilisateur)
- Surveillez `/var/log/mail.log` et l’interface Netdata

#### <span id="72-résumé-des-accès"></span>8.2. Résumé des accès

| Usage                        | URL                              | Identifiant exemple                      | Qui peut s'y connecter ?   |
|------------------------------|----------------------------------|------------------------------------------|----------------------------|
| Administration globale       | https://10.50.0.7/iredadmin/     | postmaster@ecotech-solutions.com         | Global admins              |
| Webmail (lecture/écriture)   | https://10.50.0.7/mail/          | jean@ecotech-solutions.com               | Tous les utilisateurs      |
| Monitoring système           | https://10.50.0.7/netdata/       | —                                        | —                          |
  
Documentation officielle : https://docs.iredmail.org/
