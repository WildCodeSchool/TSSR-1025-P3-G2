<h2 id="haut-de-page">Table des matières</h2>

- [1. Résumé du projet](#1-résumé-du-projet)
- [2. Schéma global de l'infrastructure](#2-schéma-global-de-linfrastructure)
- [3. Liste des briques techniques principales](#3-liste-des-briques-techniques-principales)
  - [3.1. Services d'infrastructure de base](#31-services-dinfrastructure-de-base)
  - [3.2. Services de stockage et sauvegarde](#32-services-de-stockage-et-sauvegarde)
  - [3.3. Services réseau](#33-services-réseau)
  - [3.4. Supervision et administration](#34-supervision-et-administration)
- [4. Liens vers la documentation détaillée](#4-liens-vers-la-documentation-détaillée)
- [5. Avantages de la nouvelle architecture](#5-avantages-de-la-nouvelle-architecture)
  
## <span id="1-résumé-du-projet">1. Résumé du projet</span>
  
Ce projet vise à concevoir et implémenter une nouvelle infrastructure réseau complète pour **EcoTech Solutions**, une entreprise spécialisée dans les solutions IoT pour la gestion intelligente de l'énergie. Actuellement, l'entreprise fonctionne avec une infrastructure obsolète et non sécurisée, reposant sur un réseau Wi-Fi domestique, sans serveurs, sans authentification centralisée et avec des pratiques de stockage et de sauvegarde inadaptées.
  
**Objectifs globaux** :
- Mettre en place une infrastructure réseau professionnelle et sécurisée
- Centraliser l'authentification et la gestion des utilisateurs
- Organiser le stockage des données avec redondance
- Implémenter des sauvegardes automatisées
- Faciliter l'administration et la maintenance
- Préparer l'entreprise pour sa croissance future et son potentiel partenariat
  
## <span id="2-schéma-global-de-linfrastructure">2. Schéma global de l'infrastructure</span>
  
## <span id="3-liste-des-briques-techniques-principales">3. Liste des briques techniques principales</span>
  
### <span id="31-services-dinfrastructure-de-base">3.1. Services d'infrastructure de base</span>
1. **Active Directory Domain Services (AD DS)**
   - Authentification centralisée
   - Gestion des politiques de groupe (GPO)
   - Organisation hiérarchique (OU par département/service)
  
2. **DNS (Domain Name System)**
   - Résolution de noms interne
   - Intégration avec AD DS
  
3. **DHCP (Dynamic Host Configuration Protocol)**
   - Attribution automatique d'adresses IP
   - Réservation pour les équipements critiques
  
### <span id="32-services-de-stockage-et-sauvegarde">3.2. Services de stockage et sauvegarde</span>
4. **Serveur de fichiers**
   - Stockage centralisé organisé
   - Quotas et permissions AD
  
5. **Solution de sauvegarde**
   - Sauvegardes automatisées
   - Tests de restauration
  
### <span id="33-services-réseau">3.3. Services réseau</span>
6. **Commutateurs managés**
   - Segmentation VLAN
   - Qualité de Service (QoS)
   - Supervision

7. **Wi-Fi professionnel**
   - Remplacer la box FAI
   - Authentification AD
   - Segmentation par VLAN

8. **Services DMZ (VLAN 110)**
   - Serveur Web accessible depuis l'extérieur
   - Serveur VPN pour accès distant sécurisé
   - Serveur de messagerie externe
  
### <span id="34-supervision-et-administration">3.4. Supervision et administration</span>
9. **Outils de supervision**
   - Monitoring des services
   - Alertes et rapports
  
10. **Station d'administration**
   - Outils RSAT
   - Console centrale
  
## <span id="4-liens-vers-la-documentation-détaillée">4. Liens vers la documentation détaillée</span>
  
- **[Contexte et besoins](./context.md)** - Analyse des besoins fonctionnels
- **[Périmètre du projet](./scope.md)** - Éléments inclus et exclus
- **[Architecture réseau](./network.md)** - Découpage VLAN et flux
- **[Configuration IP](./ip_configuration.md)** - Plan d'adressage détaillé
- **[Stratégie de sécurité](./security.md)** - Principes et politiques
- **[Services déployés](./services.md)** - Vue d'ensemble des services
  
## <span id="5-avantages-de-la-nouvelle-architecture">5. Avantages de la nouvelle architecture</span>
  
1. **Sécurité améliorée** : Authentification centralisée, segmentation réseau, politiques de sécurité
2. **Administration simplifiée** : Gestion centralisée des utilisateurs et postes
3. **Scalabilité** : Infrastructure prête pour l'expansion et les partenariats
4. **Continuité d'activité** : Sauvegardes automatisées et redondance
5. **Productivité** : Accès sécurisé aux ressources, moins de temps perdu en incidents

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>


