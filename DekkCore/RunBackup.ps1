$pshFolder = Split-Path $Profile
Set-Location "$pshFolder\DekkCore"
. ".\ServerCommands.ps1"

dekkCoreFullBackup