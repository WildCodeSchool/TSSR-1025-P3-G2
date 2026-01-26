# Déploiement du Routeur VyOS
----
----

## 1. Présentation de la solution

VyOS est un système d'exploitation réseau open-source basé sur Linux (Debian). C'est un routeur logiciel complet qui s'administre exclusivement en ligne de commande (CLI).

Dans notre infrastructure EcoTech Solutions, ce serveur ne sert pas de simple machine, mais de cœur de routage. Contrairement à un pare-feu comme pfSense qui filtre et protège la sortie vers Internet, le VyOS a pour rôle principal de gérer le trafic interne entre les différentes zones (VLANs), ainsi que le routage entre les différents Zones.

---

## 2. Démarrage sur l’image VyOS

Cette étape correspond au lancement de la machine à partir de l’image ISO de VyOS. Le système démarre en mode live, ce qui permet d’accéder à VyOS sans installation préalable sur le disque.

Vérifier que l’image VyOS démarre correctement

Accéder à l’environnement VyOS pour préparer l’installation

Etape 1 : 

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/318d167342e32204eaf2607f9a1e25f73c38377a/components/Vyos/ressources/installation%20Vyos/Capture%20d%E2%80%99%C3%A9cran%202026-01-21%20100734.png)
