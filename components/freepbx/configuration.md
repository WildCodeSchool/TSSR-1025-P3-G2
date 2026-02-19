# FreePBX - Phase 2 : Configuration

---


Ce fichier vous guide étape par étape dans la **phase de configuration** de votre serveur FreePBX, une fois l’installation terminée.  
Toutes les captures d’écran sont incluses pour que vous puissiez suivre visuellement chaque action.

Les étapes sont présentées dans l’ordre chronologique réel des actions que vous effectuerez.

---

### Étape 1 : Accès au Firewall depuis le Dashboard
Depuis le tableau de bord principal, cliquez sur **Connectivity** puis sur **Firewall**.

![Accès au Firewall depuis le Dashboard](03_configuration_freepbx.jpg)

Vous arrivez sur la section Firewall. Notez les avertissements éventuels (weak secrets, bad destinations, etc.).

### Étape 2 : Page principale du Firewall et Responsive Firewall
Vérifiez que le **Responsive Firewall** est activé (il l’est par défaut après le wizard initial).

![Page principale Firewall - Responsive Firewall activé](04_configuration_freepbx.jpg)

Le message vert confirme que les endpoints SIP sont automatiquement autorisés après enregistrement.  
Vous pouvez ici relancer le wizard si nécessaire ou désactiver le firewall (déconseillé).

### Étape 3 : Configuration des réseaux dans le Firewall
Allez dans l’onglet **Networks** et configurez vos réseaux locaux.

![Configuration des réseaux dans le Firewall](05_configuration_freepbx.jpg)

Exemples de configuration typique :
- `10.20.10.2/32` → **Trusted (Excluded from Firewall)**
- `10.60.28.0/24` → **Trusted**
- Ajoutez vos autres subnets selon vos besoins.

Cliquez sur **Save** pour appliquer.

### Étape 4 : Accès à la gestion des Extensions
Retournez dans le menu principal : cliquez sur **Applications** puis sur **Extensions**.

![Accès à la section Extensions](06_configuration_freepbx.jpg)

### Étape 5 : Liste des extensions et création d’une nouvelle extension
Vous voyez la liste des extensions existantes (ici 1000 et 1001).  
Cliquez sur **+ Add Extension** → **Add New SIP [chan_pjsip] Extension**.

![Liste des extensions + menu d'ajout](07_configuration_freepbx.jpg)

### Étape 6 : Formulaire de création d’une extension PJSIP
Remplissez les champs de la nouvelle extension (exemple avec l’extension 1003) :

![Formulaire d'ajout d'extension PJSIP](08_configuration_freepbx.jpg)

Points importants :
- **User Extension** : numéro de poste (ex. 1003)
- **Display Name** : nom affiché (ex. "Nom1")
- **Secret** : mot de passe SIP (évitez les mots de passe faibles comme « 1234 » – utilisez un mot de passe complexe !)
- Cliquez sur **Submit** puis sur **Apply Config** (bouton rouge en haut à droite).

### Étape 7 : Configuration du softphone 3CXPhone (côté client Windows)
Sur votre poste de travail, ouvrez **3CXPhone** et créez/ajoutez un compte SIP.

![Configuration du compte dans 3CXPhone](01_configuration_freepbx.jpg)

Paramètres recommandés :
- Extension et Password : ceux définis dans FreePBX
- IP du serveur : `10.60.70.5`
- Cochez **I am in the office - local IP**

Cliquez sur **OK**.

### Étape 8 : Vérification finale – Softphones connectés
Une fois les extensions enregistrées, vos softphones doivent afficher **Connected**.

![Softphones connectés et opérationnels](02_configuration_freepbx.jpg)

Vous pouvez maintenant passer des appels internes entre les postes (composez simplement le numéro de l’autre extension).

---

## Prochaines étapes recommandées
Une fois cette configuration terminée, poursuivez avec :
1. Création de trunks SIP externes
2. Configuration des routes sortantes et entrantes
3. Mise en place d’un IVR (menu vocal)
4. Renforcement de la sécurité (mots de passe forts, Fail2Ban, activation du Deployment ID)

**Astuce** : Après chaque modification importante, cliquez toujours sur le bouton rouge **Apply Config** en haut à droite.

N’hésitez pas à consulter la documentation officielle FreePBX ou à ouvrir une issue sur ce dépôt si vous avez une question.

Bonne configuration !
