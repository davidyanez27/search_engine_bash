#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
 
# Global variables
main_url="https://htbmachines.github.io/bundle.js"

function ctrl_c(){
	echo -e "\n\n[!]${greenColour} Saliendo... ${endColour}\n" 
	tput cnorm && exit 1
}

# Ctrl+c
trap ctrl_c INT

function helpPanel(){
  echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Use the following commands:${endColour}"
  echo -e "\t ${purpleColour}u)${endColour} ${grayColour}download or update necessary data${endColour}"
  echo -e "\t ${purpleColour}m)${endColour} ${grayColour}search for machine by name${endColour}"
  echo -e "\t ${purpleColour}h)${endColour} ${grayColour}show help panel${endColour}"
}

function searchMachine(){
  machineName="$1"
  echo "$machineName"
}

function updateFiles(){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Downloading files...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}All files were downloaded${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Searching for updates...${endColour}"
    sleep 1
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    if $(diff bundle_temp.js bundle.js > /dev/null); then
      echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}no updates, your data is up to date${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}updates applied to the file${endColour}"
      rm bundle.js && mv bundle_temp.js bundle.js
    fi
  
    tput cnorm 
  fi
}

# indicators
declare -i parameter_counter=0

while getopts "m:uh" arg; do
  case $arg in
    m) machineName=$OPTARG ;let parameter_counter+=1;;
    u) parameter_counter+=2;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
else
  helpPanel
fi
