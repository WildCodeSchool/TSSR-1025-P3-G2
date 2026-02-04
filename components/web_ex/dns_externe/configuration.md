# Configuration du DNS Split-Horizon pour le site vitrine ecotech-solutions.com

Ce guide explique pas à pas comment créer et configurer la zone DNS interne **ecotech-solutions.com** sur le serveur DNS Windows (Active Directory) pour forcer les clients internes à passer par le Reverse Proxy (10.50.0.5).

**Prérequis**  
- Serveur Windows AD fonctionnel (ex : ECO-BDX-EX01 ou ECO-BDX-EX02)  
- Rôle DNS installé et actif  
- Accès administrateur au serveur (via RDP ou console Proxmox)  
- IP du Reverse Proxy connue : 10.50.0.5

## Étape 1 – Ouvrir le gestionnaire DNS

Ouvrez l’outil **DNS Manager** (dnsmgmt.msc) sur le serveur DNS.

![Capture 01 - Ouverture DNS Manager](ressources/captures/dns-manager-ouverture.png)

**Commentaire capture 01** :  
On voit ici l’arborescence DNS avec les zones existantes (.ecotech.local).  
On va créer une nouvelle zone Forward Lookup dans le dossier Forward Lookup Zones.

## Étape 2 – Créer une nouvelle zone (clic droit)

1. Cliquez droit sur **Forward Lookup Zones**  
2. Choisissez **New Zone…**

![Capture 02 - Clic droit New Zone](ressources/captures/dns-new-zone-clic-droit.png)

**Commentaire capture 02** :  
C’est ici que l’on lance l’assistant de création de zone.

## Étape 3 – Choisir le type de zone : Primary

1. Sélectionnez **Primary zone**  
2. Cochez **Store the zone in Active Directory** (recommandé quand on est sur AD)  
3. Cliquez sur **Next**

![Capture 03 - Choix Primary zone](ressources/captures/dns-zone-type-primary.png)

**Commentaire capture 03** :  
Primary zone = on peut modifier directement les enregistrements sur ce serveur.  
Stockage AD = la zone sera répliquée automatiquement sur les autres DC du domaine.

## Étape 4 – Choisir le scope de réplication

Choisissez **To all DNS servers running on domain controllers in this domain** (ecotech.local)

Cliquez sur **Next**

![Capture 04 - Scope de réplication domaine](ressources/captures/dns-zone-replication-scope-domain.png)

**Commentaire capture 04** :  
C’est la meilleure option pour un petit domaine : réplication sur tous les DC du domaine ecotech.local.

## Étape 5 – Saisir le nom de la zone

Dans le champ **Zone name**, tapez exactement :
