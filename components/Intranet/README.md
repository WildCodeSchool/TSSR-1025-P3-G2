# Serveur Web Intranet – Portail Collaborateur

## 1. Contexte et Rôle
Le serveur **ECO-BDX-EX07** héberge le portail Intranet d'EcoTech Solutions. Ce service centralise les informations, les liens utiles et le support pour les collaborateurs.
Il a été conçu pour être accessible uniquement depuis le réseau interne (LAN) ou via le VPN, garantissant la confidentialité des données.

## 2. Fiche d'Identité Technique

| Paramètre | Valeur | Description |
| :--- | :--- | :--- |
| **Nom d'hôte** | `ECO-BDX-EX07` | Nomenclature standard. |
| **OS** | Debian 12 (Bookworm) | Système stable et léger. |
| **Adresse IP** | `10.20.20.7` | VLAN 220 (Infrastructure). |
| **Masque** | `/27` | 255.255.255.224 |
| **Passerelle** | `10.20.20.1` | Interface virtuelle du routeur pfSense. |
| **DNS** | `10.20.20.5` | Résolution interne via l'Active Directory. |

## 3. État du Service
- **Moteur Web :** Apache 2.4
- **Sécurité :** Hardening appliqué (Masquage de version).
- **Accès Utilisateur :**
  - URL directe : `http://10.20.20.7`
  - URL DNS : `http://portail.ecotech.local`

- Pour procéder au déploiement, veuillez consulter [Installation.md](./Installation.md).
- Pour les détails de paramétrage, voir [Configuration.md](./Configuration.md).
