$pshFolder = Split-Path $Profile
Set-Location "$pshFolder\DekkCore"
. ".\ServerCommands.ps1"
DelayRun 20 "MySQL and Bnet Server"
StartWorldServer