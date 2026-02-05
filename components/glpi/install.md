Installation GLPI

---

# Installation de GLPI pour le Laboratoire

Ce document recense les principales étapes réalisées lors de l'installation de GLPI, accompagnées des captures d'écran correspondantes. Il est destiné à être présenté à un professeur.

## Prérequis vérifiés

Avant de lancer l’installation via le navigateur, on vérifie que les services de base fonctionnent correctement.

### 1. Statut du serveur web Apache

Le service Apache est actif et tourne depuis plusieurs minutes.

![Statut Apache](image1.png)  

Service actif – Apache HTTP Server 2.4

### 2. Statut de MariaDB (base de données)

Le serveur de base de données est lancé et prêt à recevoir les connexions.

![Statut MariaDB](image2.png)  

MariaDB 11.8.3 – service actif

### 3. Préparation du dossier web

Suppression du fichier index.html par défaut et ajustement des droits pour l’utilisateur web.

![Ajustement des droits](image3.png)  

Dossiers config, files et marketplace passés en propriété www-data avec droits 775

## Étapes de l’installation via le navigateur

### 4. Message temporaire d’accès en écriture

GLPI demande un accès temporaire en écriture sur certains fichiers de configuration pendant l’installation.

![Avertissement écriture](image4.png)  

Accès temporaire nécessaire pour config-db.php et glpicrypt.key

### 5. Choix de la langue

Sélection de la langue d’interface pour l’assistant d’installation.

![Sélection langue](image5.png)  

Langue choisie : Français

### 6. Acceptation de la licence GNU GPL v3

Lecture et acceptation de la licence open-source.

![Licence GLPI](image6.png)  

GNU General Public License – Version 3, 29 juin 2007

![Licence suite](image7.png)  

Écran de licence avec bouton Continuer

### 7. Choix du type d’installation

Nouvelle installation ou mise à jour d’une version existante.

![Début installation](image8.png)  

Option « Installer » sélectionnée

### 8. Vérification de la compatibilité (Étape 0)

GLPI teste l’environnement PHP et les extensions nécessaires.

![Vérification compatibilité](image9.png)  

Tous les tests obligatoires sont passés (curl, gd, intl, zlib, sodium, etc.)

![Vérification sécurité](image10.png)  

Quelques avertissements de sécurité à traiter après l’installation

### 9. Test de connexion à la base de données (Étape 2)

Connexion réussie à MariaDB et sélection de la base.

![Test connexion BDD](image11.png)  

Connexion validée – Base sélectionnée : glpidb

### 10. Initialisation de la base de données (Étape 3)

Création des tables et insertion des données de base.

![Initialisation BDD](image12.png)  

Message de succès : « OK – La base a bien été initialisée »

## Après l’installation – Première connexion

### 11. Tableau de bord principal

Connexion avec le compte super-admin par défaut et affichage des alertes de sécurité.

![Tableau de bord](image13.png)  

Alertes importantes : changer les mots de passe par défaut, supprimer le dossier install/, sécuriser le dossier racine

## Actions critiques recommandées immédiatement après l’installation

- Supprimer le dossier d’installation pour des raisons de sécurité  

- Restreindre les droits en écriture sur le dossier config  

- Changer les mots de passe des comptes par défaut (glpi, post-only, tech, normal)  

- Passer en HTTPS dès que possible (même avec un certificat auto-signé pour le labo)  
- Mettre en place une synchronisation LDAP si besoin (voir document séparé)

Bon laboratoire et bonne présentation !
