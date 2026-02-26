# Installation du rôle WSUS

**Les étapes à suivre :**
    
  1. Ouvrer le **Gestionnaire de serveur**.
  2. Cliquer sur **Ajouter des rôles et des fonctionnalités**.
  3. Cocher le rôle **Services de mise à jour Windows Server (WSUS)**. Il va automatiquement ajouter les dépendances requises (comme le serveur web IIS).

		![image](install_1)

  4. Lors de l'étape "Services de rôle", laisser cochés **WID Connectivity** et **WSUS Services**.

		![image](install_2)

  5. À l'étape "Sélectionner l'emplacement du contenu", cocher la case pour stocker les mises à jour (localement ou non) et indiquer le chemin (par exemple `D:\WSUS`).

		![image](install_3)

Une fois l'installation terminée, une notification dans le Gestionnaire de serveur avec un lien cliquable : **"Lancer les tâches de post-installation"**. Cliquer dessus pour que WSUS crée sa base de données et ses dossiers.
