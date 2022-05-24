$startLocation = $pwd

$pshFolder = Split-Path $Profile
. "$pshFolder\DekkCore\Settings.ps1"

$mySqlCommands = @{
    "runSql"   = ".\mysql.exe -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST -e 'SQL_STATEMENT_REPLACEMENT'";
    "console"  = ".\mysql.exe -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST $MYSQL_DB";
    "listDb"   = ".\mysql.exe -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST -e 'show databases' -s --skip-column-names";
    "backupDb" = ".\mysqldump.exe -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST ";
}

$twoUpgradeHeirlooms = @(133595, 133597, 133585, 133596, 133598)
$threeUpgradeHeirlooms = @(105689, 105690, 126948, 126949, 128318, 105685, 105692, 105683, 105688, 105686, 105691, 105684, 105687, 105693, 131733)

function testPrompt() {
    $i = 0
    while ($i -lt 2) {
        Write-Output "Counter = $i"
        $i = askToQuit $i
        $i++
    }
    if ($i -ge 2) {
        Write-Host -ForegroundColor Red "Restarted server $MAX_RESTARTS times, giving up."
    }
    $exitCause = if ($i -eq 2) { "Timed out" } else { "User exit" }
    $host.UI.RawUI.WindowTitle = $exitCause
    return $exitCause
}

function dekkCoreFullBackup {
    foreach ($dbName in $MYSQL_DB_LIST) {
        dekkCoreBackupDb $dbName
    }
}

function dekkCoreBackupDb {
    Param([Parameter(Mandatory = $false, Position = 0)] [string]$dbName)
    Set-Location $MYSQL_LOCATION
    if ($MYSQL_BACKUP_ALLOWED -eq 1) {
        $host.UI.RawUI.WindowTitle = "Backup $dbName"
        rotateBackup $dbName

        Write-Host -ForegroundColor White "Creating new backup for $dbName"
        EnsurePathExists $MYSQL_BACKUP_LOCATION $dbname
        $basefile = "$MYSQL_BACKUP_LOCATION\$dbname\$dbname.sql"
        $backupcmd = $mySqlCommands.backupDb
        $cmd = "$backupcmd $dbName --result-file $basefile"
        Write-Host $cmd
        Invoke-Expression -Command $cmd
    }
    $host.UI.RawUI.WindowTitle = "PowerShell"
    Set-Location $startLocation
}

function rotateBackup($dbName) {
    $basefile = "$MYSQL_BACKUP_LOCATION\$dbname\$dbname.sql"
    Write-Host -ForegroundColor White "Settings allow for $MYSQL_BACKUP_COUNT backups to be saved"

    if ($MYSQL_BACKUP_COUNT -gt 1) {
        for ($i = $MYSQL_BACKUP_COUNT; $i -ge 1; $i--) {
            Write-Host -ForegroundColor White "Backup rotate checking $i"
            $backupfile = "$basefile.$i"
            if (Test-Path $backupFile) {
                if ($i -eq $MYSQL_BACKUP_COUNT) {
                    Write-Host -ForegroundColor DarkYellow "Removing oldest backup: $backupFile"
                    Remove-Item "$backupFile"
                }
                else {
                    $nextBackupNumber = $i + 1
                    Write-Host -ForegroundColor Yellow "Rotating $backupFile to $baseFile.$nextBackupNumber"
                    Move-Item "$backupFile" "$baseFile.$nextBackupNumber"
                }
            }
        }
        if (Test-Path $basefile) {
            if (Test-Path "$basefile.1") {
                Remove-Item "$basefile.1"
            }
            Move-Item "$basefile" "$baseFile.1"
        }
    }
}

function listDatabases() {
    Set-Location $MYSQL_LOCATION
    $host.UI.RawUI.WindowTitle = "MySQL Databases"
    Invoke-Expression -Command $mySqlCommands.listDb
    $host.UI.RawUI.WindowTitle = "PowerShell"
    Set-Location $startLocation
}

function runSqlInDb() {
    Param([Parameter(Mandatory = $true, Position = 0)] [string]$sql)
    Set-Location $MYSQL_LOCATION
    if([string]::IsNullOrEmpty($sql) -ne $true) {
        $foundDbName = 0
        foreach($dbName in $MYSQL_DB_LIST) {
            if($foundDbName -eq 0 -and $sql.Contains("$dbName.")) {
                $foundDbName = 1
            }
        }
        if($foundDbName -eq 0) {
            Write-Host -ForegroundColor Red "ERROR - SQL run from command line must include database names in front of tables"
            Write-Host -ForegroundColor DarkRed "Example: select * from auth.realmlist"
        }
        else {
            $dbCmd = $mySqlCommands.runSql
            $dbCmd = $dbCmd.Replace("SQL_STATEMENT_REPLACEMENT", $sql);
            Invoke-Expression -Command $dbCmd
        }
    }
    Set-Location $startLocation
}

function upgradeHeirlooms() {
    $twoTierIdSql = [string]::Join(", ", $twoUpgradeHeirlooms)
    $threeTierIdSql = [string]::Join(", ", $threeUpgradeHeirlooms)
    $twoAndThreeTierIdSql = [string]::Join(", ", $twoUpgradeHeirlooms + $threeUpgradeHeirlooms)

    $updateFiveTier = "update auth.battlenet_account_heirlooms set flags = 31 where flags != 31 and itemId not in ($twoAndThreeTierIdSql)"
    $updateTwoTier = "update auth.battlenet_account_heirlooms set flags = 3 where flags != 3 and itemId in ($twoTierIdSql)"
    $updateThreeTier = "update auth.battlenet_account_heirlooms set flags = 6 where flags != 6 and itemId in ($threeTierIdSql)"

    runSqlInDb $updateFiveTier
    runSqlInDb $updateTwoTier
    runSqlInDb $updateThreeTier

}

function dbconsole() {
    Set-Location $MYSQL_LOCATION
    $host.UI.RawUI.WindowTitle = "MySQL Console"
    Invoke-Expression -Command $mySqlCommands.console
    $host.UI.RawUI.WindowTitle = "PowerShell"
    Set-Location $startLocation
}

function StartBnetServer() {
    Set-Location $SERVER_LOCATION
    $host.UI.RawUI.WindowTitle = "BattleNetServer"
    $i = 0
    while ($i -lt $MAX_RESTARTS) {
        if ($AUTH_SERVER_TYPE -eq "Auth") {
            & .\authserver.exe
        }
        else {
            & .\bnetserver.exe
        }
        $i = askToQuit $i
        $i++
    }
    HandleExit($i)
}

function StartWorldServer() {
    if($AUTO_UPGRADE_HEIRLOOMS -eq 1) {
        upgradeHeirlooms
    }
    Set-Location $SERVER_LOCATION
    $host.UI.RawUI.WindowTitle = "WorldServer"
    $i = 0
    while ($i -lt $MAX_RESTARTS) {
        & .\worldserver.exe
        $i = askToQuit $i
        $i++
    }
    HandleExit($i)
}


function StartMysql() {
    Set-Location $MYSQL_LOCATION
    $host.UI.RawUI.WindowTitle = "MySQL"
    $i = 0
    while ($i -lt $MAX_RESTARTS) {
        & .\mysqld.exe --console --standalone
        $i = askToQuit $i
        $i++
    }
    HandleExit($i)
}

function askToQuit($counter) {
    if (TimedPrompt "Restarting in $PROMPT_TIMEOUT.  Press Q to quit " $PROMPT_TIMEOUT) {
        $counter = $MAX_RESTARTS + 100
        Write-Host -ForegroundColor Green "Exiting per user request"
    }
    
    return $counter
}

function HandleExit($i) {
    if ($i -gt $MAX_RESTARTS -and $i -lt $MAX_RESTARTS + 100) {
        Write-Host -ForegroundColor Red "Restarted server $MAX_RESTARTS times, giving up."
        $host.UI.RawUI.WindowTitle = "CRASHED"
    }
    else {
        $host.UI.RawUI.WindowTitle = "PowerShell"
    }
}

Function TimedPrompt($prompt, $secondsToWait) {   
    Write-Host -NoNewline $prompt
    $secondsCounter = 0
    $subCounter = 0
    $QuitKey = 81

    While ( $secondsCounter -lt $secondsToWait) {
        if ($host.UI.RawUI.KeyAvailable) {
            $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
            if ($key.VirtualKeyCode -eq $QuitKey) {
                break
            }
        }
        start-sleep -m 10
        $subCounter = $subCounter + 10
        if ($subCounter -eq 1000) {
            $secondsCounter++
            $subCounter = 0
            Write-Host -NoNewline "$secondsCounter ... "
        }       
        If ($secondsCounter -eq $secondsToWait) { 
            Write-Host "`r`n"
            return $false;
        }
    }
    Write-Host "`r`n"
    
    return $true;
}

function DelayRun($seconds, $service) {
    Write-Host -ForegroundColor DarkYellow "Waiting $seconds seconds for $service to start up"
    Start-Sleep 10
}

function EnsurePathExists($path, $name) {
    if (Test-Path "$path\$name") {
        Write-Host -ForegroundColor DarkGray "$path\$name already exists"
    }
    else {
        Write-Host -ForegroundColor DarkYellow "Creating $path\$name"
        New-Item -Path $path -Name $name -ItemType "directory"
    }
}