$pshFolder = Split-Path $Profile
Set-Location "$pshFolder\DekkCore"
. ".\ServerCommands.ps1"
DelayRun 10 "MySQL"
StartBnetServer