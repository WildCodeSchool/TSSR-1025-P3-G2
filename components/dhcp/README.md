DHCP
----

# 1. Rôle du service
Le serveur DHCP attribue automatiquement les paramètres réseau aux équipements clients qui se connectent au réseau (postes de travail, imprimantes, téléphones VoIP, points d'accès, etc.).
Il fournit principalement :

Adresse IP dynamique (ou fixe via réservation MAC)
Masque de sous-réseau
Passerelle par défaut
Serveurs DNS à utiliser
Nom de domaine
Autres options spécifiques (ex : TFTP pour VoIP, NTP, etc.)

# 2. Position dans l'architecture

Serveur principal : ECO-BDX-EX02 → 10.20.20.6 (VLAN 220)
Serveur secondaire : ECO-BDX-EX01 → 10.20.20.5 (VLAN 220)
Redondance : DHCP Failover en mode Load Balancing (répartition 50/50)
VLAN concernés : Tous les VLANs utilisateurs dynamiques (VLAN 600 - 670)
Type : DHCP centralisé avec haute disponibilité via Failover
Relais DHCP : Activés sur les routeurs / switches L3 pour chaque VLAN utilisateur (ip helper-address vers 10.20.20.6 et 10.20.20.5)

# 3. Prérequis

Serveurs : Windows Server 2022
Adresses IP statiques sur les deux serveurs DHCP
Accès aux scopes pour chaque VLAN sur les deux serveurs
NTP synchronisé sur les deux serveurs (même source de temps)
Firewall et Switch L3 : ports DHCP ouverts (UDP 67/68) depuis les VLANs clients vers les deux serveurs
Communication bidirectionnelle entre les deux serveurs DHCP :
TCP 647 (port Failover)
ICMP (pour tests de connectivité)

Sauvegarde régulière des bases de leases et des configurations
Domaine Active Directory fonctionnel (recommandé pour l’authentification et la gestion centralisée)

# 4. Fonctionnalités

Réservations MAC (fixes par adresse MAC)
DHCP Failover en mode Load Balancing :
Répartition automatique des requêtes clients entre les deux serveurs
Synchronisation en temps réel des baux (MCLT)
Délai de grâce (grace period) pour éviter les conflits d’adresses (géré par Windows)
Option de split-scope manuelle possible en complément si besoin

# 5. Documentation liée

Configuration détaillée du DHCP Failover Load Balancing
Liste des scopes par VLAN et plages d’adresses
Procédure de test et bascule manuelle du Failover
