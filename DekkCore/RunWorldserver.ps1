$pshFolder = Split-Path $Profile
Set-Location "$pshFolder\DekkCore"
. ".\ServerCommands.ps1"
if ($MYSQL_BACKUP_BEFORE_WORLDSERER_RUNS -eq 1) {
    dekkCoreFullBackup
}
else {
    DelayRun 20 "MySQL and Bnet Server"
}
StartWorldServer