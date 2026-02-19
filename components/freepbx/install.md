# FreePBX - Phase 1 : Installation

**Version du système :** FreePBX 16.0.33 (Sangoma Linux 7)  
**Date de réalisation :** Février 2026  
**Objectif :** Guide complet de l’installation initiale du serveur FreePBX.

Bonjour,

Ce fichier vous guide étape par étape dans la **phase d’installation** de votre serveur FreePBX. Toutes les captures d’écran sont incluses pour que vous puissiez suivre visuellement chaque action.

---

### Étape 1 : Premier démarrage et login console
Après l’installation de l’ISO FreePBX / Sangoma Linux et le premier redémarrage, connectez-vous en console avec l’utilisateur `root`.

![Premier écran console après installation](Capture d’écran 2026-02-17 193546.jpg)

Vous voyez alors l’écran d’accueil FreePBX avec les informations réseau, les notifications et l’état du système (non activé).

### Étape 2 : Assistant de configuration initiale – Choix des locales
Accédez à l’interface web via `http://10.60.70.5`. L’assistant vous demande de sélectionner les langues par défaut du PBX.

![Sélection des locales](Capture d’écran 2026-02-18 125830.jpg)

Choisissez **English** pour les prompts sonores et **English (United States)** pour la langue système, puis cliquez sur **Submit**.

### Étape 3 : Introduction au wizard Sangoma Smart Firewall
L’assistant Firewall démarre automatiquement. Lisez la présentation du firewall.

![Introduction au wizard Firewall](Capture d’écran 2026-02-18 131311.jpg)

Cliquez sur **Next**.

### Étape 4 : Marquage de votre poste de travail comme Trusted
Le système détecte votre adresse IP actuelle (ici `10.20.10.2/32`). Il est **fortement recommandé** de la marquer comme Trusted pour éviter tout blocage accidentel.

![Question Trusted Client](Capture d’écran 2026-02-18 131323.jpg)

Cliquez sur **Yes**.

### Étape 5 : Confirmation d’activation du Firewall
Le wizard se termine et confirme que le Sangoma Smart Firewall est maintenant activé.

![Firewall activé](Capture d’écran 2026-02-18 131306.jpg)

Cliquez sur **Continue**.

### Étape 6 : Popup SIPStation Free Trial
Une fenêtre publicitaire pour le service SIPStation apparaît. Vous pouvez la fermer.

![Popup SIPStation](Capture d’écran 2026-02-18 132607.jpg)

Cliquez sur **Not Now** pour continuer.

---

**Fin de la Phase 1 – Installation.**  
Passez maintenant au fichier `CONFIGURATION.md` pour configurer vos extensions, firewall et softphones.
