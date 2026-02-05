# Installation du serveur GLPI

Ce document présente les étapes d’installation réalisées sur la machine GLPI. Vous trouverez les commandes exécutées et les captures correspondantes. L’installation reste basique pour le Sprint 2 (préparation de la pile LAMP + GLPI), la configuration fine et l’intégration AD arrivent dans les sprints suivants.

### 1. Mise à jour du système

Commande exécutée :

apt update && apt upgrade -y

Cette commande actualise la liste des paquets et applique les mises à jour disponibles. Elle est indispensable avant toute installation pour travailler sur un système à jour et sécurisé.

### 2. Installation de la pile LAMP (Apache + MariaDB + PHP)

Commandes exécutées :

apt install apache2 mariadb-server php php-mysql php-curl php-gd php-mbstring php-xml php-zip php-intl php-apcu php-imagick unzip wget curl -y

- apache2 : serveur web  
- mariadb-server : base de données (remplace MySQL)  
- php + modules : PHP 8.2 avec les extensions nécessaires pour GLPI (curl, gd, mbstring, xml, zip, intl, apcu, imagick)  

Observation : les paquets ont été installés sans erreur majeure (quelques warnings possibles sur les dépendances).

### 3. Sécurisation de MariaDB (mariadb-secure-installation)

Commande exécutée :

mariadb-secure-installation

![Sécurisation MariaDB](ressources/captures/glpi-install-01-mariadb-secure.png)

Étapes réalisées :
- Suppression des utilisateurs anonymes  
- Interdiction de connexion root à distance  
- Suppression de la base test  
- Rechargement des privilèges  

Cela ferme les failles classiques d’une installation MariaDB fraîche.

### 4. Création de la base de données GLPI

Commandes exécutées :

mysql -u root -p

Puis dans le prompt MySQL :

CREATE DATABASE glpi CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;  
CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'MotDePasseTresFort2026';  
GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';  
FLUSH PRIVILEGES;  
EXIT;

La base glpi est créée avec l’utilisateur glpi et un mot de passe fort.

### 5. Téléchargement et extraction de GLPI

Commandes exécutées :

cd /var/www/html  
wget https://github.com/glpi-project/glpi/releases/download/10.0.16/glpi-10.0.16.tgz  
tar xzf glpi-10.0.16.tgz  
mv glpi glpi-prod  
chown -R www-data:www-data glpi-prod  
rm glpi-10.0.16.tgz

GLPI 10.0.16 est téléchargé, extrait dans /var/www/html/glpi-prod et les droits sont donnés à l’utilisateur web.

### 6. Vérification du service Apache

Commande exécutée :

systemctl status apache2

Le service est actif et running.

### Synthèse des commandes clés

- Mise à jour système : apt update && apt upgrade -y  
- Installation LAMP + modules PHP : apt install apache2 mariadb-server php ... -y  
- Sécurisation MariaDB : mariadb-secure-installation  
- Création base + utilisateur : mysql -u root -p  
- Téléchargement GLPI : wget + tar + chown  

### État actuel (Sprint 2)

- Pile LAMP installée et sécurisée  
- GLPI 10.0.16 téléchargé et extrait  
- Services Apache et MariaDB actifs  
- Le serveur est prêt pour l’assistant d’installation web[](http://IP/glpi-prod/install/install.php)

**Date** : 05 février 2026  
**Auteur** : Anis – Groupe 2/4  

N’hésitez pas à consulter le fichier **configuration.md** pour la suite (assistant d’installation, configuration LDAP/AD, durcissement).
