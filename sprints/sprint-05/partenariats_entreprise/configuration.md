# Mise en place d'une relation d'approbation Active Directory entre ecotech.local et billu.lan

## 1. Prérequis

### Configuration DNS pour la résolution de noms

Avant de créer la relation d'approbation, la résolution de noms entre les deux domaines doit être opérationnelle (prérequis indispensable pour le wizard).

- Ouverture de **Server Manager** > **Outils** > **DNS**.
- Configuration d'un **redirecteur conditionnel** (Conditional Forwarder) pointant vers les serveurs DNS de billu.lan (et réciproquement sur le domaine partenaire).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/dns.jpg)

## 2. Création de la relation de confiance (New Trust Wizard)

### Accès aux propriétés du domaine

1. Dans **Active Directory Domains and Trusts**, clic droit sur **ecotech.local** > **Propriétés**.
2. Onglet **Approbations** (Trusts).
3. Clic sur le bouton **Nouvelle approbation...** (**New Trust...**).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154530.png)
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154541.png)

### Étapes de l'assistant Nouvelle Approbation

**Étape 1 : Bienvenue dans l'assistant**
- Lancement de l'**assistant Nouvelle Approbation** (New Trust Wizard).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154545.png)

**Étape 2 : Nom de l'approbation**
- Nom du domaine partenaire : billu.lan.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154553.png)

**Étape 3 : Type d'approbation**
- Sélection : **Approbation externe** (External trust) – approbation non transitive entre deux domaines hors forêt.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154559.png)

**Étape 4 : Direction de l'approbation**
- Sélection : **Bidirectionnelle** (Two-way) – les utilisateurs des deux domaines peuvent s'authentifier mutuellement.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154604.png)

**Étape 5 : Côtés de l'approbation**
- Choix : **Les deux domaines** (Both this domain and the specified domain).
- Fourniture des identifiants d'un compte Administrateur du domaine billu.lan.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154613.png)
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154630.png)

**Étape 6 : Niveau d'authentification sortant**
- Pour le domaine local (**ecotech.local**) : **Authentification sélective** (Selective authentication).
- Même choix pour le domaine partenaire (**billu.lan**).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154637.png)
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154642.png)

**Récapitulatif avant création**
- Validation des paramètres : domaine ecotech.local, partenaire billu.lan, bidirectionnelle, type **External**, authentification sélective.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154650.png)

**Confirmation des approbations**
- Confirmation de l'approbation entrante.
- Confirmation de l'approbation sortante.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154657.png)
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154706.png)

**Fin de la création**
- Message de'information 

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154712.png)

## 3. Sécurisation de la relation d'approbation

- **Authentification sélective** activée des deux côtés : seuls les utilisateurs explicitement autorisés pourront accéder aux ressources.
- **Filtrage SID** (SID Filtering) automatiquement activé pour les approbations externes (protection contre les attaques par élévation de privilèges via SID History).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/Trust/Capture%20d'%C3%A9cran%202026-03-02%20154712.png)

La relation apparaît désormais dans l'onglet **Approbations** avec :
- Type : **External**
- Transitive : **No**


## 5. Autorisation d'authentification sélective sur le serveur cible

Étant donné que la relation d'approbation a été sécurisée au niveau de la forêt avec l'**Authentification Sélective**, les comptes du domaine partenaire n'ont par défaut aucun droit de connexion sur notre infrastructure. Il est impératif de leur accorder explicitement le droit de s'authentifier sur la machine cible (ici, le serveur eco-bdx-ex02).

**Étapes de configuration :**

1. Dans la console **Utilisateurs et ordinateurs Active Directory**, assurez-vous au préalable que l'affichage des **Fonctionnalités avancées** est activé (via le menu *Affichage* > *Fonctionnalités avancées*).
2. Naviguez dans l'arborescence jusqu'à trouver l'objet ordinateur du serveur cible (eco-bdx-ex02).
3. Faites un clic droit sur l'objet **eco-bdx-ex02** et sélectionnez **Propriétés**.
4. Rendez-vous dans l'onglet **Sécurité**.
5. Cliquez sur **Ajouter...** et renseignez le compte de l'administrateur partenaire (ex: BILLU\franck.paisant.admin).
6. Sélectionnez ce compte dans la liste. Dans la fenêtre des autorisations en bas, cherchez la ligne **Autorisé à s'authentifier** (Allowed to Authenticate) et cochez la case **Autoriser**.
7. Cliquez sur **Appliquer** puis sur **OK**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fb149735d9f86b4d2d3a1a503abe42f20443cdba/sprints/sprint-05/partenariats_entreprise/ressources/authentification%20s%C3%A9lective/Capture%20d%E2%80%99%C3%A9cran%202026-03-06%20234019.jpg)
