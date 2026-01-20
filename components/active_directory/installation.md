# Déploiement du Contrôleur de Domaine Principal

Ce document retrace les étapes techniques du déploiement du serveur ECO-BDX-EX01, premier contrôleur de domaine de l'infrastructure EcoTech Solutions.  
Les captures d'écran présentes dans le document permettent d'améliorer la compréhension de l'installation du serveur.

---

## 1. Configuration de l'Hôte

Avant la promotion AD, les paramètres suivants ont été validés pour garantir la conformité au document **[naming.md](/naming.md)**

---

### 1.1. Nom d'hôte : 
* `ECO-BDX-EX01` (Conforme au standard ECO-CodeSite-CodeTypeNum).

![Nom_du_serveur](ressources/1_nom_ECO_BDX_EX01.png) 
![Nom_du_serveur_2](ressources/1_nom_ECO_BDX_EX01_2.png)

Une fois la commande pour accéder au changement de nom rentrée, il suffit d'écrire le nouveau nom et de valider.

---

### 1.2. Adressage IPv4 statique : 
* `10.20.20.5` (Masque /27), Passerelle par défaut `10.20.20.1`.

![IP_du_serveur](ressources/2_IP_ECO_BDX_EX01.png) 
![IP_du_serveur_2](ressources/2_IP_ECO_BDX_EX01_2.png)
![IP_du_serveur_3](ressources/2_IP_ECO_BDX_EX01_3.png) 
![IP_du_serveur_4](ressources/2_IP_ECO_BDX_EX01_4.png)

Pour la configuration IP du serveur, il est préférable de passer par des commandes en CLI.  
* Premièrement, trouver l'interface IP avec la commande `Get-NetIPInterface -AddressFamily IPv4`.
* Deuxièmement, configurer l'adresse IP sur la bonne interface trouvée précédemment avec la commande  
`New-NetIPAddress -InterfaceIndex 3 -IPAddress 10.20.20.5 -PrefixLength 27 -DefaultGateway 10.20.20.1`.
* Troisièmement, vérifier via la commande `ipconfig /all` si la configuration s'est bien appliquée.

---

### 1.3. DNS Local : 
* Configuré sur `127.0.0.1` pour permettre la promotion du rôle AD DS.

![DNS_du_serveur](ressources/3_DNS_ECO_BDX_EX01.png)

Configurer le DNS sur le serveur avec la commande`Set-DnsClientServerAddress -InterfaceIndex 3 -ServerAddresses ("127.0.0.1")`.
Vérifier via la commande `ipconfig /all` que la configuration du DNS est bien appliquée.

---

## 2. Installation et Promotion Active Directory
