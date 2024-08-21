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
  echo -e "\t ${purpleColour}d)${endColour} ${grayColour}search for machine by difficulty${endColour}"
  echo -e "\t ${purpleColour}o)${endColour} ${grayColour}search for machine by operative systems${endColour}"
  echo -e "\t ${purpleColour}s)${endColour} ${grayColour}search for machine by skill${endColour}"
  echo -e "\t ${purpleColour}i)${endColour} ${grayColour}search for machine by IP${endColour}"
  echo -e "\t ${purpleColour}y)${endColour} ${grayColour}tutorial of a specific machine${endColour}"
  echo -e "\t ${purpleColour}h)${endColour} ${grayColour}show help panel${endColour}"
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

function checkIsMachineExists(){
  results=$1
  error=$2
  trimmed_results=$(echo "$results" | tr -d '[:space:]')
  if [[ -z "$trimmed_results" ]]; then
    echo -e "${redColour}[!] ${error}${endColour}"
    exit 1
  fi
}

function searchMachine(){
  machineName="$1"
  machine_result="$(cat bundle.js | awk "BEGIN{IGNORECASE=1} /\"${machineName}\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed "s/^ *//")"
  checkIsMachineExists "$machine_result" "$machineName machine has not been found."
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}listing the properties for the machine${endColour} ${blueColour}$machineName${endColour}${grayColour}:${endColour}"
    cat bundle.js | awk "BEGIN{IGNORECASE=1} /name: \"${machineName}\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed "s/^ *//"
  }

function searchByIP(){
  ipAddress="$1"
  machine_result="$(cat bundle.js | grep "ip: \"${ipAddress}\"" -B 3 | grep "name: " | awk 'NF{print$NF}' | tr -d '"' | tr -d ',')"
  checkIsMachineExists "$machine_result" "machine has not been found asociated with the ip Address $ipAddress."
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}the machine for the ip${endColour} ${blueColour}${ipAddress}${endColour} ${grayColour}is${endColour} ${blueColour}${machine_result}${endColour}"
}

function getMachineTutorial(){
  machineName="$1"
  machine_result="$(cat bundle.js | awk "BEGIN{IGNORECASE=1} /\"${machineName}\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed "s/^ *//")"
  checkIsMachineExists "$machine_result" "$machineName machine has not been found."
  link="$(cat bundle.js | awk "BEGIN{IGNORECASE=1} /name: \"${machineName}\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed "s/^ *//" | grep youtube | awk 'NF{print $NF}')"
  echo -e "${yellowColour}[+]${endColour}${grayColour} If you are stuck here is the machine solution:${endColour}${blueColour} ${link}${endColour}"
}

function getMachineByDifficulty(){
  machine_results="$(cat bundle.js | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name: "| awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"
  checkIsMachineExists "$machine_results" "please enter a correct difficulty: Fácil, Media, Difícil, Insane."
  echo -e "${yellowColour}[+]${endColour}${grayColour} The machines with difficulty${endColour} ${blueColour}${difficulty}${endColour}${grayColour} are the following:${endColour}\n"
  echo -e "${machine_results}"
}

function getMachineByOs(){
  os="$1"
  machine_results="$(cat bundle.js | grep "so: \"${os}\"" -B 4 | grep "name: " | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column)"
  checkIsMachineExists "$machine_results" "please enter a correct OS: Linux or Windows."
  echo -e "${yellowColour}[+]${endColour}${grayColour} The machines with OS ${endColour} ${blueColour}${os}${endColour}${grayColour} are the following:${endColour}\n"
  echo -e "${machine_results}"
  }

function getMachineByDifficultyAndOs(){
  difficulty=$1
  os=$2

  machine_results="$(cat bundle.js | grep "so: \"${os}\"" -C 4 | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  checkIsMachineExists "$machine_results" "please enter a correct OS: Linux or Windows or difficulty: Fácil, Media, Difícil, Insane."
  echo -e "${yellowColour}[+]${endColour}${grayColour} The machines with OS${endColour} ${blueColour}${os}${endColour}${grayColour} and difficulty ${blueColour}${difficulty}${endColour}${grayColour} are thefollowing:${endColour}\n"
  echo -e "${machine_results}"
}

function getMachineBySkill(){
  skill=$1
  machine_results="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"
  checkIsMachineExists "$machine_results" "machines that required the following skill ${blueColour}${skill}${endColour} ${redColour}has not been found.${endColour}"
  echo -e "${yellowColour}[+]${endColour}${grayColour} The machines that required the skill${endColour} ${blueColour}${skill}${endColour}${grayColour}${grayColour} are thefollowing:${endColour}\n"
  echo -e "${machine_results}"
}

# indicators
declare -i parameter_counter=0

declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG";let parameter_counter+=1;;
    u) parameter_counter+=2;;
    i) ipAddress="$OPTARG";parameter_counter+=3;;
    y) machineName="$OPTARG";parameter_counter+=4;;
    d) difficulty="$OPTARG";chivato_difficulty+=1;parameter_counter+=5;;
    o) os="$OPTARG";chivato_os+=1;parameter_counter+=6;;
    s) skill="$OPTARG";parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchByIP $ipAddress
elif [ $parameter_counter -eq 4 ];then
  getMachineTutorial $machineName
elif [ $parameter_counter -eq 5 ];then
  getMachineByDifficulty $difficulty
elif [ $parameter_counter -eq 6 ];then
  getMachineByOs $os
elif [ $parameter_counter -eq 7 ];then
  getMachineBySkill "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ];then 
  getMachineByDifficultyAndOs $difficulty $os
else 
  helpPanel
fi
