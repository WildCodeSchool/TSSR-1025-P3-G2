<span id="haut-de-page"></span>
# DNS
---
## Table des matières

- [1. Rôle du service](#1-rôle-du-service)
- [2. Position dans l'architecture](#2-position-dans-larchitecture)
- [3. Prérequis](#3-prérequis)
- [4. Fonctionnalités](#4-fonctionnalités)
- [5. Documentation liée](#5-documentation-liée)

## 1. Rôle du service  
Le service DNS assure la résolution de noms au sein de l’entreprise et vers Internet.  

Il remplit principalement deux fonctions essentielles :
- Résolution des noms internes
- Forwarding des requêtes externes vers des serveurs DNS publics fiables

## 2. Position dans l'architecture  
- Serveurs principaux : Intégré aux contrôleurs de domaine Active Directory  
  - SRV-AD-01 → 172.16.100.2  
  - SRV-AD-02 → 172.16.X.X  
- VLAN : VLAN_100 avec IP statiques  
- Type : DNS autoritaire pour la zone interne ecotech.local  
- Rôle secondaire : Résolveur récursif + forwarder pour les noms externes
- Firewall : ports DNS ouverts vers les clients (voir matrice flux)

## 3. Prérequis  
- Active Directory fonctionnel  
- NTP synchronisé sur tous les DCs  
- Redondance : 2 serveurs DNS  
- Reverse lookup (PTR) activé pour les plages internes
- Firewall : ports DNS ouverts vers les clients

**Zones gérées**  
| Zone                    | Type          | Serveur(s) responsable(s)  |
|-------------------------|---------------|----------------------------|
| ecotech.local           | Primaire      | SRV-AD-01 + SRV-AD-02      |
| 100.16.172.in-addr.arpa | Reverse (PTR) | SRV-AD-01 + SRV-AD-02      |
| 110.16.172.in-addr.arpa | Reverse (PTR) | SRV-AD-01 + SRV-AD-02      |
| Autres VLANs            | Reverse       | SRV-AD-01 + SRV-AD-02      |

**Configuration forwarding**  
- Forwarders externes :  
  - 1.1.1.1 (Cloudflare)  
  - 1.0.0.1 (Cloudflare secondaire)  
  - 8.8.8.8 (Google)

## 4. Fonctionnalités  
- DNS sécurisé 
- Cache DNS activé (amélioration performances)  
- Nettoyage automatique des enregistrements obsolètes 
- Enregistrements statiques pour :  
  - Serveurs critiques (VoIP, messagerie, stockage)  
  - Alias CNAME utiles  
- Protection contre DNS amplification (limitation des réponses aux clients internes)

## 5. Documentation liée

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
