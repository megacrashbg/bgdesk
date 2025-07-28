set sh1 to "launchctl unload -w /Library/LaunchDaemons/com.thinksoft.BGDesk_service.plist;"
set sh2 to "/bin/rm /Library/LaunchDaemons/com.thinksoft.BGDesk_service.plist;"
set sh3 to "/bin/rm /Library/LaunchAgents/com.thinksoft.BGDesk_server.plist;"

set sh to sh1 & sh2 & sh3
do shell script sh with prompt "BGDesk want to unload daemon" with administrator privileges