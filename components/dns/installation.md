# Table des matieres :

## [Installation du sereur DNS sur le Contrôleur de Domaine Principal Version Core](#domaine-principal)
- [1. Intsallation du DNS](#intsallation-DNS)
- [2. Configuration des Forwarders](#configuration-forwarders)
- [3. Sécurisation](#securisation)

# Installation du sereur DNS sur le Contrôleur de Domaine Principal Version Core.
<span id="domaine-principal"><span/>

Ce document retrace les étapes techniques de l'installation du rôle du DNS sur le serveur ECO-BDX-EX01, premier contrôleur de domaine de l'infrastructure EcoTech Solutions.
Les captures d'écran présentes dans le document permettent d'améliorer la compréhension de l'installation du serveur.

## 1. Intsallation du DNS.
<span id="intsallation-DNS"><span/>

La configuration du DNS se fait avec l'adresse `172.0.0.1` car il a le rôle principale et l'adresse `10.20.20.6` correspond au serveur AD secondaire :

- Configurer le DNS sur le serveur avec la commande`Set-DnsClientServerAddress -InterfaceIndex 3 -ServerAddresses ("127.0.0.1, 10.20.20.5")`.
- Vérifier via la commande `ipconfig /all` que la configuration du DNS est bien appliquée.

![IP_config](ressources/1_config_IP_DNS.png)
