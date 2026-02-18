
# Guide d'Installation iRedMail

Ce guide détaille l'installation d'un serveur de mail complet utilisant le script iRedMail sur un système Linux vierge.

## 1. Prérequis Système
* **OS :** Debian.
* **RAM :** 2 Go minimum.
* **Réseau :** Port 25 (SMTP) ouvert.

## 2. Configuration du Hostname (Crucial)
Le nom d'hôte de votre serveur doit être un nom de domaine pleinement qualifié (FQDN). 
Exemple : `mail.ecotech-solutions.com`.

```bash
# Définir le hostname
hostnamectl set-hostname mail.ecotech-solutions.com

# Modifier le fichier /etc/hosts
nano /etc/hosts

Vérifiez avec la commande hostname -f. Elle doit retourner mail.ecotech-solutions.com.

3. Téléchargement d'iRedMail

Mettez à jour votre système et téléchargez la dernière version stable.
Bash

apt update && apt upgrade -y
apt install wget tar bzip2 -y

# Télécharger la dernière version (Vérifiez sur iredmail.org pour la version actuelle)
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.7.4.tar.gz

# Extraire le fichier et préparer l'installation

tar xvf 1.7.4.tar.gz
cd iRedMail-1.7.1/

4. Lancement de l'installateur

Lancez le script et suivez l'assistant graphique dans votre terminal.
Bash

bash iRedMail.sh

Étapes de l'assistant :

    Directory : Acceptez le chemin par défaut pour les mails (/var/vmail).

    Web Server : Choisissez Nginx.

    Database : Choisissez MariaDB (plus simple à gérer).

    Password : Définissez le mot de passe de l'administrateur SQL.

    First Domain : Entrez votre domaine principal (ex: votre-domaine.com).

    Admin Password : Définissez le mot de passe pour postmaster@votre-domaine.com.

    Components : Sélectionnez tout (Roundcube, Netdata, iRedAdmin, Fail2ban).

    5. Finalisation

reboot
