#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m'
BOLD='\033[1m'


cur_dir=$(pwd)
if [[ $EUID -ne 0 && $(hostname) != "localhost" && $(hostname) != "127.0.0.1" ]]; then
  echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n"
  exit 1
fi

install_jq() {
    if ! command -v jq &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            apt-get update
            apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}


menu(){
    install_jq
    clear
    
    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    # Fetch server country using ip-api.com
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')
    
    # Fetch server isp using ip-api.com
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')

    Docker_CORE=$(check_docker_installed)

    
echo "*---------------------------------------------------------------------------------------------*"
echo "|  _____   _____    _____     ____     _____   _  __  ______   _____                          |"
echo "| |_   _| |  __ \  |  __ \   / __ \   / ____| | |/ / |  ____| |  __ \                         |"
echo "|   | |   | |__) | | |  | | | |  | | | |      | ' /  | |__    | |__) |                        |"
echo "|   | |   |  _  /  | |  | | | |  | | | |      |  <   |  __|   |  _  /   @ALEFBEMEDIA          |"
echo "|  _| |_  | | \ \  | |__| | | |__| | | |____  | . \  | |____  | | \ \   join telegram channel |"
echo "| |_____| |_|  \_\ |_____/   \____/   \_____| |_|\_\ |______| |_|  \_\                        |"
echo "*---------------------------------------------------------------------------------------------*"
    echo -e "|${GREEN}Server Country    |${NC} $SERVER_COUNTRY"
    echo -e "|${GREEN}Server IP         |${NC} $SERVER_IP"
    echo -e "|${GREEN}Server ISP        |${NC} $SERVER_ISP"
    echo -e "|${GREEN}Server Docker     |${NC} $Docker_CORE"
    echo "*---------------------------------------------------------------------------------------------*"
    echo -e "|${YELLOW}Please choose an option:${NC}"
    echo "*---------------------------------------------------------------------------------------------*"
    echo -e $1
    echo "*---------------------------------------------------------------------------------------------*"
    echo -e "\033[0m"
}


loader(){
    
    menu "| 1  - Install Docker (method 1) ${YELLOW}${BOLD}Slow / Recommended ✅${NC} \n|\n| 2  - Install Docker (method 2) ${YELLOW}${BOLD}Fast / NOT Recommended ⚠️${NC} \n|\n| 0  - Exit"
    
    read -p "Enter option number: " choice
    case $choice in
        1)
            install_command_1
        ;;
        2)
            install_command_2
        ;;
        0)
            echo -e "${GREEN}Exiting program...${NC}"
            exit 0
        ;;
        *)
            echo "Not valid"
        ;;
    esac
    
}

install_command_1(){

    # disable systemd-resolved and set dns
    systemctl stop systemd-resolved
    systemctl disable systemd-resolved
    bash -c 'echo -e "nameserver 178.22.122.100\nnameserver 185.51.200.2" > /etc/resolv.conf'

    # Install Requirements
    apt-get update; apt-get upgrade -y; apt-get install curl socat git -y

    # python installer
    rm install.py
    wget https://raw.githubusercontent.com/AlefbeMedia/irDocker/refs/heads/main/install.py
    python3 install.py
    rm install.py

    # Check Docker version
    docker --version

    # set back dns
    systemctl enable systemd-resolved
    systemctl start systemd-resolved
    bash -c 'echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf'
}

install_command_2(){

    # Install Requirements
    apt-get update; apt-get upgrade -y; apt-get install curl socat git -y

    # snap check
    if ! command -v snap &> /dev/null; then
        echo "snapd is not installed. Installing snapd..."
        apt install snapd
    fi

    # disable systemd-resolved and set dns
    systemctl stop systemd-resolved
    systemctl disable systemd-resolved
    bash -c 'echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf'
    
    # Install Docker using snap
    echo "Installing Docker using snap..."
    snap install docker

    # Check Docker version
    docker --version

    # set mirror list docker
    bash -c 'cat > /var/snap/docker/current/config/daemon.json <<EOF
{
  "insecure-registries" : ["https://docker.arvancloud.ir"],
  "registry-mirrors": ["https://docker.arvancloud.ir"]
}
EOF'

    # restart docker 
    snap restart docker

    # set back systemd-resolved
    systemctl enable systemd-resolved
    systemctl start systemd-resolved

}

check_docker_installed() {
  if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker is installed.${NC}"
  else
    echo -e "${RED}❌ Docker is not installed.${NC}"

  fi
}
loader
