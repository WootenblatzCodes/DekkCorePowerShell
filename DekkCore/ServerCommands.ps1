$pshFolder = Split-Path $Profile
. "$pshFolder\DekkCore\Settings.ps1"

function testPrompt() {
    $i = 0
    while ($i -lt 2) {
        Write-Output "Counter = $i"
        $i = askToQuit $i
        $i++
    }
    if($i -ge 2) {
        Write-Host -ForegroundColor Red "Restarted server $MAX_RESTARTS times, giving up."
    }
    $exitCause = if ($i -eq 2) { "Timed out"  } else { "User exit"}
    $host.UI.RawUI.WindowTitle = $exitCause
    return $exitCause
}

function dbconsole() {
    Set-Location $MYSQL_LOCATION
    $host.UI.RawUI.WindowTitle = "MySQL Console"
    $run = ".\mysql.exe -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST $MYSQL_DB"
    Invoke-Expression -Command $run
    $host.UI.RawUI.WindowTitle = "PowerShell"
}

function StartBnetServer() {
    Set-Location $SERVER_LOCATION
    $host.UI.RawUI.WindowTitle = "BattleNetServer"
    $i = 0
    while ($i -lt $MAX_RESTARTS) {
        if($AUTH_SERVER_TYPE -eq "Auth")
        {
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
    if(TimedPrompt "Press Q to quit" $PROMPT_TIMEOUT) {
        $counter = $MAX_RESTARTS + 100
        Write-Host -ForegroundColor Green "Exiting per user request"
    }
    
    return $counter
}

function HandleExit($i) {
    if($i -gt $MAX_RESTARTS -and $i -lt $MAX_RESTARTS + 100) {
        Write-Host -ForegroundColor Red "Restarted server $MAX_RESTARTS times, giving up."
        $host.UI.RawUI.WindowTitle = "CRASHED"
    }
    else {
        $host.UI.RawUI.WindowTitle = "PowerShell"
    }
}

Function TimedPrompt($prompt,$secondsToWait){   
    Write-Host -NoNewline $prompt
    $secondsCounter = 0
    $subCounter = 0
    $QuitKey = 81

    While ( $secondsCounter -lt $secondsToWait) {
        if($host.UI.RawUI.KeyAvailable) {
            $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
            if($key.VirtualKeyCode -eq $QuitKey) {
                break
            }
        }
        start-sleep -m 10
        $subCounter = $subCounter + 10
        if($subCounter -eq 1000)
        {
            $secondsCounter++
            $subCounter = 0
            Write-Host -NoNewline "."
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