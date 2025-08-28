set sh1 to "launchctl unload -w /Library/LaunchDaemons/br.com.boagestao.BGDesk_service.plist;"
set sh2 to "/bin/rm /Library/LaunchDaemons/br.com.boagestao.BGDesk_service.plist;"
set sh3 to "/bin/rm /Library/LaunchAgents/br.com.boagestao.BGDesk_server.plist;"

set sh to sh1 & sh2 & sh3
do shell script sh with prompt "BGDesk wants to unload daemon" with administrator privileges