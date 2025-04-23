#!/usr/bin/env bash

#check if script is running with root privileges
function check_sudo(){
    if [ "$EUID" -ne 0 ]; then
        printf "\e[1;31m[!] Not running as root.\e[0m"
        printf "\n\n\e[1;34mExiting..\e[0m"
        sleep 1
        exit 1
    fi
}

check_sudo

#check if tor is installed
printf "\e[1;34mChecking if tor is installed...\e[0m"
sleep 1

if ! command -v tor >/dev/null 2>&1; then 
    printf "\n\e[1;31m[!] Tor is not installed.\e[0m\n\n\e[1;34mInstall it using your package manager (e.g apt install tor)\e[0m\n"
    exit 1
else
    printf "\n\n\e[1;32m[+] Tor is already installed\e[0m"
fi

#displaying tor version
version=$(tor --version | head -n1 | awk '{print $3}')
printf "\n\n\e[1;32m[*] Tor version - \e[0m\e[1;35m${version}\e[0m"

sleep 1.5

printf "\e[1;35m\n\n============================================\e[0m"
printf "\e[1;35m\n============================================\e[0m"

#check current ip
current_ip=$(curl -4 -s https://ifconfig.me/ip)
printf "\n\n\e[1;34m[*] Current IP is: \e[0m\e[1;35m${current_ip}\e[0m"

sleep 1.5

systemctl is-active --quiet tor 
tor_active=$?

#check if tor is active
if [ "$tor_active" -eq 0 ]; then
	printf "\n\n\e[1;32mTor is already running\e[0m"
else
	printf "\n\n\e[1;34m[*] Tor is not active, starting...\e[0m"
	systemctl start tor
	sleep 2
fi

printf "\n\n\e[1;37m[user@AutoIpChanger]$ systemctl status tor\e[0m\n\n"
systemctl is-active tor

sleep 2

printf "\e[1;35m\n============================================\e[0m"
printf "\e[1;35m\n============================================\e[0m"

#change of ip in time (s)
printf "\n\n\033[1;33m[>] How often do you want to change your IP? (in seconds), recommended: minimum 10 seconds >> \033[0m"
read time_interval
if ! [[ "$time_interval" =~ ^[0-9]+$ ]] || [[ "$time_interval" -le 0 ]]; then
    printf "\n\e[1;31m[!] \e[0m\e[1;33mInput must be integer and positive number\e[0m"
    exit 1
fi

printf "\n\e[1;33m[*] IP will change once in "$time_interval" second(s)"
printf "\n* To stop script running press Ctrl + C *\e[0m"

while true; do
    tor_ip=$(curl --socks5 127.0.0.1:9050 -4 -s https://icanhazip.com)
    if [ -z "$tor_ip" ]; then
        printf "\n\e[1;31m[!] Error connecting to tor\e[0m"
    else
        printf "\n\e[1;32m[+] New ip $tor_ip\e[0m"
    fi

    systemctl restart tor
    sleep $time_interval
done
