# Set this to the location of your bnetserver.exe and worldserver.exe
$SERVER_LOCATION = "c:\Server"

# Each service will be restarted $MAX_RESTARTS times before giving up
$MAX_RESTARTS = 25

# When a service exits, you have $PROMPT_TIMEOUT seconds to hit Q before it restarts
$PROMPT_TIMEOUT = 5

# Supply MYSQL credentials to open database console with 'dbconsole' in PowerShell
$MYSQL_USER = "root"
$MYSQL_PASS = "admin"
$MYSQL_DB = "auth"
$MYSQL_HOST = "127.0.0.1"

# If you're using this with an older project that runs authserver.exe,
# comment out the line below and uncomment the Auth line
$AUTH_SERVER_TYPE = "Bnet"
#$AUTH_SERVER_TYPE = "Auth"

# You do not need to change this
$MYSQL_LOCATION = [string]::Join("\", $SERVER_LOCATION, "Data", "MySQL", "bin")