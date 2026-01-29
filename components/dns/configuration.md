# Table des matieres :

## [Configuration du sereur DNS sur le Contrôleur de Domaine Principal Version Core](#domaine-principal)
- [1. Configuration des Forwarders](#configuration-forwarders)
- [2. Sécurisation](#securisation)

# Configuration du sereur DNS sur le Contrôleur de Domaine Principal Version Core.
<span id="domaine-principal"><span/>

## 1. Configuration des Forwarders.
<span id="configuration-forwarders"><span/>

Pour permettre aux utilisateurs et aux serveurs d'accéder à Internet (mises à jour, navigation via proxy), le serveur doit rediriger les requêtes qu'il ne connaît pas vers l'extérieur.

- Cible Primaire : 10.40.0.1 (Interface du pfSense).
- Cible Secondaire : 8.8.8.8 (Google DNS).

``` PowerShell
Add-DnsServerForwarder -IPAddress "10.40.0.1", "8.8.8.8"
```

## 2. Sécurisation
<span id="securisation"><span/>

Conformément au standard de Tiering, les transferts de zone sont restreints pour éviter la fuite d'informations.  
Le serveur autorise uniquement le contrôleur secondaire à répliquer l'annuaire.

``` PowerShell
Set-DnsServerPrimaryZone -Name "ecotech.local" -SecureSecondaries "TransferToSecureServers" -SecondaryServers "10.20.20.6"
```
