# DekkCore Powershell
## What does it do?

I created these scripts to automatically run DekkCore each time my windows virtual machine starts up.  When an application is run by these scripts it will automatically restart after a crash.  

The auto-restart behavior is configurable.  By default the script will only restart a service 25 times before giving up.  In between crashes there is a configurable wait period where you can hit **Q** to exit the auto-restart process. 

This project also comes with commands that can back up your server's MySQL database, run ad-hoc sql querys from the command line, upgrade heirlooms to max level and more.  See the [Other Commands](#OtherCommands) section for more information.

---

## Installation

1. Double click `Install.cmd` to start the automatic installation process.  
2. When prompted type Y or N to include ServerCommands.ps1 in the default PowerShell profile script.
3. When prompted type Y or N to edit the Settings.ps1 file.  This is where you'll set the $SERVER_LOCATION variable that points to the location of your DekkCore install.

This was tested heavily with newer versions of PowerShell.  I've attempted to support older releases that have a different script location but did not test that as much.

---

## What if I do not use DekkCore or I'm using an older server project?

Server admins using Trinity Core or some other variant should be able to use these tools with no problems as long as you make sure to update the names of the databases in Settings.ps1.  

If you're on an older project, such as 3.3.5a most of these tools will work.  Given that there is not a Bnetserver.exe in those projects, I've added an option in Settings.ps1 that lets you set the `$AUTH_SERVER_TYPE` to Bnet or Auth.  If you set it to Auth, the system will run authserver.exe instead of bnetserver.exe.

While the database backup functionality should work universally as long as the database names are correct, any commands that interact with database records may be subject to release specific support.  

---

## How can I make all PowerShell security warnings go away?

Because PowerShell can tell that you got these scripts from the internet, you'll have to unblock them. Changing the ExecutionPolicy with an Administrator account will not always make them stop showing up.  

Open a PowerShell window and paste the following:

```
Unblock-File -Path $env:USERPROFILE\Documents\WindowsPowerShell\DekkCore\*.ps1
```

---

## Manual Installation
1. In File explorer paste `%USERPROFILE%\Documents\` into the address bar to open your documents folder.
   * If you do not have a folder called `WindowsPowerShell`, create that now. 
   * If there is already WindowsPowerShell folder, move to step 2.
2. Copy the `DekkCore` folder into `%USERPROFILE%\Documents\WindowsPowerShell\`
3. Open a new File Explorer window by holding down the start key on your keyboard and tapping E (`WINKEY+E`)
4. Paste `%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup` into the address bar to open the Startup folder
5. In the original File Explorer Window, select the three .CMD files from `DekkCore\Autostart Commands` and copy them into the Startup folder.
6. Edit `%USERPROFILE%\Documents\WindowsPowerShell\DekkCore\Settings.ps1` and make sure the value assigned to `$SERVER_LOCATION` points to your DekkCore server directory.


---

## What's included?

**Autostart Commands**

The *Autostart Commands* folder has three .CMD files that are copied into your Windows startup folder.  This will automatically run your server when you sign in to windows.  Each CMD file exists to execute the corresponding Powershell script to start a given service.

**Task Scheduler Commands**

There is a single task scheduler .CMD file that you can use to backup your database on a schedule.  Task Scheduler comes with windows and is located in Windows Administrative Tools.  [Learn about using Task Scheduler](https://www.google.com/search?q=how+to+schedule+a+task+windows).

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

---

### How can I use the ServerCommands if my Profile isn't loading automatically?
Open powershell, source your profile with `. $PROFILE` and then type `dbconsole` to automatically open MySQL with a connection to the *auth* database.

```
PS C:\Server> . $PROFILE
```

---

### How can I run the dbconsole command?

Open powershell, source your profile with `. $PROFILE` and then type `dbconsole` to automatically open MySQL with a connection to the *auth* database.

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

---
<a name="OtherCommands"></a>
## Other commands available 
`StartMysql` - Runs the database manually

`StartBnetServer` - Runs the BnetServer manually

`StartWorldServer` - Runs the WorldServer manually

Running commands manually includes the same crash protection as the automated startup method.

**Database Commands**
- `dekkCoreBackupDb dbName` will back up a single database where dbName is auth, world, hotfixes or characters.
- `dekkCoreFullBackup` will backup all four databases.
- `upgradeHeirlooms` will upgrade all heirlooms for existing users to max level for both 5 tier and 3 tier upgrade items.
- `runSqlInDb "SQL STATEMENT"` will execute your SQL statement to the command line.  Be sure to prefix table names with the database that table is in, for instance "select * from realmlist" should be written as "select * from auth.realmlist".  Failure to prefix a db name will cause an error.

In Settings.ps1 you can set `$MYSQL_BACKUP_BEFORE_WORLDSERER_RUNS = 1` to enable running a full backup before the Worldserver starts after a reboot. As database backups take some time, the worldserver delay run of 20 seconds does not occur. 

Set `$AUTO_UPGRADE_HEIRLOOMS = 1` to upgrade heirlooms before the worldserver starts.  Because of how the server loads this data, updating it in the db while the server is running usually does not work without a reload.  Prior to starting the worldserver is an ideal location to make this change take place automatically.
