#!/bin/bash
clear
osdata=$(hostnamectl | grep 'Operating System')
osver=${osdata##*: }
kerneldata=$(hostnamectl | grep 'Kernel')
kernelver=${kerneldata##*: }
ipaddr=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
uptimedata=$(uptime -p)
uptimeinfo=${uptimedata##*up }

echo '-------------- I Broke It ---------------'
echo '# System Information'
echo ''
echo "# Hostname     : $(hostname -s)"
echo "# IP Address   : $ipaddr"
echo "# Current User : $(whoami)"
echo ''
echo "# OS           : $osver    "
echo "# Kernel       : $kernelver"
echo "# System Time  : $(date)"
echo "# Uptime       : $uptimeinfo"
echo ''
echo '------ Unauthorized use is prohibited ------'