<h2 id="haut-de-page">Table des matières</h2>

- [1. Découpage en zones](#decoupage)
  - [1.1. Zone utilisateurs (Département)](#utilisateurs)
  - [1.2. Zone Serveurs (VLAN_100)](#serveurs)
  - [1.3. Zone DMZ (VLAN_110)](#DMZ)
  - [1.4. Zones Spécialisées](#spe)

- [2. Rôle des VLANs principaux](#role-vlans)

- [3. Flux principaux entre zones](#flux-principaux)
  - [3.1. Flux de Services Communs (Infrastructure)](#flux-commun)
  - [3.2. Flux spécifiques par Niveau de Sécurité](#flux-securite)
  - [3.3. Flux Périmétriques (Internet et DMZ)](#flux-perimetrique)
  - [3.4. Contôle et Traçabilité](#controle)

- [4. Principes de routage et filtrage](#principes-routage)
  - [4.1. Gestion de la Passerelle](#passerelle)
  - [4.2. Adressage Dynamique](#dynamique)
  - [4.3. Adressage Statique](#statique)
  - [4.4. Sécurité Périmétrique](#perimetrique)

- [5. Schéma](#schema)
  - [5.1. Zones Internes](#internes)
  - [5.2. Zones Périmètrique](#perimetrique)


## 1. Découpage en zones :
<span id="decoupage"><span/>

### 1.1. Zone utilisateurs (Département) : 
<span id="utilisateurs"><span/>

Regroupe les **différents départements** de l'entreprise :  
- Développement  
- Commercial  
- Communication  
- DRH  
- Finance  
- DSI  
- Direction  
  
### 1.2. Zone Serveurs (VLAN_100) :
<span id="serveurs"><span/>

**Segment critique** hébergeant les services d'infrastructure internes.
(AD / DNS, DHCP, Stockage, VoIP, etc...)

### 1.3. Zone DMZ (VLAN_110) :
<span id="DMZ"><span/>

**Zone tampon exposée** pour les services nécessitant un accès externe **sécurisé**. 
(Web, VPN, Messagerie externe)

### 1.4. Zones Spécialisées : 
<span id="spe"><span/>

Segments dédiés à l'IoT (VLAN_10) et à la VoIP (VLAN_20).

## 2. Rôle des VLANs principaux
<span id="role-vlans"><span/>

| VLAN          | Nom / Département        | Rôle Principal                                     |
| ------------- | ------------------------ | -------------------------------------------------- |
| VLAN_10       | VoIP                     | Objets connectés de l'infrastructure               |
| VLAN_20       | IoT                      | Flux voix sur le réseau IP                         |
| VLAN_30 à 90  | Départements connus      | Postes de travail des différents services          |
| VLAN_100      | Serveurs                 | Coeur des services internes                        |
| VLAN_110      | DMZ                      | Services web et accès distants sécurisés           |

## 3. Flux principaux entre zones
<span id="flux-principaux"><span/>

L'infrastructure applique le principe de **Segmentaion Stricte** et du **moindre privilège**.  
Par défaut, tout flux inter-VLAN **non explicitement autorisé** est bloqué.  

### 3.1. Flux de Services Communs (Infrastructure)
<span id="flux-commun"><span/>

Toutes les zones (VLAN 10 à 90 et 110) sont autorisées à communiquer avec la Zone Serveurs (VLAN 100) pour les services vitaux :

- UDP 53 (DNS) : Résolution de noms auprès du serveur 172.16.100.2.  
- UDP 67-68 (DHCP) : Obtention d'IP via le serveur 172.16.100.3.  
- TCP 445 / 139 (Fichiers) : Accès au serveur de stockage 172.16.100.5 (selon droits AD).  

### 3.2. Flux spécifiques par Niveau de Sécurité :
<span id="flux-securite"><span/>

Basé sur la classification de la politique de sécurité, les flux sont hiérarchisés.

| Source            | Destination           | Protocoles autorisés          | Justification                                                        |
| ----------------- | --------------------- | ----------------------------- | -------------------------------------------------------------------- |
| VLAN_80 (Admin)   | Toutes zones          |                               | Administration et monitoring centralisé                              |
| VLAN_30 (Dev)     | VLAN_100/110          |                               | Accès aux dépôts de code et bases de données lab                     |
| VLAN_80 (DMZ)     | VLAN_100              |                               | Les services exposées interrogent l'AD ou la base de données interne |
| VLAN_10 (VoIP)    | VLAN_100              |                               | Remontée des capteurs vers le serveur de supervision                 |
| VLAN_20 (IoT)     | VLAN_100              |                               | Flux voix vers le serveur VoIP 172.16.100.7                          |

### 3.3. Flux Périmétriques (Internet et DMZ)
<span id="flux-perimetrique"><span/>

Le Firewall (172.16.100.6) assure le rôle de passerelle sécurisée :

- Entrant : **Internet → Firewall → DMZ (VLAN_110)**.  
Seuls les ports 80/443 (Web), 1194 (VPN) et 25 (Mail) sont ouverts.  

- Sortant : **Zones Internes → Firewall → Internet**.    
Accès limité au HTTP / HTTPS pour les utilisateurs. Les serveurs (VLAN_100) n'ont accès qu'aux dépots de mises à jour officiels.  

### 3.4. Contôle et Traçabilité
<span id="controle"><span/>

Conformément au principe de Journalisation complète, chaque flux traversant le Firewall ou le routeur inter-VLAN génère un log envoyé au serveur de logs (VLAN 100) pour analyse par la solution SIEM (ELK).

## 4. Principes de routage et filtrage
<span id="principes-routage"><span/>

### 4.1. Gestion de la Passerelle :
<span id="passerelle"><span/>

Pour chaque segment, **la passerelle** par défaut est **systématiquement positionnée sur la première adresse disponible** du réseau.
(ex : 172.16.100.1 pour la VLAN_100)

### 4.2. Adressage Dynamique :
<span id="dynamique"><span/>

Toutes les VLANs **utilisateurs, IoT et VoIP** reçoivent leur configuration via le **serveur DHCP**.
(IP 172.16.100.3)

### 4.3. Adressage Statique : 
<span id="statique"><span/>

Seules les VLANs **serveurs et DMZ** sont configurées en **IP fixe** pour garantir la stabilité des services.

### 4.4. Sécurité Périmétrique :
<span id="perimetrique"><span/>

**Un firewall** (IP 172.16.100.6) assure le **filtrage** des flux entre les zones sensibles et vers l'exterieur.

## 5. Schéma
<span id="schema"><span/>

### 5.1. Zones Internes
<span id="internes"><span/>

Dans la zone interne, les deux schémas ci-dessous sont sur le même "Switch L3".  
Il est représenter deux fois pour montrer que toutes les VLANs y sont reliés.  
Le schéma du VLAN_100 (Serveurs) est séparé des autres VLANs car il fallait préciser sont contenu.  

#### Schéma VLANs Métiers :

![VLANs_metiers](ressources/VLANs_metiers_5_OK.png)

#### Schéma VLAN_100 (Serveurs) :

![VLAN_100_serveurs](ressources/VLAN_100_serveurs_4_OK.png)

### 5.2. Zone Périmètrique
<span id="perimetre"><span/>

#### Schéma WAN et DMZ :

![WAN_DMZ_OK](ressources/WAN_DMZ_OK.png)

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>



