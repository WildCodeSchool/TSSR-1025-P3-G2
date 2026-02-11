# Installation simple de Zabbix 7.0 sur Debian 12 (Proxmox LXC)

**Objectif de ce mini-guide**  
Montrer comment installer **Zabbix 7.0** (logiciel de supervision gratuit et puissant) sur une machine Debian 12 (souvent utilisée dans un conteneur LXC sous Proxmox).

Ce document est fait pour les débutants : on explique **chaque commande** que l’on voit sur les captures d’écran.

Date des captures : février 2026  
Version ciblée : **Zabbix 7.0 LTS** (version longue durée – supportée jusqu’en 2029)

## 📋 Prérequis

- Une machine / conteneur **Debian 12 Bookworm** (Proxmox LXC, VM, serveur dédié…)
- Accès root (ou sudo)
- Connexion internet
- Au moins 2 Go de RAM et 10-20 Go de disque (idéalement plus si vous surveillez beaucoup de machines)

## Étapes montrées dans les captures

### 1. Mise à jour du système (le réflexe de base)

```bash
apt update





























PaquetRôle (en français simple)zabbix-server-mysqlLe cerveau principal de Zabbix (collecte les données)zabbix-frontend-phpL’interface web (ce que tu vois dans ton navigateur)zabbix-apache-confConfiguration Apache pour afficher l’interfacezabbix-sql-scriptsScripts SQL pour créer les tables de la base de donnéeszabbix-agentAgent léger à installer sur les machines que tu veux surveille
