# FreePBX - Phase 2 : Configuration

**Version du système :** FreePBX 16.0.33 (Sangoma Linux 7)  
**Date de réalisation :** Février 2026  
**Objectif :** Guide complet de la configuration post-installation du serveur FreePBX.

Bonjour,

Ce fichier vous guide étape par étape dans la **phase de configuration** de votre serveur FreePBX (après la fin de l’installation). Toutes les captures d’écran sont incluses pour que vous puissiez suivre visuellement chaque action.

---

### Étape 1 : Configuration des réseaux dans le Firewall
Allez dans **Connectivity → Firewall → Networks** et vérifiez/ajoutez vos réseaux locaux.

![Configuration des réseaux Firewall](Capture d’écran 2026-02-18 164555.jpg)

Ajoutez ou modifiez les zones :
- 10.20.10.2/32 → **Trusted (Excluded from Firewall)**
- 10.20.28.0/24 → **Local**
- 10.60.0.0/24 → **Trusted**

Cliquez sur **Save**.

### Étape 2 : Vérification du Responsive Firewall
Retournez sur l’onglet principal du Firewall pour confirmer que le Responsive Firewall est bien activé.

![Responsive Firewall activé](Capture d’écran 2026-02-18 164506.jpg)

Aucune action supplémentaire n’est nécessaire pour les pairs SIP (ils sont autorisés automatiquement après enregistrement).

### Étape 3 : Accès à la création d’extensions
Allez dans **Applications → Extensions** puis cliquez sur **+ Add Extension → Add New SIP [chan_pjsip] Extension**.

![Menu création d’extensions](Capture d’écran 2026-02-18 141017.jpg)

### Étape 4 : Liste des extensions créées
Vous voyez maintenant vos deux extensions :

![Liste des extensions](Capture d’écran 2026-02-18 141034.jpg)

- 1000 → Poste1
- 1001 → Poste2

### Étape 5 : Configuration détaillée d’une extension
Modifiez l’extension (ex. 1000 ou 1001). Attention : le mot de passe (Secret) doit être fort (ici il est faible « 1000 »).

![Édition d’extension PJSIP](Capture d’écran 2026-02-18 164528.jpg)

Renseignez le Display Name, le Secret, puis cliquez sur **Submit** et **Apply Config**.

### Étape 6 : Configuration du softphone 3CXPhone
Sur votre poste Windows, ouvrez 3CXPhone et ajoutez un compte SIP :

![Configuration compte 3CXPhone](Capture d’écran 2026-02-18 162606.jpg)

- Extension : 1000 (ou 1001)
- Password : celui défini dans FreePBX
- IP du PBX : `10.60.70.5`
- Cochez « I am in the office - local IP »

### Étape 7 : Vérification des softphones connectés
Les deux postes sont maintenant enregistrés et affichent « Connected ».

![Softphones connectés](Capture d’écran 2026-02-18 165132.jpg)

Vous pouvez désormais passer des appels internes entre Poste1 et Poste2.

---

## Prochaines étapes recommandées
Une fois ces étapes terminées, vous pouvez poursuivre avec :
1. Création de trunks SIP externes
2. Configuration des routes sortantes et entrantes
3. Mise en place d’un IVR
4. Renforcement de la sécurité (mots de passe forts, Fail2Ban, activation officielle du système)

N’hésitez pas à consulter la documentation officielle FreePBX ou à ouvrir une issue sur ce dépôt si vous rencontrez un problème.

Bonne configuration !
