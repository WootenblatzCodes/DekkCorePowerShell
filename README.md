# DekkCore Powershell
## What is the purpose of these files?

I created these scripts to automatically run DekkCore each time my windows virtual machine starts up.  When an application is run by these scripts it will automatically restart after a crash.  

The auto-restart behavior is configurable.  By default the script will only restart a service 25 times before giving up.  In between crashes there is a configurable wait period where you can hit **Q** to exit the auto-restart process. 

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

The *Autostart Commands* folder has three .CMD files that you can put in your Windows startup folder to automatically run your server when you sign in to windows.

You can find your Startup folder by pasting the following into the address bar of File Explorer:

    %USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

Copy and paste the three CMD files into this folder to autostart the server applications after Windows restarts.

**Powershell files**

`Settings.ps1` - Edit this file to configure the location of your server with the $SERVER_LOCATION variable.  The other defaults should be acceptable for an uncustomized DekkCore installation.  

`ServerCommands.ps1` - Contains powershell functions for the run scripts.  You can also source this file in a PowerShell window to gain access to commands to manually run the servers or quickly open a MySQL console.

    To make ServerCommands available in a normal PowerShell window, paste the following:

    . .\%USERPROFILE%\Documents\PowerShell\DekkCore\ServerCommands.ps1

    You could also add the above line into your PowerShell Profile located at

    %USERPROFILE%\Documents\Powershell\Profile.ps1

`RunMysql.ps1` - This starts the database

`RunBnetserver.ps1` - This starts the BattleNet application

`RunWorldserver.ps1` - This starts the Worldserver application
