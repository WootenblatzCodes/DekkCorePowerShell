param($forceRun)

# This file is called library.ps1 because I thought calling it
# install.ps1 would confuse people.  
cls

Write-Host -ForegroundColor DarkGreen  "Install DekkCore Powershell Scripts?"
if([string]::IsNullOrEmpty($forceRun)) {
    $run = Read-Host "Type Y or N "
}
else {
    $run = "y"
}
if($run -eq "y") {

    $currentDir = $pwd
    $docFolder = "$env:USERPROFILE\Documents"
    $startupFolder = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    $ErrorActionPreference = 'SilentlyContinue'
    $code = (get-command code.cmd).Path.Replace(' ', '` ')
    $notepad = (get-command notepad.exe).Path.Replace(' ', '` ')
    $ErrorActionPreference = 'Inquire'

    $pshProfile = $Profile
    $pshFolder = Split-Path $Profile
    Write-Host -ForegroundColor DarkGray "Powershell folder is located at $pshFolder"

    if (Test-Path $pshFolder) {
        Write-Host -ForegroundColor DarkBlue "PowerShell script folder exists."
    }
    else {
        Write-Host -ForegroundColor Yellow "PowerShell script folder does not exist, creating it."
        New-Item -Path $pshFolder -Name "DekkCore" -ItemType "directory"
    }

    Write-Host -ForegroundColor Green "Copying DekkCore folder to"
    Write-Host -ForegroundColor Cyan $pshFolder
    Copy-Item -Path "$currentDir\DekkCore\*.ps1" -Destination "$pshFolder\DekkCore" -Recurse -Force
    $fileList = Get-ChildItem -Path "$pshFolder\DekkCore" | Where-Object { $_.PSIsContainer } | Select-Object Name,FullName
    Write-Host -ForegroundColor DarkGray $fileList

    Write-Host -ForegroundColor DarkBlue "Copying startup commands to $startupFolder"
    Write-Host -ForegroundColor Cyan $startupFolder
    Copy-Item -Path "$currentDir\Autostart Commands\*.cmd" -Destination $startupFolder  -Force

    Write-Host -ForegroundColor DarkBlue "Copying backup cmd to Documents"
    Copy-Item -Path "$currentDir\Task Scheduler Commands\DekkCoreBackup.cmd" -Destination "$docFolder" -Force

    # If we're running on an older version of powershell, try to use that path for the cmd files.
    if(!$pshFolder.Contains("WindowsPowerShell")) {
        (Get-Content "$startupFolder/001-StartMysql.cmd") -Replace 'WindowsPowershell', 'PowerShell' | Set-Content "$startupFolder/001-StartMysql.cmd"
        (Get-Content "$startupFolder/002-StartBnetserver.cmd") -Replace 'WindowsPowershell', 'PowerShell' | Set-Content "$startupFolder/002-StartBnetserver.cmd"
        (Get-Content "$startupFolder/003-StartWorldserver.cmd") -Replace 'WindowsPowershell', 'PowerShell' | Set-Content "$startupFolder/003-StartWorldserver.cmd"
        (Get-Content "$docFolder/DekkCoreBackup.cmd") -Replace 'WindowsPowershell', 'PowerShell' | Set-Content "$docFolder/DekkCoreBackup.cmd"
    }

    $profileExists = Test-Path $pshProfile

    if($profileExists)
    {
        $profileAlreadySetup = Select-String -Path $pshProfile -Pattern "ServerCommands"
    }

    if ( $profileExists -and $profileAlreadySetup )
    {
        Write-Host -ForegroundColor DarkBlue "ServerCommands.ps1 is already in your Powershell Profile, skipping this step."
    }
    else {
        Write-Host -ForegroundColor Green "Do you want to add ServerCommands to your Powershell Profile?"
        $updateProfile = Read-Host "Type Y or N: "
        if($updateProfile -eq "y") {
            if($profileExists)
            {
                Copy-Item -Path $pshProfile -Destination "_Psh_Profile_ps1.backup" -Force
            }
            $srvCmd = ". $pshFolder\DekkCore\ServerCommands.ps1"
            Add-Content $pshProfile $srvCmd
        }
    }

    Write-Host -ForegroundColor Green "Do you want to edit the DekkCore Powershell settings file?"
    $updateSettings = Read-Host "Type Y or N: "
    if($updateSettings -eq "y") {
        if (![string]::IsNullOrEmpty($code)) {
            Invoke-Expression "& $code $pshFolder\DekkCore\Settings.ps1"
        }
        else {
            Invoke-Expression "& $notepad $pshFolder\DekkCore\Settings.ps1"
        }
    }

    Write-Host -ForegroundColor DarkGreen "All Done!"
    Write-Host -ForegroundColor White "Next time this machine restarts DekkCore will run automatically after you sign in."
    Write-Host -ForegroundColor DarkGray "Start up scripts load after a brief delay."
}
else {
    Write-Host -ForegroundColor DarkRed "Exiting per user request."
}