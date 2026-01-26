# Configuration - VyOS

**Projet :** EcoTech Solutions
**Groupe :** 2
**OS Cible :** VyOS 1.4+
**Objectif :** Synthèse des commandes pour le déploiement des routeurs (Backbone & Cœur).

Ce document recense les commandes nécessaires pour configurer les interfaces, le routage, les services de base et le pare-feu, ainsi que les commandes de gestion du cycle de vie de la configuration.

## 1. Gestion du Cycle de Vie (Mode Configuration)

Avant de taper ces commandes, il faut entrer en mode configuration via la commande `configure`.

| Action | Commande | Description |
| :--- | :--- | :--- |
| **Entrer en config** | `configure` | Passe du mode utilisateur (`$`) au mode configuration (`#`). |
| **Appliquer** | `commit` | Applique les changements en mémoire vive (RAM). |
| **Sauvegarder** | `save` | Enregistre la configuration active sur le disque (persistant au reboot). |
| **Quitter** | `exit` | Sort du mode configuration. |
| **Annuler** | `exit discard` | Quitte sans sauvegarder les modifications non appliquées. |
| **Voir les modifs** | `compare` | Affiche les différences entre la config active et vos changements non "commités". |

---

## 2. Configuration des Interfaces (Niveau 2 & 3)

Remplacez `[X]` par le numéro de l'interface (ex: `eth0`, `eth1`) et `[ID]` par le VLAN.

| Objectif | Syntaxe de la commande | Exemple Concret |
| :--- | :--- | :--- |
| **IP sur Interface Physique** | `set interfaces ethernet eth[X] address '[IP]/[CIDR]'` | `set interfaces ethernet eth0 address '10.40.20.2/28'` |
| **Description** | `set interfaces ethernet eth[X] description '[TEXTE]'` | `set interfaces ethernet eth0 description 'UPLINK-VERS-DX03'` |
| **Créer une VIF (VLAN)** | `set interfaces ethernet eth[X] vif [ID] address '[IP]/[CIDR]'` | `set interfaces ethernet eth1 vif 210 address '10.20.10.254/24'` |
| **Description VLAN** | `set interfaces ethernet eth[X] vif [ID] description '[NOM]'` | `set interfaces ethernet eth1 vif 210 description 'VLAN-ADMIN'` |
| **Supprimer une IP** | `delete interfaces ethernet eth[X] address` | `delete interfaces ethernet eth0 address` |
| **Supprimer un VLAN** | `delete interfaces ethernet eth[X] vif [ID]` | `delete interfaces ethernet eth1 vif 999` |

---

## 3. Configuration du Routage (Statique)

| Objectif | Syntaxe de la commande | Exemple Concret |
| :--- | :--- | :--- |
| **Route par défaut (Internet)** | `set protocols static route 0.0.0.0/0 next-hop [IP_GW]` | `set protocols static route 0.0.0.0/0 next-hop 10.40.20.1` |
| **Route vers un réseau** | `set protocols static route [RESEAU]/[CIDR] next-hop [IP_GW]` | `set protocols static route 10.60.0.0/16 next-hop 10.40.20.2` |
| **Supprimer une route** | `delete protocols static route [RESEAU]/[CIDR]` | `delete protocols static route 0.0.0.0/0` |

---

## 4. Système et Services de Base

| Objectif | Syntaxe de la commande | Description |
| :--- | :--- | :--- |
| **Nom d'hôte** | `set system host-name '[NOM]'` | Définit le nom de la machine (ex: `ECO-BDX-AX01`). |
| **Serveur DNS** | `set system name-server [IP_DNS]` | Définit le DNS utilisé par le routeur (ex: `1.1.1.1`). |
| **Activer SSH** | `set service ssh port '22'` | Active l'accès distant sécurisé. |
| **DHCP Relay (VLANs)** | `set service dhcp-relay interface eth[X].vif[ID]` | Définit quelle interface écoute les demandes DHCP. |
| **DHCP Relay (Serveur)** | `set service dhcp-relay server [IP_SERVEUR]` | Définit vers où transférer les demandes (IP Serveur Windows). |

---

## 5. Firewalling (Bases - Stateless / Stateful)

*Note : VyOS utilise des "Rulesets" qu'on attache ensuite à une interface et une direction (`in`, `out`, `local`).*

| Étape | Commande | Explication |
| :--- | :--- | :--- |
| **1. Créer le set** | `set firewall name [NOM_SET] default-action 'drop'` | Crée un pare-feu qui bloque tout par défaut. |
| **2. Autoriser le retour** | `set firewall name [NOM_SET] rule 10 action 'accept'`<br>`set firewall name [NOM_SET] rule 10 state established 'enable'`<br>`set firewall name [NOM_SET] rule 10 state related 'enable'` | Indispensable : autorise les réponses aux connexions initiées. |
| **3. Autoriser SSH** | `set firewall name [NOM_SET] rule 20 action 'accept'`<br>`set firewall name [NOM_SET] rule 20 protocol 'tcp'`<br>`set firewall name [NOM_SET] rule 20 destination port '22'` | Autorise le port 22 entrant. |
| **4. Attacher (Direction)** | `set interfaces ethernet eth[X] firewall local name [NOM_SET]` | Applique les règles au trafic destiné au routeur lui-même (Local). |

---

## 6. Diagnostic et Vérification (Mode Opérationnel)

Ces commandes se tapent en mode utilisateur (pas besoin de `configure`, ou utiliser `run` devant si vous êtes en config).

| Commande | Résultat attendu / Usage |
| :--- | :--- |
| `show interfaces` | Affiche la liste des cartes, VLANs, IPs et leur état (u/u = Up/Up). |
| `show ip route` | Affiche la table de routage (S = Static, C = Connected). |
| `show ip route 0.0.0.0` | Vérifie spécifiquement la route par défaut. |
| `show configuration` | Affiche toute la configuration active. |
| `show configuration commands` | Affiche la configuration sous forme de liste de commandes `set`. |
| `ping [IP]` | Teste la connectivité vers une IP. |
| `monitor interface eth[X]` | Affiche le trafic en temps réel (débit) sur une interface. |

---
---

## 7.1 Validation Visuelle (Preuves de fonctionnement)

Cette section illustre l'état du routeur **AX01 (Cœur-L3)** une fois la configuration appliquée.

### 7.1.1 État des Interfaces (VLANs et Adressage)
> **Commande tapée :** `show interfaces`

Ici, nous vérifions que toutes les sous-interfaces (VIF) sont bien créées, possèdent les bonnes adresses IP (Passerelles) et sont dans l'état `u/u` (Up/Up).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/51b86ec2eefbf5cef7e2611b46f9359b6f34670e/components/Vyos/ressources/DX04/show%20interfaces.PNG)

*Vérification : S'assurer que les VLANs 200, 210, 220, 600, etc. sont bien listés sous eth1.*

### 7.1.2 Table de Routage (Connectivité L3)
> **Commande tapée :** `show ip route`

Cette capture valide le routage statique. Nous devons voir les réseaux connectés (C) et surtout la route par défaut (S) vers le Backbone.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/51b86ec2eefbf5cef7e2611b46f9359b6f34670e/components/Vyos/ressources/DX04/show%20ip%20route.PNG)

*Vérification : Présence de la ligne `S>* 0.0.0.0/0 [1/0] via 10.40.20.1, eth0`.*

### 7.1.3 Test de Connectivité (Ping)
> **Commande tapée :** `ping 10.40.20.1 count 4` (Vers Backbone) et `ping 8.8.8.8 count 4` (Vers Internet)

Preuve que le routeur communique bien avec son voisin (DX03) et qu'il accède à l'extérieur.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/51b86ec2eefbf5cef7e2611b46f9359b6f34670e/components/Vyos/ressources/DX04/ping%20LAN.PNG)

*Vérification : 0% packet loss.*

### 7.1.4 Configuration Appliquée (Synthèse)
> **Commande tapée :** `show configuration commands | grep protocols`

Vue synthétique des règles de routage et des protocoles actifs.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/51b86ec2eefbf5cef7e2611b46f9359b6f34670e/components/Vyos/ressources/DX04/ping%20internet.PNG)


### 7.2 Validation Visuelle - Routeur Backbone (DX03)

Cette section illustre l'état du routeur DX03 une fois la configuration appliquée.

### 7.2.1 État des Interfaces (Transits)

    Commande tapée : show interfaces

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/a419c690e53b79516eb0994fc224e65326883c1d/components/Vyos/config%20DX03/show%20interfaces.PNG)

Ici, on vérifie simplement les deux pattes du routeur. Contrairement au AX01, il ne doit pas y avoir de VLANs (pas de .200, .600, etc.), juste les interfaces physiques.

Vérification attendue :

    eth0 : 10.40.10.2/28 (Côté PfSense) - État u/u

    eth1 : 10.40.20.1/28 (Côté Cœur AX01) - État u/u

### 7.2.2 Table de Routage (Le point critique)

    Commande tapée : show ip route

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/a419c690e53b79516eb0994fc224e65326883c1d/components/Vyos/config%20DX03/show%20ip%20route.PNG)


C'est la capture la plus importante pour le Backbone. On doit voir qu'il sait envoyer le trafic vers Internet (défaut) ET renvoyer le trafic vers les réseaux internes (10.20.x et 10.60.x).

Vérification attendue :

    S>* 0.0.0.0/0 via 10.40.10.1 (Route vers Internet via PfSense).

    S>* 10.20.0.0/16 via 10.40.20.2 (Route de retour vers Infra via AX01).

    S>* 10.60.0.0/16 via 10.40.20.2 (Route de retour vers Métiers via AX01).

### 7.2.3 Test de Connectivité (Ping étendu)

    Commandes tapées :

        ping 10.40.10.1 count 4 (Test vers PfSense)


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/a419c690e53b79516eb0994fc224e65326883c1d/components/Vyos/config%20DX03/ping%20pfsense.PNG)


        ping 10.40.20.2 count 4 (Test vers AX01)


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/a419c690e53b79516eb0994fc224e65326883c1d/components/Vyos/config%20DX03/ping%20DX04.PNG)


        ping 8.8.8.8 count 4 (Test vers Internet)


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/a419c690e53b79516eb0994fc224e65326883c1d/components/Vyos/config%20DX03/ping%20Internet.PNG)


Preuve que le Backbone discute bien avec ses deux voisins et accède au WAN.

Vérification attendue : 0% packet loss sur les 3 tests.

### 7.2.4 Synthèse de la configuration active

    Commande tapée : show configuration commands | grep "protocols static"

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/a419c690e53b79516eb0994fc224e65326883c1d/components/Vyos/config%20DX03/protocols%20static.PNG)


Cette vue filtrée permet de valider d'un coup d'œil que toutes les routes statiques ont été saisies correctement sans avoir à lire toute la config.

