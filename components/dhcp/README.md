<span id="haut-de-page"></span>
# DHCP
---
## Table des matières

- [1. Rôle du service](#1-rôle-du-service)
- [2. Position dans l'architecture](#2-position-dans-larchitecture)
- [3. Prérequis](#3-prérequis)
- [4. Fonctionnalités](#4-fonctionnalités)
- [5. Documentation liée](#5-documentation-liée)

## 1. Rôle du service  
Le serveur DHCP attribue automatiquement les paramètres réseau aux équipements clients qui se connectent au réseau (postes de travail, imprimantes, téléphones VoIP, points d'accès, etc.).

Il fournit principalement :
- Adresse IP dynamique (ou fixe via réservation MAC)
- Masque de sous-réseau
- Passerelle par défaut
- Serveurs DNS à utiliser
- Nom de domaine
- Autres options spécifiques (ex : TFTP pour VoIP, NTP, etc.)

## 2. Position dans l'architecture  
- Serveur principal : SRV-DHCP → 172.16.100.3 (VLAN 100)  
- Redondance : À prévoir  
- VLAN concerné : Tous les VLANs utilisateurs dynamiques (VLAN 10 à 90)    
- Type : DHCP centralisé

## 3. Prérequis  
- Serveur Windows Server 2022  
- Adresse IP statique sur le serveur DHCP  
- Accès aux scopes pour chaque VLAN 
- NTP synchronisé  
- Firewall : ports DHCP ouverts (UDP 67/68) depuis les VLANs clients vers le serveur  
- Sauvegarde régulière des bases de leases et des configurations

## 4. Fonctionnalités  
- Réservations MAC      
- Nettoyage automatique des leases expirés  
- Logging vers supervision (alertes sur épuisement de scope)

## 5. Documentation liée  

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
