DHCP installation
-----

DHCP GUI

1. Sur le serveur manager cliquer sur "Add Roles and features"
![image]()


2. Cliquer sur next
![image]()




3. Laisser par default cliquer sur next
![image]()




4. Cliquer sur "Select a server from the server pool, cliquer sur Next
![image]()




5. Cochez la case "DHCP Server"
![image]()




6. Cliquer sur "Add features"
![image]()




7. Cliquer "Next"
![image]()




8. Cliquer "Next"
![image]()




9. Cliquer "Close"
![image]()




Votre installation DHCP terminé


----
DHCP CORE 

1.Pour installer le rôle DHCP taper la commande :

    Install-WindowsFeature DHCP -IncludeManagementTools

2. Pour Afficher le rôle DHCP taper la commande : 
 
       Install-WindowsFeature DHCP -IncludeManagementTools
