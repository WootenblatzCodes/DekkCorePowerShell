# DekkCore Powershell
## What is the purpose of these files?

I created these scripts to automatically run DekkCore each time my windows virtual machine starts up.  When an application is run by these scripts it will automatically restart after a crash.  

The auto-restart behavior is configurable.  By default the script will only restart a service 25 times before giving up.  In between crashes there is a configurable wait period where you can hit **Q** to exit the auto-restart process. 

---

## Installation

1. Double click `Install.cmd` to start the automatic installation process.  
2. When prompted type Y or N to include ServerCommands.ps1 in the default PowerShell profile script.
3. When prompted type Y or N to edit the Settings.ps1 file.  This is where you'll set the $SERVER_LOCATION variable that points to the location of your DekkCore install.

This was tested heavily with newer versions of PowerShell.  I've attempted to support older releases that have a different script location but did not test that as much.

---

## Manual Installation
1. In File explorer paste `%USERPROFILE%\Documents\` into the address bar to open your documents folder.
   * If you do not have a folder called `PowerShell`, create that now. 
   * If there is already PowerShell folder, move to step 2.
2. Copy the `DekkCore` folder into `%USERPROFILE%\Documents\PowerShell\`
3. Open a new File Explorer window by holding down the start key on your keyboard and tapping E (`WINKEY+E`)
4. Paste `%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup` into the address bar to open the Startup folder
5. In the original File Explorer Window, select the three .CMD files from `DekkCore\Autostart Commands` and copy them into the Startup folder.
6. Edit `%USERPROFILE%\Documents\PowerShell\DekkCore\Settings.ps1` and make sure the value assigned to `$SERVER_LOCATION` points to your DekkCore server directory.


---

## What's included?

**Autostart Commands**

The *Autostart Commands* folder has three .CMD files that are copied into your Windows startup folder.  This will automatically run your server when you sign in to windows.  Each CMD file exists to execute the corresponding Powershell script to start a given service.

**Powershell files**

`Settings.ps1` - Edit this file to configure the location of your server with the $SERVER_LOCATION variable.  The other defaults should be acceptable for an uncustomized DekkCore installation.  

`ServerCommands.ps1` - Contains powershell functions for the run scripts.  You can also source this file in a PowerShell window to gain access to commands to manually run the servers or quickly open a MySQL console.

`RunMysql.ps1` - This starts the database.  This runs immediately.

`RunBnetserver.ps1` - This starts the BattleNet application. This waits 10 seconds before running to give the database time to start.

`RunWorldserver.ps1` - This starts the Worldserver application.  This waits 20 seconds before running, to give the database and BnetServer time to start.

Delayed start occurs only the first time a script executes.  

---

### Why would I want ServerCommands.ps1 in my Powershell profile?

ServerCommands.ps1 is the brain of this project.  In addition to handling restarting crashed applications, prompting to quit between crashes, and managing the title of each PowerShell window, it makes the core functions available to call in any PowerShell window that has sourced the file.

As an example, you can open powershell, source your profile with `. $PROFILE` and then type `dbconsole` to automatically open MySQL with a connection to the *auth* database.

```
PS C:\Server> . $PROFILE
PS C:\Server> dbconsole
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 19
Server version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

### Other commands available 
`StartMysql` - Runs the database manually

`StartBnetServer` - Runs the BnetServer manually

`StartWorldServer` - Runs the WorldServer manually

Running commands manually includes the same crash protection as the automated startup method.