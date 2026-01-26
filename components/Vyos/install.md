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

- 1] Se connecter tapez :
     Login : vyos
     Password : vyos

- 2] tapez `install image`

- 3] tapez `yes`
 
- 4] Appuyez sur *ENTREE* 

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6b7efea00d65165844e0aac3dbf46e8606e095b2/components/Vyos/ressources/installation/VM1.png)

Etape 2 : 

- 5] Appuyez sur *ENTREE*

- 6] tapez `yes`

- 7] Appuyez sur *ENTREE*

- 8] Appuyez sur *ENTREE*

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6b7efea00d65165844e0aac3dbf46e8606e095b2/components/Vyos/ressources/installation/VM2.png)

Etape 3 :

- 9] Appuyez sur *ENTREE*

- 10] tapez le mot de passe de l'utilisateur qui se nomme "vyos"

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6b7efea00d65165844e0aac3dbf46e8606e095b2/components/Vyos/ressources/installation/VM3.png)

Etape 4 : 

- 11] Retapez le mot de passe attribuer à l'utilisateur "vyos"

- 12] Appuyez sur *ENTREE*

- 13] tapez `reboot`

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6b7efea00d65165844e0aac3dbf46e8606e095b2/components/Vyos/ressources/installation/VM4.png)

Etape 4 : 

- 14] tapez `y`

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6b7efea00d65165844e0aac3dbf46e8606e095b2/components/Vyos/ressources/installation/vm5.png)

** Après le redémarrage, l’utilisateur doit se connecter au système VyOS avec le compte vyos et le mot de passe définis lors de la phase d’installation. **
