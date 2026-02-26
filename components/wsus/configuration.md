# Partie A : Configuration du serveur WSUS ECO-BDX-EX16

---

Cette **Partie A** présente de façon complète et ordonnée toute la configuration réalisée directement sur le serveur Windows Server Update Services (WSUS) nommé **ECO-BDX-EX16**.  
Chaque étape est illustrée par les captures d’écran correspondantes. Les explications indiquent clairement ce qui a été fait et pourquoi ce choix est pertinent dans un environnement d’entreprise.

---

## 1. État initial de la console WSUS

![Écran d’accueil WSUS](Capture d’écran 2026-02-21 164315.jpg)

La console s’ouvre sur une vue vide avec le statut « Idle » et le message indiquant qu’aucune synchronisation n’a encore eu lieu.  
C’est le point de départ classique d’une installation fraîche. L’administrateur lance alors l’assistant de configuration pour définir tous les paramètres de base.

---

## 2. Lancement de l’assistant de configuration

![Lancement de l’assistant](Capture d’écran 2026-02-21 164332.jpg)

L’administrateur clique sur **Options** puis sur le lien « WSUS Server Configuration Wizard ».  
Cet assistant officiel permet de configurer les réglages essentiels de manière guidée et fiable.

---

## 3. Pages initiales de l’assistant

![Before You Begin](Capture d’écran 2026-02-21 164417.jpg)  
![Microsoft Update Improvement Program](Capture d’écran 2026-02-21 164437.jpg)

Les prérequis sont validés et l’option du programme d’amélioration Microsoft est cochée.  
Ce programme permet à Microsoft de collecter des statistiques anonymes pour améliorer le service.

![Choose Upstream Server](Capture d’écran 2026-02-21 164459.jpg)  
![Specify Proxy Server](Capture d’écran 2026-02-21 164509.jpg)  
![Start Connecting](Capture d’écran 2026-02-21 164551.jpg)

Le choix « Synchronize from Microsoft Update » est sélectionné (connexion directe). Aucun proxy n’est configuré car l’accès internet est direct. Le bouton « Start Connecting » lance la récupération des métadonnées depuis Microsoft.

---

## 4. Choix des langues, produits et classifications

![Choose Languages](Capture d’écran 2026-02-21 170044.jpg)

Seules les langues **English** et **French** sont conservées.  
Cette sélection réduit considérablement l’espace disque utilisé par les fichiers de mises à jour.

![Choose Products Windows 10-11](Capture d’écran 2026-02-21 172705.jpg)  
![Choose Products Serveurs](Capture d’écran 2026-02-21 172718.jpg)  
![Choose Products Serveurs 2](Capture d’écran 2026-02-21 172945.jpg)

Toutes les versions Windows 10 et Windows 11 Client ainsi que les systèmes serveurs 21H2 à 23H2 sont sélectionnées.  
Le serveur peut ainsi distribuer les mises à jour à l’ensemble du parc postes de travail et serveurs de l’entreprise.

![Choose Classifications](Capture d’écran 2026-02-21 173034.jpg)

Seules les catégories **Critical Updates** et **Security Updates** sont activées.  
Ce choix priorise la sécurité et évite le téléchargement de mises à jour optionnelles inutiles.

---

## 5. Planning de synchronisation et fin de l’assistant

![Set Sync Schedule](Capture d’écran 2026-02-21 173100.jpg)  
![Finished](Capture d’écran 2026-02-21 173241.jpg)  
![What’s Next](Capture d’écran 2026-02-21 173310.jpg)

La synchronisation est configurée en mode automatique (une fois par jour). La case « Begin initial synchronization » est cochée.  
L’assistant se termine et la première synchronisation se lance automatiquement.

---

## 6. Première synchronisation en cours

![Synchronisation démarrée](Capture d’écran 2026-02-21 173731.jpg)  
![Synchronisation running](Capture d’écran 2026-02-21 173850.jpg)

Le statut passe à « Synchronizing… » puis « Running… ».  
Cette phase correspond au téléchargement réel des mises à jour depuis Microsoft Update.

---

## 7. Configuration manuelle via le menu Options

![Options principales](Capture d’écran 2026-02-21 163416.jpg)  
![Update Source and Proxy Server – Source](Capture d’écran 2026-02-21 163439.jpg)  
![Update Source and Proxy Server – Proxy](Capture d’écran 2026-02-21 163637.jpg)

Dans le menu **Options**, la source de mises à jour est confirmée sur Microsoft Update et aucun proxy n’est utilisé.

![Options – Update Files and Languages mis en évidence](Capture d’écran 2026-02-21 163723.jpg)  
![Update Files and Languages](Capture d’écran 2026-02-21 163803.jpg)

La section **Update Files and Languages** est ouverte. Seules les langues **English** et **French** sont conservées.

![Options Computers](Capture d’écran 2026-02-21 175441.jpg)  
![All Computers vide](Capture d’écran 2026-02-21 175657.jpg)  
![Add Computer Group](Capture d’écran 2026-02-21 175912.jpg)  
![Groupes finaux](Capture d’écran 2026-02-21 175959.jpg)

Les groupes d’ordinateurs **Clients**, **DC** et **Servers** sont créés.  
Cette organisation permet de définir des règles différentes selon le type de machine.

---

## Conclusion de la Partie A

Le serveur WSUS ECO-BDX-EX16 est maintenant entièrement configuré côté serveur :  
- Connexion directe à Microsoft Update  
- Langues limitées à English et French  
- Mises à jour critiques et de sécurité uniquement  
- Synchronisation automatique quotidienne  
- Groupes d’ordinateurs créés et prêts à l’emploi  

Cette configuration optimise l’espace disque, la sécurité et la maintenance du serveur.  

---

# Partie B : Configuration des GPO Client pour le serveur WSUS ECO-BDX-EX16

---

Cette **Partie B** se concentre exclusivement sur la configuration des stratégies de groupe (GPO) côté client.  
L’objectif est de faire en sorte que tous les ordinateurs du domaine se connectent automatiquement au serveur WSUS **ECO-BDX-EX16**, s’assignent au bon groupe et appliquent les mises à jour selon un planning défini.  
Chaque capture d’écran est expliquée pour que les étudiants puissent reproduire ces étapes et que le professeur dispose d’un support visuel clair et pédagogique.

---

## 1. Pointage vers le serveur WSUS intranet

![Specify intranet Microsoft update service location](Capture d’écran 2026-02-23 222307.jpg)

La stratégie **Specify intranet Microsoft update service location** est activée (Enabled).  
Les deux champs sont renseignés avec la même URL :  
http://ECO-BDX16.ecotech.local:8530

**Rôle de cette stratégie** : elle indique à tous les ordinateurs Windows du domaine d’utiliser le serveur WSUS interne au lieu de se connecter directement à Microsoft Update sur internet.  
C’est l’étape fondamentale pour centraliser les mises à jour.

---

## 2. Activation du client-side targeting (assignation au groupe)

![Enable client-side targeting](Capture d’écran 2026-02-23 222411.jpg)

La stratégie **Enable client-side targeting** est mise sur **Enabled**.  
Le champ **Target group name for this computer** contient la valeur **Clients**.  

**Rôle de cette stratégie** : elle permet à chaque ordinateur client de s’identifier automatiquement auprès du WSUS en indiquant dans quel groupe il doit être placé (ici le groupe « Clients » créé sur le serveur WSUS).  
Cela facilite l’application de règles spécifiques par groupe (approbations, délais, etc.).

---

## 3. Configuration des mises à jour automatiques

![Configure Automatic Updates](Capture d’écran 2026-02-23 142053.jpg)

La stratégie **Configure Automatic Updates** est activée avec l’option **4 – Auto download and schedule the install**.  
Paramètres sélectionnés :  
- Installation tous les jours  
- Horaire d’installation : **03:00**  

**Rôle de cette stratégie** : elle force les ordinateurs à télécharger automatiquement les mises à jour approuvées par le WSUS et à les installer selon un planning fixe (chaque jour à 3h du matin).  
Ce réglage garantit une application régulière, silencieuse et sans intervention des utilisateurs.

---

# Partie B (suite) : Configuration des GPO Client pour le groupe DC

**Guide pédagogique – Configuration côté client uniquement (serveurs Domain Controllers)**  
*Documentation GitHub – À l’attention des étudiants et du professeur*

---

Cette section complète la **Partie B** en se concentrant sur la configuration des stratégies de groupe (GPO) spécifiques aux **Domain Controllers** (groupe DC).  
L’objectif reste le même que pour les postes clients : diriger les serveurs vers le WSUS interne, les assigner au groupe correspondant sur le serveur WSUS, et définir un planning d’installation adapté aux contraintes des contrôleurs de domaine.

Les captures montrent les réglages appliqués pour les DC, qui diffèrent légèrement de ceux des postes clients classiques.

---

## 1. Pointage vers le serveur WSUS intranet (identique pour tous)

![Specify intranet Microsoft update service location](Capture d’écran 2026-02-23 180800.jpg)

La stratégie **Specify intranet Microsoft update service location** est activée (Enabled).  
Les deux champs (update service et statistics server) pointent vers :  
http://ECO-BDX-EX16.ecotech.local:8530  

**Rôle** : tous les ordinateurs du domaine, y compris les Domain Controllers, utilisent le serveur WSUS local au lieu de Microsoft Update sur internet.

---

## 2. Activation du client-side targeting pour les DC

![Enable client-side targeting pour DC](Capture d’écran 2026-02-23 180833.jpg)

La stratégie **Enable client-side targeting** est mise sur **Enabled**.  
Le champ **Target group name for this computer** contient la valeur **DC**.  

**Rôle** : cette stratégie permet aux Domain Controllers de s’identifier automatiquement auprès du WSUS en indiquant qu’ils appartiennent au groupe **DC** (créé précédemment sur le serveur WSUS).  
Cela permet d’appliquer des règles spécifiques aux contrôleurs de domaine (approbations plus strictes, planning différent, etc.).

---

## 3. Configuration des mises à jour automatiques pour les DC

![Configure Automatic Updates pour DC](Capture d’écran 2026-02-23 142053.jpg)

La stratégie **Configure Automatic Updates** est activée avec l’option **3 – Auto download and notify for install**.  

**Rôle** :  
- Les mises à jour sont téléchargées automatiquement en arrière-plan.  
- Une notification est envoyée à l’utilisateur (administrateur) lorsqu’elles sont prêtes à être installées.  
- L’installation n’est pas automatique : elle nécessite une intervention manuelle ou une approbation explicite.  

**Pourquoi ce choix pour les DC ?**  
Les Domain Controllers sont des machines critiques. Une installation automatique pendant la nuit pourrait causer un redémarrage imprévu et perturber l’authentification du domaine.  
L’option 3 offre un contrôle plus strict : les administrateurs sont informés et décident du moment de l’installation.

**Paramètres supplémentaires observés** :  
- Pas de case cochée pour « Install during automatic maintenance » (pas d’installation forcée).  
- Pas de planning fixe d’installation automatique (contrairement aux postes clients qui utilisent l’option 4 à 03:00).  

---

## Conclusion de la Partie B (suite – DC)

Pour les **Domain Controllers**, les trois stratégies clés sont :  
- Pointage vers le serveur WSUS intranet (http://ECO-BDX-EX16.ecotech.local:8530)  
- Assignation automatique au groupe **DC** sur le WSUS  
- Téléchargement automatique + notification pour installation (option 3) → pas d’installation forcée  

Ce réglage est adapté aux serveurs critiques : il garantit que les mises à jour de sécurité arrivent rapidement, tout en laissant le contrôle final aux administrateurs pour éviter tout risque sur les contrôleurs de domaine.

**Prochaines étapes pour le cours :**  
1. Créer une GPO dédiée aux DC (ou utiliser un filtre WMI / lien spécifique sur l’OU Domain Controllers)  
2. Forcer la mise à jour des stratégies sur un DC test (gpupdate /force)  
3. Vérifier dans la console WSUS que les DC apparaissent dans le groupe **DC** et rapportent leur statut

---

# Partie B (suite) : Configuration des GPO Client pour le groupe Serveurs

---


Cette section poursuit la **Partie B** en présentant les stratégies de groupe (GPO) appliquées spécifiquement aux **serveurs généraux** (groupe **Serveurs** sur le WSUS).  
L’approche reste cohérente avec les précédentes configurations (pointage WSUS + targeting), mais le planning d’installation est adapté aux serveurs non critiques (contrairement aux Domain Controllers).

Les captures montrent les réglages finaux pour ce groupe.

---

## 1. Pointage vers le serveur WSUS intranet (identique pour tous les groupes)

![Specify intranet Microsoft update service location](Capture d’écran 2026-02-23 205456.jpg)

La stratégie **Specify intranet Microsoft update service location** est activée (Enabled).  
Les deux champs pointent vers :  
http://ECO-BDX-EX16.ecotech.local:8530

**Rôle** : tous les serveurs du domaine utilisent le serveur WSUS interne au lieu de se connecter directement à Microsoft Update sur internet.

---

## 2. Activation du client-side targeting pour les serveurs

![Enable client-side targeting pour Serveurs](Capture d’écran 2026-02-23 205555.jpg)

La stratégie **Enable client-side targeting** est mise sur **Enabled**.  
Le champ **Target group name for this computer** contient la valeur **Serveurs**.  

**Rôle** : cette stratégie permet aux serveurs généraux de s’identifier automatiquement auprès du WSUS en indiquant qu’ils appartiennent au groupe **Serveurs**.  
Cela permet d’appliquer des règles d’approbation et de planning spécifiques à ce type de machines (différentes de celles des postes clients ou des DC).

---

## 3. Configuration des mises à jour automatiques pour les serveurs

![Configure Automatic Updates pour Serveurs](Capture d’écran 2026-02-23 205656.jpg)

La stratégie **Configure Automatic Updates** est activée avec l’option **3 – Auto download and notify for install**.  

**Rôle** :  
- Les mises à jour sont téléchargées automatiquement en arrière-plan.  
- Une notification est envoyée lorsqu’elles sont prêtes à être installées.  
- L’installation reste manuelle ou nécessite une approbation explicite (pas de redémarrage forcé).  

**Pourquoi ce choix pour les serveurs généraux ?**  
Les serveurs non-DC sont souvent critiques pour les applications métier. L’option 3 évite les redémarrages imprévus tout en garantissant que les mises à jour arrivent rapidement.  
Les administrateurs peuvent planifier l’installation pendant une fenêtre de maintenance.

**Comparaison avec les autres groupes** :  
- Postes clients → Option 4 (installation automatique à 03:00)  
- Domain Controllers → Option 3 (notification stricte)  
- Serveurs généraux → Option 3 (contrôle humain conservé)

---

## Conclusion de la Partie B (complète)

La configuration GPO client pour le serveur WSUS ECO-BDX-EX16 est maintenant terminée pour tous les groupes :  

- **Postes clients** : pointage WSUS + groupe « Clients » + installation automatique quotidienne à 03:00 (option 4)  
- **Domain Controllers** : pointage WSUS + groupe « DC » + téléchargement auto + notification (option 3)  
- **Serveurs généraux** : pointage WSUS + groupe « Serveurs » + téléchargement auto + notification (option 3)  

Ces réglages assurent une gestion centralisée et sécurisée des mises à jour :  
- Tous les ordinateurs pointent vers le WSUS interne  
- Chaque type de machine est assigné à son groupe dédié  
- Le planning est adapté à la criticité des rôles  

**Prochaines étapes pour le cours :**  
1. Lier les GPO aux OU correspondantes (OU Clients, OU Domain Controllers, OU Serveurs)  
2. Forcer la mise à jour des stratégies sur des machines test (`gpupdate /force`)  
3. Vérifier dans la console WSUS que les ordinateurs apparaissent dans les groupes corrects et rapportent leur statut  
