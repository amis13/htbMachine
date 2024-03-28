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

#Variables
main_url="https://htbmachines.github.io/bundle.js"

#Functions
function ctrl_c(){
	echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
	tput cnorm && exit 1
}

#Ctrl+C
trap ctrl_c INT

function helpPanel(){
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
	echo -e "\t${yellowColour}u)${endColour}${grayColour} Descargar/Actualizar los archivos necesarios${endColour}"
	echo -e "\t${yellowColour}d)${endColour}${grayColour} Buscar por dificultad${endColour}"
	echo -e "\t${yellowColour}o)${endColour}${grayColour} Buscar por sistema operativo${endColour}"
	echo -e "\t${yellowColour}m)${endColour}${grayColour} Buscar por nombre de máquina${endColour}"
	echo -e "\t${yellowColour}i)${endColour}${grayColour} Buscar por direccion IP${endColour}"
	echo -e "\t${yellowColour}s)${endColour}${grayColour} Buscar por skills${endColour}"
	echo -e "\t${yellowColour}y)${endColour}${grayColour} Obtener el link de youtube de la maquina${endColour}"
	echo -e "\t${yellowColour}h)${endColour}${grayColour} Panel de ayuda${endColour}"
}

function updateFiles(){
	tput civis
	if [ ! -f bundle.js ]; then
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos...${endColour}"
		curl -s $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${greenColour}[+]${endColour}${grayColour} ¡Descarga realizada con éxito!${endColour}"
	else
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
		curl -s $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')

		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			sleep 1
			echo -e "\n${yellowColour}[+]${endColour}${grayColour} No hay actualizaciones disponibles, esta todo actualizado ;)${endColour}"
			rm bundle_temp.js

		else
			echo -e "\n${yellowColour}[+]${endColour}${grayColour} Hay actualizaciones disponibles${endColour}"
			sleep 1

			rm bundle.js && mv bundle_temp.js bundle.js
			echo -e "\n${greenColour}[+]${endColour}${grayColour} ¡Actualización finalizada con éxito!${endColour}"
		fi
	fi
	tput cnorm
}

function searchMachine(){
	machineName="$1"
	machineName_checker="$(	cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

	if [ "$machineName_checker" ]; then
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina${endColour} ${yellowColout}$machineName${endColour}${grayColour}:${endColour}"
		cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
	else
		echo -e "\n${redColour}[!] La maquina ${yellowColour}$machineName${endColour} ${redColour}no existe${endColour}\n"
	fi
}

function searchIP(){
	ipAddress="$1"
	machineName="$(cat bundle.js| grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"')"

	if [ "$machineName" ]; then
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} La  maquina correspondiente para la IP ${blueColour}$ipAddress${endColour} es: ${endColour}${yellowColour}$machineName${endColour}\n"
	else
		echo -e "\n${redColour}[!] La ${yellowColour}$ipAddress${endColour} ${redColour}no existe${endColour}\n"
	fi
}

function getYoutubeLink(){
	machineName="$1"
	youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'| grep youtube | awk 'NF{print $NF}')"
	if [ "$youtubeLink" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para la maquina esta en el siguiente enlace:${endColour} ${blueColour}$youtubeLink${endColour}\n"
		cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'| grep youtube | awk 'NF{print $NF}'
	else
		echo -e "\n${redColour}[!] La maquina ${yellowColour}$machineName${endColour} ${redColour}no existe${endColour}\n"
	fi
}

function getMachineDifficulty(){
	difficulty="$1"
	machineCheck="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$machineCheck" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Las maquinas con difucultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}son:${endColour}\n"
		cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!] La ${yellowColour}$difficulty${endColour} ${redColour}no existe${endColour}\n"
	fi
}

function getOSMachines(){
	os="$1"
	osChecker="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$osChecker" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Las maquinas con el sistema operativo${endColour} ${blueColour}$os${endColour} ${grayColour}son:${endColour}\n"
		cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!] El sistema operativo ${yellowColour}$os${endColour} ${redColour}no existe${endColour}\n"
	fi
}

function getOSDifficultyMachines(){
	difficulty="$1"
	os="$2"
	check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$check_results" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Las maquinas con el sistema operativo${endColour} ${blueColour}$os${endColour} y dificultad ${blueColour}$difficulty${endColour} ${grayColour}son:${endColour}\n"
		cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!] Se ha indicado una dificultad o sistema operativo incorrecto${endColour}\n"
	fi
}

function getSkill(){
	skill="$1"
	skill_checker="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
	if [ "$skill_checker" ]; then
                echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Las maquinas con la skill${endColour} ${blueColour}$skill${endColour} ${grayColour}son:${endColour}\n"
		cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!] La skill ${yellowColour}$skill${endColour} ${redColour}no existe${endColour}\n"

	fi
}

# Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

# Indicadores
declare -i parameter_counter=0

while getopts "m:ui:y:d:o:s:h" arg; do
	case $arg in
		m) machineName="$OPTARG"; let parameter_counter+=1;;
		u) let parameter_counter+=2;;
		i) ipAddress="$OPTARG"; let parameter_counter+=3;;
		y) machineName="$OPTARG"; let parameter_counter+=4;;
		d) difficulty="$OPTARG"; chivato_difficulty=1;  let parameter_counter+=5;;
		o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
		s) skill="$OPTARG"; let parameter_counter+=7;;
		h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine "$machineName"
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP "$ipAddress"
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink "$machineName"
elif [ $parameter_counter -eq 5 ]; then
	getMachineDifficulty "$difficulty"
elif [ $parameter_counter -eq 6 ]; then
	getOSMachines "$os"
elif [ $parameter_counter -eq 7 ]; then
	getSkill "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
	getOSDifficultyMachines "$difficulty" "$os"
else
	helpPanel
fi
