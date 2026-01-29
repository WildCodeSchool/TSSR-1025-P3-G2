# Table des matieres :

- # [Installation du sereur DNS sur le Contrôleur de Domaine Principal Version Core](#installation-du-sereur-DNS-sur-le-contrôleur-de-domaine-principal-version-core-)
- [1. Intsallation du DNS](#1-intsallation-du-DNS-)
- [2. Configuration des Forwarders](#2-configuration-des-forwarders-)
- [3. Sécurisation](#3-securisation-)

# Installation du sereur DNS sur le Contrôleur de Domaine Principal Version Core.

Ce document retrace les étapes techniques de l'installation du rôle du DNS sur le serveur ECO-BDX-EX01, premier contrôleur de domaine de l'infrastructure EcoTech Solutions.
Les captures d'écran présentes dans le document permettent d'améliorer la compréhension de l'installation du serveur.

## 1. Intsallation du DNS.

La configuration du DNS se fait avec l'adresse `172.0.0.1` car il a le rôle principale et l'adresse `10.20.20.6` correspond au serveur AD secondaire :

- Configurer le DNS sur le serveur avec la commande`Set-DnsClientServerAddress -InterfaceIndex 3 -ServerAddresses ("127.0.0.1, 10.20.20.5")`.
- Vérifier via la commande `ipconfig /all` que la configuration du DNS est bien appliquée.

![IP_config](ressources/1_config_IP_DNS.png)

## 2. Configuration des Forwarders.

Pour permettre aux utilisateurs et aux serveurs d'accéder à Internet (mises à jour, navigation via proxy), le serveur doit rediriger les requêtes qu'il ne connaît pas vers l'extérieur.

- Cible Primaire : 10.40.0.1 (Interface du pfSense).
- Cible Secondaire : 8.8.8.8 (Google DNS).

``` PowerShell
Add-DnsServerForwarder -IPAddress "10.40.0.1", "8.8.8.8"
```

## 3. Sécurisation

Conformément au standard de Tiering, les transferts de zone sont restreints pour éviter la fuite d'informations.  
Le serveur autorise uniquement le contrôleur secondaire à répliquer l'annuaire.

``` PowerShell
Set-DnsServerPrimaryZone -Name "ecotech.local" -SecureSecondaries "TransferToSecureServers" -SecondaryServers "10.20.20.6"
```
