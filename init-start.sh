#!/bin/bash

# Import config variables
source config

#############
# Functions
#############
function install_system {
    echo -e "\n${green_back}Installing ${bold}$system...${reset}"

    echo $1
    (cd ./systems; git clone https://github.com/djulitro/$1.git)

    # Esperar hasta que el repositorio haya sido clonado
    while [ ! -d "./systems/$1" ]; do
        sleep 1  # Espera 1 segundo antes de volver a comprobar
    done

    (cd ./systems/$1; git checkout $branch)
    (cd ./systems/$1; git config core.fileMode false)

    if [ $1 = "gymbro-backend" ] || [ $1 = "gymbro-frontend" ]; then
        cp ./systems/$1/.env.example ./systems/$1/.env
    fi

    update_alias $1
}

function update_alias {
    # Create alias.
    echo "alias ${1}='sudo docker exec -it ${1}'" >> ~/.bash_aliases
    echo -e "${green_bold}${1}${reset} ${green}alias updated.${reset}"
}

function system_is_real {
    if [[ ! " ${systems[*]} " =~ " ${system} " ]]; then
        echo -e "\n${green_bold}$system${reset} ${red}doesn't exists.${reset}"
        return 0
    else
        return 1
    fi
}

###################
# Starting point
###################
# Menu
echo -e "\nHi traveler, first of all... ${bold}do you need sudo with docker-compose?${reset}"
printf "yes or no: "
read -r sudoAnswer

set_sudo $sudoAnswer

echo -e "\nOk, what do you want to do?"
echo -e "${bold}1) Install a system"
echo -e "2) Update aliases"
printf "Choose: "
read -r option

# # Execute option selected

if [ $option -ge 1 ]; then
    echo -e "\nSystems available: ${green_bold}${systems[*]}${reset}"
    printf "Choose (eg. gymbro-backend gymbro-frontend): "
    read -r chosenSystems
    echo -e "\n"

    for system in $chosenSystems
        do
            if system_is_real $system; then
                continue;
            fi

            if [ $option == 1 ]; then
                # Check if the folder is empty. If the folder has files, then the software will not be installed.
                if [ $(ls "./systems/$system" | wc -l) -gt 0 ]; then
                    echo -e "\n${green_bold}$system ${orange}folder not empty.${reset} Delete the folder to re install."
                    continue;
                fi

                install_system $system
            else
                # Check if folder exists.
                if [ ! -d "./systems/$system" ]; then
                    echo -e "\n${green_bold}$system${reset} is ${orange}not installed.${reset}"
                    continue;
                fi

                if [ $option == 2 ]; then
                    update_alias $system
                fi
            fi
        done
else
    echo -e "${red_bold}\nChoose a valid option please.${reset}"
    exit 1
fi
