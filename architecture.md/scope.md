# Contexte du Projet – EcoTech Solutions 🌿​

---

## Présentation de l’Entreprise

**EcoTech Solutions** est une entreprise innovante basée à **Bordeaux**, spécialisée dans les solutions **IoT** dédiées à la gestion intelligente de l’énergie et à la transition écologique.  
Elle collabore avec des acteurs **gouvernementaux et énergétiques** afin de réduire l’empreinte carbone.

L’entreprise compte **251 collaborateurs**, répartis en **7 départements**.  
Le projet de refonte de l’infrastructure est confié à une **société prestataire**, représentée par l’équipe projet.

---

## Organisation Interne

L’entreprise est structurée de manière **hiérarchique** autour de trois niveaux :  
**Directeurs**, **Managers** et **Employés**.

Les départements sont les suivants :

- Direction  
- Ressources Humaines (RH)  
- Finance / Comptabilité  
- Développement  
  - Backend  
  - Frontend  
  - Mobile  
- Commercial  
- Communication  
- DSI  

Un **partenariat stratégique** est actuellement en cours de négociation.  
Ce contexte impose de prévoir une **évolutivité de l’architecture** afin d’anticiper une augmentation des besoins futurs.


---

## Audit de l’Existant – État des Lieux

### A. Infrastructure Réseau

La connexion réseau actuelle repose sur une **Box FAI standard**, complétée par des **répéteurs Wi-Fi grand public**.  
Le réseau est de type **plat**, sans segmentation.

- **Plan d’adressage** : `172.16.20.0/24`
- **Segmentation** : inexistante (pas de VLAN)
- **Équipements professionnels** : absents

Au vu du nombre de collaborateurs, le réseau est **proche de la saturation**, ce qui limite fortement son évolutivité.



### B. Gestion des Identités et des Postes

Le parc informatique est constitué à **100 % de PC portables hétérogènes**.  
Les postes fonctionnent en **mode Workgroup (Groupe de travail)**.

Aucune solution de centralisation n’est en place :
- Comptes **locaux** sur chaque machine
- Mots de passe **réutilisés ou mal gérés**
- Niveau de sécurité jugé **critique**



### C. Services et Données

Le stockage des données repose sur :
- Un **NAS grand public**
- L’utilisation de **Clouds personnels non maîtrisés**

La **messagerie** est hébergée en **Cloud**.  
Les **sauvegardes** sont réalisées de manière ponctuelle, sans politique de rétention définie, ce qui représente un **risque majeur pour l’intégrité des données**.

---

## Objectifs :

La mission consiste à **professionnaliser l’infrastructure informatique** afin d’atteindre les standards d’une entreprise de cette taille.

Les objectifs principaux sont :

- **Centralisation des identités** via un **Active Directory**
- **Refonte du plan d’adressage réseau**
  - Mise en place d’une segmentation par **VLANs**
- **Déploiement des services socles**
  - DHCP  
  - DNS  
  - Serveur de fichiers
- **Renforcement de la sécurité** globale de l’infrastructure

---