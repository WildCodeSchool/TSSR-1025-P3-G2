# DHCP Configuration

----

---

1. Dans le DHCP Manager, faites un clique droit, cliquez sur "New Scope"

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/01_dhcp_configuration.jpg)

2. Cliquez sur "Next"

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/02_dhcp_configuration.jpg)

3. Entrez un nom à votre scope, puis une description

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/03_dhcp_configuration.jpg)

4. Tapez le début et la fin de l'étendu de votre réseau, ensuite la longueur (CIDR)

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/04_dhcp_configuration.jpg)

5. Si vous voulez ajoutez des adresses ip d'exclusion, entrez là

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/05_dhcp_configuration.jpg)

6. Tapez la durée du bail choisi pour votre Scope

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/06_dhcp_configuration.jpg)

7. Cochez "Yes, I want to configure these options now" pour poursuivre les configuration DHCP

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/07_dhcp_configuration.jpg)

8. Tapez l'ip de la route par défault

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/08_dhcp_configuration.jpg)

9. Tapez le nom de domaine si vous en faites partie afin de l’attribuer à vos clients.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/09_dhcp_configuration.jpg)

10. Cliquez sur "Next"

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/10_dhcp_configuration.jpg)

11. Cochez la case "Yes, I want to activate this scope now" pour amorcer votre configuration 

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/11_dhcp_configuration.jpg)


La suite de ce fichier expliquera le principe du mode DHCP Failover Load Balancing qui permet d’assurer la continuité de service et la haute disponibilité du DHCP en répartissant automatiquement les requêtes des clients entre deux serveurs. Dans cette infrastructure, ce mécanisme est mis en œuvre entre les serveurs 10.20.20.5 et 10.20.20.6, qui partagent la charge de distribution des adresses IP de manière équilibrée. Les deux serveurs synchronisent en permanence les informations de baux afin de garantir la cohérence des attributions, et un délai de grâce (grace period) est appliqué pour éviter les conflits d’adresses en cas de perte de communication temporaire entre eux. Ce mode permet ainsi de maintenir le service DHCP opérationnel même si l’un des serveurs devient momentanément indisponible, tout en assurant une gestion centralisée et fiable des adresses IP.

1. Dans manager DHCP, cliquez droit sur **"DHCP"** "Manage authorized servers..."

2. Cliquez sur "Authorize..." 

3. Tapez l'adresse IP de votre deuxième serveur dhcp

4. Séléctionnez le serveur secondaire

5. Ouvrer l'onglet de votre PREMIER serveur dhcp, faite un clique droit sur IPv4, cliquez sur "Configure FailOver"

6. Laissez par défault

7. 














