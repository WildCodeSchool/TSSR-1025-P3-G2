
pfSense constitue la barrière périmétrique d'**EcoTech Solutions**. Son rôle est d'assurer l'étanchéité entre le monde extérieur et l'infrastructure interne, tout en gérant le routage de la zone exposée (DMZ).

# 1. Affectation des Interfaces et VLANs

pfSense est configuré avec plusieurs interfaces virtuelles pour segmenter les flux selon leur niveau de confiance.

- **WAN** : Connexion vers l'extérieur (Internet).
- **LAN / Transit** : Lien vers le routeur interne (VyOS).
- **DMZ** : Zone accueillant le serveur Web et le Proxy.

> **[Menu Interfaces > Assignments]**

## 2. Services Réseau de Base

### 2.1. DNS Resolver (Unbound)

Pour garantir la résolution des noms au sein de la forêt **ecotech.local** tout en permettant la navigation externe, le service **Unbound** est configuré en mode hybride.

- **DNS Query Forwarding** : Activé pour rediriger les requêtes inconnues vers des DNS publics sécurisés (ex: Cloudflare 1.1.1.1).
- **Domain Overrides** : Une règle spécifique est créée pour le domaine interne.
    - **Domaine** : **ecotech.local**
    - **IP Cibles** : **10.20.20.5** (AD-01) et **10.20.20.6** (AD-02).

### 2.2. NAT (Network Address Translation)

Pour permettre aux serveurs de la DMZ (ex: Serveur Web) d'être accessibles depuis l'extérieur, des règles de **Port Forwarding** sont appliquées.

- **Règle HTTP/HTTPS** : Redirection des ports 80/443 vers l'IP du serveur Web.
- **Port SSH personnalisé** : Redirection du port 22222 pour l'administration distante.

> **[Menu Firewall > NAT > Port Forward]**

## 3. Règles de Pare-feu (Firewall Rules)

La politique de sécurité appliquée est le **"Default Deny"** : tout ce qui n'est pas explicitement autorisé est bloqué.

### 3.1. Règles sur l'interface WAN

La surface d'attaque est réduite au strict minimum. Seuls les flux destinés à être publiés sont ouverts.

- **Block RFC1918** : Activé pour rejeter tout trafic provenant d'IP privées sur le port WAN (anti-spoofing).
- **ICMP** : Autorisé avec limitation (Rate Limit) pour permettre les tests de diagnostic depuis l'extérieur.

### 3.2. Règles sur l'interface DMZ (Sortant)

La DMZ est une zone à risque car elle est exposée. Son accès vers l'interne est donc strictement interdit.

- **Accès Internet** : Autorisé sur les ports **80** (HTTP), **443** (HTTPS) et **123** (NTP) pour les mises à jour système.
- **Isolation Interne** : Une règle de blocage "Any" est placée vers les réseaux **10.20.10.0/29** (Admin) et **10.60.20.0/16** (Infra) pour empêcher tout rebond d'un attaquant vers le cœur du réseau.

Le serveur Web est autorisé à contacter les serveurs de mise à jour, mais ne peut pas initier de connexion vers le VLAN Admin (VLAN 210).

> **[Menu Firewall > Rules (par interface)]**

# 4. Accès Distants (OpenVPN)

pfSense fait office de serveur VPN pour les collaborateurs sur les sites distants.

# 5. Journalisation et Monitoring (Log Management)

Pour assurer la traçabilité des accès, la journalisation est activée sur les règles de rejet (Drop).

- **System Logs** : Consultation régulière via **Status > System Logs > Firewall**.
- **Analyse de trafic** : Utilisation de l'outil de diagnostic "Packet Capture" sur l'interface WAN pour valider les tentatives de connexion sur le port personnalisé **22222**.
