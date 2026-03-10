<span id="haut-de-page"></span>

# Configuration — AD CS EcoTech

---

## Table des matières

---

## 1. Certification de ECO-BDX-EX07 (Intranet)

### 1.1 Création du Dossier SSL

``` Bash
sudo mkdir -p /etc/apache2/ssl
cd /etc/apache2/ssl
```

- C'est dans le dossier `ssl` que toutes les configuration se feront

### 1.2 Création de la clé privée

``` Bash
# Clé privée

sudo openssl genrsa -out portail.key 2048
```

- Cette commande créer la clé privé du serveur. Elle déchiffrera les communications en HTTPS (443) des visiteurs.
-  2048 bits est le standard actuel recommandé pour les certificats de services.

### 1.3 Configuration du fichier SAN

``` Bash
# Fichier SAN

sudo nano san.cnf
```

- Le SAN (Subject Alternative Name) est obligatoire car les navigateurs modernes comme Edge et Chrome ignorent le CN et vérifient uniquement ce champ. Sans lui le navigateur affiche "Non sécurisé" même avec un certificat valide.

``` ini
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = portail.ecotech.local
```

- Le format INI : C'est un format de fichier de configuration très ancien et très simple. Il est utilisé par énormément d'outils système car il est lisible par les humains et facile à parser par les machines.

### 1.4 Création de la clé CSR

``` Bash
sudo openssl req -new -key portail.key \
    -out portail.csr \
    -subj "/C=FR/ST=Gironde/L=Bordeaux/O=EcoTech/CN=portail.ecotech.local" \
    -config san.cnf
```
- Les `\` présent dans la commade représente un retour à la ligne, reproduite la commande sur une seul ligne.
- La CSR (Certificate Signing Request) est la demande de signature. Elle contient l'identité du serveur (CN=portail.ecotech.local) et le SAN, mais pas la clé privée. C'est ce fichier qu'on va envoyer à `ECO-BDX-EX12` pour obtenir un certificat signé.

### 1.5 Soumettre la clé CSR dans certsrv

- Depuis **un poste admin**, ouvrir le navigateur :

```
http://10.20.20.15/certsrv
    - Request a certificate
        - Advanced certificate request
            - Submit a certificate request by using a base64...
                - Coller le contenu de portail.csr
                - Certificate Template : Web Server
                - Additional Attributes : laisser vide
                - Submit
```

- Pour afficher le contenu de la CSR à coller :

```bash
cat /etc/apache2/ssl/portail.csr
```

- Copier tout le contenu entre `-----BEGIN CERTIFICATE REQUEST-----` et `-----END CERTIFICATE REQUEST-----` inclus.

### 1.6 Télécharger le certificat signé

```
Page "Certificate Issued"
    - Sélectionner : Base 64 encoded ← obligatoire
    - Download certificate
    - Sauvegarder sous : portail.crt
```

- Choisir **Base 64 encoded** et non DER.
- Apache ne peut pas lire le format DER directement.

### 1.7 Déposer le certificat sur EX07

- Depuis **un poste admin** en PowerShell :

```powershell
scp C:\Users\gx-rogenoud\Downloads\portail.crt infra@10.20.20.7:/etc/apache2/ssl/portail.crt
```

- Vérifier que tous les fichiers sont présents sur le **serveur EX07** :

```bash
ls -lh /etc/apache2/ssl/
```

- Ces fichiers devront être présent :
    - portail.key
    - portail.csr
    - portail.crt
    - san.cnf


### 1.8 Installer le CA AD CS sur EX07

- **EX07** est un serveur Linux. Le **CA AD CS** n'y est pas déployé automatiquement contrairement aux machines Windows du domaine. Sans cette étape, `curl` et les outils Linux ne valident pas le certificat.

- Télécharger le CA depuis certsrv sur **un poste admin** :

```
http://10.20.20.15/certsrv
    - Download a CA certificate, certificate chain, or CRL
        - Encoding method : Base 64
        - Download CA certificate
        - Sauvegarder : ecotech-ca.crt
```

- Envoyer et installer sur EX07 :

- Sur un **poste Admin** :

```powershell
scp C:\Users\gx-rogenoud\Downloads\ecotech-ca.crt infra@10.20.20.7:/tmp/
```

- Sur le **serveur EX07**

```bash
sudo cp /tmp/ecotech-ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
# Doit afficher : 1 added ✅
```

### 1.9 Configurer Apache

```bash
sudo nano /etc/apache2/sites-available/portail.conf
```

```apache
<VirtualHost *:443>
    ServerName portail.ecotech.local
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile    /etc/apache2/ssl/portail.crt
    SSLCertificateKeyFile /etc/apache2/ssl/portail.key

    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
</VirtualHost>
```

- Le port 80 n'est pas configuré car il est bloqué au niveau de pfSense.

Activer les modules et redémarrer Apache :

```bash
sudo a2enmod ssl
sudo a2ensite portail.conf
sudo apache2ctl configtest
sudo systemctl restart apache2
```

### 1.10 Vérification

- Sur le **serveur EX07** :

```bash
curl https://portail.ecotech.local
# Doit retourner le contenu HTML du site
```

- Depuis un navigateur sur **un poste admin** :

```
https://portail.ecotech.local
# La connexion est sécurisée 
```

## 2. Certificat de ECO-BDX-EX12 (pfSense / pare-feu)

### 2.1 Importer le CA AD CS dans pfSense

- pfSense a besoin de connaître le CA AD CS pour valider les certificats signés par lui.
- Le CA AD CS n'a pas de clé privée dans pfSense — il ne peut donc pas signer de certificats en interne. Il sert uniquement à valider.

- Télécharger le CA depuis certsrv sur **un poste admin** :

```
http://10.20.20.15/certsrv
    - Download a CA certificate, certificate chain, or CRL
        - Encoding method : Base 64 ✅
        - Download CA certificate
        - Sauvegarder : ecotech-ca.crt
```

- Ouvrir le fichier avec le bloc-notes, sélectionner tout et copier.

- Sur pfSense :

```
System - Cert Manager - Authorities
    - + Add
        - Descriptive Name : ecotech-ECO-BDX-EX12-CA
        - Method : Import an existing Certificate Authority
        - Certificate data : coller le contenu de ecotech-ca.crt
        - Save
```

### 2.2 Générer la CSR depuis pfSense

- pfSense génère la clé privée en interne et ne la partage jamais.
- On génère uniquement la CSR qu'on envoie à AD CS pour signature.

```
System - Cert Manager - Certificates
    - Add/Sign
        - Method : Create a Certificate Signing Request
        - Descriptive Name : pfsense-web
        - Key type : RSA
        - Key length : 2048
        - Digest Algorithm : SHA256
        - Common Name : pfsense.ecotech.local
        - Certificate Type : Server Certificate
        - Alternative Names :
            - FQDN or Hostname : pfsense.ecotech.local
        - Save
```

### 2.3 Exporter la CSR

```
System - Cert Manager - Certificates
    - Trouver pfsense-web (external · signature pending)
        - Cliquer sur Export CSR ← icône flèche
            - Sauvegarder le fichier .req
```

### 2.4 Faire signer par AD CS

- Ouvrir le fichier `.req` avec le bloc-notes, sélectionner tout et copier.

```
http://10.20.20.15/certsrv
    - Request a certificate
        - Advanced certificate request
            - Coller le contenu du fichier .req
            - Certificate Template : Web Server
            - Additional Attributes : laisser vide
            - Submit
                - Base 64 encoded
                - Download certificate
                - Sauvegarder : certnew.cer
```

### 2.5 Importer le certificat signé dans pfSense

- Ouvrir `certnew.cer` avec le bloc-notes, sélectionner tout et copier.

```
System - Cert Manager - Certificates
    - Trouver pfsense-web (external · signature pending)
        - Cliquer sur éditer
            - Page "Complete Signing Request for pfsense-web"
                - Final certificate data : coller le contenu de certnew.cer
                - Update
```

### 2.6 Appliquer le certificat à l'interface web

```
System - Advanced - Admin Access
    - webConfigurator
        - Protocol : HTTPS (SSL/TLS)
        - SSL/TLS Certificate : pfsense-web
        - Save
```

### 2.7 Corriger la protection DNS Rebind

- pfSense bloque par défaut l'accès via un nom de domaine qui n'est pas dans sa liste d'exceptions. Il faut ajouter le nom DNS de pfSense.

```
System - Advanced - Admin Access
    - Alternate Hostnames
        - Ajouter : pfsense.ecotech.local
        - Save
```

### 2.8 Vérification

- Depuis un navigateur sur **un poste admin** :

```
https://pfsense.ecotech.local
    - La connexion est sécurisée
``` 

## 3. Certification de ECO-BDX-EX15 (Bastion / Guacamole)

### 3.1 Se placer dans le dossier SSL

```bash
cd /opt/guacamole/ssl
```

- C'est dans ce dossier que la clé privée, le fichier SAN et la CSR seront générés.
- Les sous-dossiers `private/` et `certs/` sont déjà créés et montés en volume dans le conteneur nginx.

### 3.2 Création de la clé privée

```bash
openssl genrsa -out private/bastion.key 2048
```

- La clé privée est générée directement dans `private/`, là où nginx la lit via le volume Docker.
- 2048 bits est le standard actuel recommandé pour les certificats de services.

### 3.3 Configuration du fichier SAN

```bash
nano san.cnf
```

```ini
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = bastion.ecotech.local
```

- Le SAN est obligatoire car les navigateurs modernes comme Edge et Chrome ignorent le CN et vérifient uniquement ce champ. Sans lui le navigateur affiche "Non sécurisé" même avec un certificat valide.

### 3.4 Création de la CSR

```bash
openssl req -new -key private/bastion.key -out bastion.csr -subj "/C=FR/ST=Gironde/L=Bordeaux/O=EcoTech/CN=bastion.ecotech.local" -config san.cnf
```

- Commande à saisir sur une seule ligne.
- La CSR contient l'identité du serveur et le SAN, mais pas la clé privée. C'est ce fichier qu'on va envoyer à `ECO-BDX-EX12` pour obtenir un certificat signé.

### 3.5 Soumettre la CSR dans certsrv

- Pour afficher le contenu de la CSR à copier :

```bash
cat /opt/guacamole/ssl/bastion.csr
```

- Copier tout le contenu entre `-----BEGIN CERTIFICATE REQUEST-----` et `-----END CERTIFICATE REQUEST-----` inclus.

- Depuis **un poste admin**, ouvrir le navigateur :

```
http://10.20.20.15/certsrv
    - Request a certificate
        - Advanced certificate request
            - Submit a certificate request by using a base64...
                - Coller le contenu de bastion.csr
                - Certificate Template : Web Server
                - Additional Attributes : laisser vide
                - Submit
```

### 3.6 Télécharger le certificat signé

```
Page "Certificate Issued"
    - Sélectionner : Base 64 encoded ← obligatoire
    - Download certificate
    - Sauvegarder sous : bastion.crt
```

- Choisir **Base 64 encoded** et non DER.
- nginx ne peut pas lire le format DER directement.

### 3.7 Déposer le certificat sur EX15

- Depuis **un poste admin** en PowerShell :

```powershell
scp C:\Certificats\ecotech-ca.crt root@10.50.20.5:/opt/guacamole/ssl/certs/bastion.crt
```

- Vérifier que tous les fichiers sont présents sur le **serveur EX15** :

```bash
ls -lh /opt/guacamole/ssl/private/
ls -lh /opt/guacamole/ssl/certs/
```

- Ces fichiers devront être présents :
    - `private/bastion.key`
    - `certs/bastion.crt`
    - `san.cnf`
    - `bastion.csr`

### 3.8 Installer le CA AD CS sur EX15

- **EX15** est un serveur Linux. Le **CA AD CS** n'y est pas déployé automatiquement contrairement aux machines Windows du domaine. Sans cette étape, les outils Linux ne valident pas le certificat.

- Télécharger le CA depuis certsrv sur **un poste admin** :

```
http://10.20.20.15/certsrv
    - Download a CA certificate, certificate chain, or CRL
        - Encoding method : Base 64
        - Download CA certificate
        - Sauvegarder : ecotech-ca.crt
```

- Envoyer et installer sur EX15 :

- Sur un **poste admin** :

```powershell
scp C:\Certificats\ecotech-ca.crt root@10.50.20.5:/tmp/
```

- Sur le **serveur EX15** :

```bash
cp /tmp/ecotech-ca.crt /usr/local/share/ca-certificates/
update-ca-certificates
# Doit afficher : 1 added 
```

### 3.9 Redémarrer nginx

```bash
cd /opt/guacamole
docker compose restart nginx
```

- nginx recharge les volumes à chaque démarrage — aucune modification du `docker-compose.yml` ni du `nginx.conf` n'est nécessaire. Seul le fichier de certificat a changé.

- Vérifier l'état des conteneurs :

```bash
docker compose ps
```

- Les 4 conteneurs doivent afficher le statut `Up` :
    - `nginx_reverse_proxy`
    - `guacamole`
    - `guacd`
    - `postgres_guacamole`

### 3.10 Vérification

- Depuis un navigateur sur **un poste admin** :

```
https://bastion.ecotech.local/guacamole
    - La connexion est sécurisée
```

## 4. Sécurisation de certsrv (ECO-BDX-EX12 / IIS)

### 4.1 Contexte
- Par défaut, l'interface Web Enrollment certsrv est accessible uniquement en HTTP (http://10.20.20.15/certsrv). Cette section documente la mise en place d'un certificat sur IIS afin d'exposer certsrv en HTTPS via https://certificat.ecotech.local/certsrv.

- La particularité ici est que c'est l'AC elle-même qui signe son propre certificat serveur IIS  ce comportement est normal pour une Root CA.

### 4.2 Créer le dossier de travail

- Sur ECO-BDX-EX12 en PowerShell :

``` powershell
mkdir C:\Certificats
```

### 4.3 Créer le fichier de configuration CSR

``` powershell
notepad C:\Certificats\EX12.inf
```

``` ini
ini[Version]
Signature="$Windows NT$"

[NewRequest]
Subject="CN=certificat.ecotech.local,O=EcoTech,C=FR"
KeyLength=2048
KeyAlgorithm=RSA
HashAlgorithm=SHA256
KeyUsage=0xa0

[Extensions]
2.5.29.17 = "{text}"
_continue_ = "dns=certificat.ecotech.local&"
```

- Le SAN est défini dans la section [Extensions] — c'est la syntaxe propre à certreq sous Windows, différente du format san.cnf utilisé sur Linux.

- Le flag -machine est obligatoire pour que la clé privée soit stockée dans le magasin machine utilisé par IIS.

### 4.4 Générer la CSR

``` powershell
certreq -new -machine C:\Certificats\EX12.inf C:\Certificats\EX12.csr
```

### 4.5 Soumettre la CSR dans certsrv

- Ouvrir C:\Certificats\EX12.csr avec le bloc-notes, sélectionner tout et copier.

``` 
http://10.20.20.15/certsrv
    - Request a certificate
        - Advanced certificate request
            - Coller le contenu de EX12.csr
            - Certificate Template : Web Server
            - Additional Attributes : laisser vide
            - Submit
                - Base 64 encoded
                - Download certificate
                - Sauvegarder : C:\Certificats\certnew.cer
```

### 4.6 Installer le certificat dans le magasin machine

```powershell
certreq -accept -machine C:\Certificats\certnew.cer
```

- Le flag -machine est indispensable — sans lui le certificat est installé dans le magasin utilisateur et IIS ne peut pas accéder à la clé privée.

- Vérifier que le certificat est bien installé :

```powershell
certutil -store -machine "My" | findstr "certificat.ecotech.local"
```

### 4.7 Appliquer le certificat dans IIS

``` Markdown
IIS Manager
    - Sites - Default Web Site
        - Bindings
            - Add
                - Type : https
                - IP address : 10.20.20.15
                - Port : 443
                - Host name : certificat.ecotech.local
                - SSL certificate : certificat.ecotech.local
                - OK
```

### 4.8 Créer l'enregistrement DNS

- Sur ECO-BDX-EX01, ouvrir le Gestionnaire DNS :

``` Markdown
Gestionnaire DNS
    - Zones de recherche directes
        - ecotech.local
            - Nouvel enregistrement A
                - Nom : certificat
                - Adresse IP : 10.20.20.15
                - OK
```

### 4.9 Vérification

- Depuis un navigateur sur un poste admin :

```
https://certificat.ecotech.local/certsrv
    - La connexion est sécurisée
```

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>