# Mise en place d'une relation d'approbation Active Directory entre ecotech.local et billu.lan

## 1. Prérequis

### Configuration DNS pour la résolution de noms

Avant de créer la relation d'approbation, la résolution de noms entre les deux domaines doit être opérationnelle (prérequis indispensable pour le wizard).

- Ouverture de **Server Manager** > **Outils** > **DNS**.
- Configuration d'un **redirecteur conditionnel** (Conditional Forwarder) pointant vers les serveurs DNS de `billu.lan` (et réciproquement sur le domaine partenaire).

![Console DNS - Configuration des redirecteurs conditionnels](images/dns_conditional_forwarder.png)

## 2. Création de la relation de confiance (New Trust Wizard)

### Accès aux propriétés du domaine

1. Dans **Active Directory Domains and Trusts**, clic droit sur **ecotech.local** > **Propriétés**.
2. Onglet **Approbations** (Trusts).
3. Clic sur le bouton **Nouvelle approbation...** (**New Trust...**).

![Propriétés de ecotech.local - Onglet Approbations - Lancement du wizard](images/trusts_tab_new_trust.png)

### Étapes de l'assistant Nouvelle Approbation

**Étape 1 : Bienvenue dans l'assistant**
- Lancement de l'**assistant Nouvelle Approbation** (New Trust Wizard).

![Bienvenue dans l'assistant Nouvelle Approbation](images/new_trust_wizard_welcome.png)

**Étape 2 : Nom de l'approbation**
- Nom du domaine partenaire : `billu.lan`.

![Saisie du nom de domaine partenaire - billu.lan](images/trust_name_billu_lan.png)

**Étape 3 : Type d'approbation**
- Sélection : **Approbation externe** (External trust) – approbation non transitive entre deux domaines hors forêt.

![Choix du type d'approbation - External trust](images/trust_type_external.png)

**Étape 4 : Direction de l'approbation**
- Sélection : **Bidirectionnelle** (Two-way) – les utilisateurs des deux domaines peuvent s'authentifier mutuellement.

![Direction de l'approbation - Two-way](images/direction_of_trust_twoway.png)

**Étape 5 : Côtés de l'approbation**
- Choix : **Les deux domaines** (Both this domain and the specified domain).
- Fourniture des identifiants d'un compte Administrateur du domaine `billu.lan`.

![Côtés de l'approbation](images/sides_of_trust_both.png)
![Identifiants Administrateur billu.lan](images/username_password_administrator.png)

**Étape 6 : Niveau d'authentification sortant**
- Pour le domaine local (**ecotech.local**) : **Authentification sélective** (Selective authentication).
- Même choix pour le domaine partenaire (**billu.lan**).

![Authentification sélective - Local Domain](images/outgoing_auth_selective_local.png)
![Authentification sélective - Specified Domain](images/outgoing_auth_selective_specified.png)

**Récapitulatif avant création**
- Validation des paramètres : domaine `ecotech.local`, partenaire `billu.lan`, bidirectionnelle, type **External**, authentification sélective.

![Récapitulatif des sélections](images/trust_selections_complete.png)

**Confirmation des approbations**
- Confirmation de l'approbation entrante.
- Confirmation de l'approbation sortante.

![Confirmation Incoming Trust](images/confirm_incoming_trust.png)
![Confirmation Outgoing Trust](images/confirm_outgoing_trust.png)

**Fin de la création**
- Message de succès : « The trust relationship was successfully created. »

![Création de l'approbation terminée](images/trust_creation_complete.png)

## 3. Sécurisation de la relation d'approbation

- **Authentification sélective** activée des deux côtés : seuls les utilisateurs explicitement autorisés pourront accéder aux ressources.
- **Filtrage SID** (SID Filtering) automatiquement activé pour les approbations externes (protection contre les attaques par élévation de privilèges via SID History).

![Avertissement Filtrage SID après création](images/sid_filtering_warning.png)

La relation apparaît désormais dans l'onglet **Approbations** avec :
- Type : **External**
- Transitive : **No**

## 4. Configuration des autorisations - Méthode AGDLP

Pour accorder un accès contrôlé (ex. : RDP) aux administrateurs IT de `billu.lan` tout en respectant l'authentification sélective :

1. Sur le domaine **billu.lan** :
   - Création d'un **Groupe Global** (ex. : `GG_BillU_IT_Admins`) contenant les comptes concernés.

2. Sur le domaine **ecotech.local** :
   - Création d'un **Groupe Domaine Local** (ex. : `DL_EcoTech_RDP_Admins`).
   - Ajout du groupe global distant (`GG_BillU_IT_Admins`) comme membre du groupe domaine local (méthode **AGDLP** : Account → Global → Domain Local → Permissions).

3. Attribution des droits :
   - Ajout du groupe `DL_EcoTech_RDP_Admins` dans les autorisations locales ou la GPO « Allow log on through Remote Desktop Services » sur les serveurs cibles.
   - Sur chaque serveur concerné : clic droit sur l'objet ordinateur > **Propriétés** > onglet **Sécurité** > **Autoriser l'authentification** pour le groupe domaine local.

![Configuration des groupes de sécurité AGDLP et "Allowed to Authenticate"](images/groups_agdlp_allowed_to_authenticate.png)

## 5. Test final de l'accès distant

- Connexion RDP depuis un poste du domaine **billu.lan** avec un compte membre du groupe global.
- Vérification de l'accès uniquement sur les ressources autorisées via le groupe domaine local.
- Contrôle des journaux d'événements (Security) sur les contrôleurs de domaine et serveurs membres pour valider l'authentification croisée.

![Test de connexion RDP réussi depuis le domaine partenaire](images/rdp_test_success.png)
