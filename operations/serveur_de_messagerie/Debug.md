# Dépannage iRedMail (Problèmes les plus fréquents)

Ce guide couvre les **bugs et erreurs** les plus courants **pendant l'installation** et **après** sur Debian.

## 1. Avant tout : les 3 règles d’or pour éviter 90 % des problèmes
- Installez toujours sur un **serveur frais / clean** (pas de Postfix/Exim/Dovecot/MySQL pré-installés).
- Exécutez en tant que **root**.
- Lisez **toute** la sortie du script – les erreurs sont souvent affichées en rouge clair.

## 2. Commandes de diagnostic de base (exécutez toujours en premier)

```bash
# Services critiques
systemctl status --no-pager postfix dovecot amavis-new nginx mariadb fail2ban

# Ports en écoute ?
ss -ltnp | grep -E ':25|:465|:587|:993|:995|:80|:443'

# Logs mail en temps réel (indispensable !)
tail -f /var/log/mail.log

# Logs installation (si échec pendant setup)
cat /root/iRedMail-*/*.log   # ou ls -l /root/iRedMail-*
```
