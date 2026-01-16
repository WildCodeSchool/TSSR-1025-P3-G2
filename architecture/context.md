<span id="haut-de-page"><span/>
  
## Table des matières

- [1. Présentation de l'entreprise](#1-présentation-de-lentreprise)
- [2. Organisation Interne](#2-organisation-interne)
- [3. Audit de l'existant (État des lieux)](#3-audit-de-lexistant-état-des-lieux)
- [4. Objectifs de la Refonte (Projet)](#4-objectifs-de-la-refonte-projet)

## 1. Présentation de l'entreprise
EcoTech Solutions est une entreprise innovante basée à Bordeaux, spécialisée dans les solutions IoT pour la gestion intelligente de l'énergie et la transition écologique.  
Elle collabore avec des acteurs gouvernementaux et énergétiques pour réduire l'empreinte carbone.   
L'entreprise compte 251 collaborateurs répartis en 7 départements.  
Le projet est réalisé par une société prestataire (votre équipe).

## 2. Organisation Interne
L'entreprise est structurée hiérarchiquement (Directeurs, Managers, Employés) autour des départements suivants :  
- Direction  
- Direction des Ressources Humaines  
- Finance et Comptabilité  
- Développement (Backend, Frontend, Mobile)  
- Commercial  
- Communication  
- DSI
  
Un partenariat stratégique est en cours de négociation, ce qui impose de prévoir une évolutivité de l'architecture.

## 3. Audit de l'existant (État des lieux)
### A. Infrastructure Réseau
La connexion actuelle repose sur une Box FAI standard avec des répéteurs Wi-Fi grand public.  
Le réseau est "plat" (sans segmentation) avec un adressage en 172.16.20.0/24, proche de la saturation au vu du nombre d'employés.  
Aucun équipement d'administration réseau professionnel n'est en place.

### B. Gestion des Identités et Postes
Le parc informatique est constitué à 100 % de PC portables hétérogènes fonctionnant en mode Workgroup (Groupe de travail).   
Il n'y a aucune centralisation : les comptes sont locaux et les mots de passe sont souvent réutilisés ou mal gérés (sécurité critique).

### C. Services et Données
Le stockage repose sur un NAS grand public et l'usage de Cloud personnel non maîtrisé (Shadow IT).  
La messagerie est hébergée en Cloud.  
Les sauvegardes sont uniquement ponctuelles et sans politique de rétention définie, représentant un risque majeur pour les données.

## 4. Objectifs de la Refonte
La mission consiste à professionnaliser l'infrastructure pour atteindre les standards d'entreprise : 
- Centralisation des identités via Active Directory,
- Refonte du plan d'adressage réseau avec segmentation (VLANs),
- Services socles (DHCP, DNS, Fichiers...) et de la sécurité.
- Modernisation de la communication : Remplacement de la téléphonie hétérogène par une solution IP standardisée (FreePBX) pour les postes fixes de bureaux.

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>







