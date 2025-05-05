#!/usr/bin/env bash

function scan_ports(){
    found_port=0

    for ((port=$MIN_PORT; port<=$MAX_PORT; port++)); do
        if nc -zv $host $port &>/dev/null; then
            service_name=$(getent services $port | awk '{print $1}' | cut -d'/' -f1)
            if [ -z "$service_name" ]; then
                service_name="unknown"
            fi
            echo -e "\t\t   [+] Port $port $service_name is open"
            found_port=1
        fi
    done
    echo -e "\n"

    if [ "$found_port" -eq 0 ]; then
        echo -e "\n\e[1;33mNo open ports found in range $MIN_PORT-$MAX_PORT. Try increasing the port range.\e[0m\n"
    fi
}

function ping_target(){
    if ping -c 1 $host &> /dev/null; then
        echo -e "\n\t\e[1;32m#############################################\e[0m"
        echo -e "\t\e[1;32m#           Host is up. Scanning...         #\e[0m"
        echo -e "\t\e[1;32m#############################################\e[0m\n"
    else
        echo -e "\n\e[1;31mERROR: host is down\e[0m\n"
        exit 1
    fi
}

function get_help_menu(){
    echo "Usage: $0 <host> <MIN_PORT> <MAX_PORT>"
    exit 1
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    get_help_menu
fi

host=$1
MIN_PORT=$2
MAX_PORT=$3

if [ -z "$host" ] || [ -z "$MIN_PORT" ] || [ -z "$MAX_PORT" ]; then
    echo -e "\n\e[1;31mERROR: At least 1 of your inputs is missing\e[0m\n"
    get_help_menu
    exit 1
fi

if ! [[ "$MIN_PORT" =~ ^[0-9]+$ ]] || ! [[ "$MAX_PORT" =~ ^[0-9]+$ ]]; then
    echo -e "\n\e[1;31mERROR: MIN_PORT and MAX_PORT must be valid positive integers.\e[0m\n"
    exit 1
fi

if [ $MIN_PORT -ge $MAX_PORT ]; then
    echo -e "\n\e[1;31mYour MIN_PORT $MIN_PORT cannot be equal to or greater than MAX_PORT $MAX_PORT\e[0m\n"
    exit 1
fi

if [[ "$host" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
    IFS="." read -r part1 part2 part3 part4 <<< "$host"
    
    if [[ "$part1" -ge 0 && "$part1" -le 255 ]] && \
       [[ "$part2" -ge 0 && "$part2" -le 255 ]] && \
       [[ "$part3" -ge 0 && "$part3" -le 255 ]] && \
       [[ "$part4" -ge 0 && "$part4" -le 255 ]]; then
        ping_target
        scan_ports
    else
        echo -e "\n\e[1;31mERROR: Each part of the IP address must be between 0 and 255\e[0m\n"
        exit 1
    fi
else
    echo -e "\n\e[1;31mERROR: IP needs to be in format X.X.X.X where X is integer between 0 and 255\e[0m\n"
    exit 1
fi

