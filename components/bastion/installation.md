## 1. Création de la VLAN 520

Le serveur bastion nécessite un réseau isolé pour respecter le principe de séparation des responsabilités. Le VLAN 520 a été créé spécifiquement pour héberger cette infrastructure d'administration sécurisée.

Caractéristiques du VLAN 520 :

- Réseau : 10.50.20.0/28
- Passerelle : 10.50.20.1 (VIP CARP haute disponibilité)
- Usage : Administration sécurisée des serveurs

Ce réseau est distinct de la DMZ publique (VLAN 500) pour éviter qu'une compromission des services exposés à Internet n'impacte les accès d'administration.

---