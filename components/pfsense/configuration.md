
# 1. Affectation des Interfaces et VLANs

pfSense est configuré avec plusieurs interfaces virtuelles pour segmenter les flux selon leur niveau de confiance.

- **WAN** : Connexion vers l'extérieur (Internet).
- **LAN / Transit** : Lien vers le routeur interne (VyOS).
- **DMZ (VLAN 500)** : Zone accueillant le serveur Web et le Proxy.

> **[Menu Interfaces > Assignments]**

# 2. Services Réseau de Base

## 2.1. DNS Resolver (Unbound)

pfSense est configuré pour résoudre les noms externes tout en relayant les requêtes internes vers les contrôleurs de domaine **AD-01** et **AD-02**.

## 2.2. NAT (Network Address Translation)

Pour permettre aux serveurs de la DMZ (ex: Serveur Web) d'être accessibles depuis l'extérieur, des règles de **Port Forwarding** sont appliquées.

- **Règle HTTP/HTTPS** : Redirection des ports 80/443 vers l'IP du serveur Web.
- **Port SSH personnalisé** : Redirection du port 22222 pour l'administration distante.

> **[Menu Firewall > NAT > Port Forward]**

# 3. Règles de Pare-feu (Firewall Rules)

La politique de sécurité appliquée est le **"Default Deny"** : tout ce qui n'est pas explicitement autorisé est bloqué.

## 3.1. Règles sur l'interface WAN

Seuls les flux indispensables (VPN, ports exposés de la DMZ) sont autorisés en entrée.

## 3.2. Règles sur l'interface DMZ

Le serveur Web est autorisé à contacter les serveurs de mise à jour, mais ne peut pas initier de connexion vers le VLAN Admin (VLAN 210).

> **[Menu Firewall > Rules (par interface)]**

# 4. Accès Distants (OpenVPN)

pfSense fait office de serveur VPN pour les collaborateurs nomades (Commerciaux) et les sites distants.
