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


function ctrl_c(){
 echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
 tput cnorm && exit 1
}


# Ctrl+C

trap ctrl_c INT

# Variables Globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
 echo -e "\n${yellowColour}[+] Uso:${endColour}"
 
 echo -e "\t${purpleColour}u)${endColour} Descargar o actualizar archivos necesarios"
 echo -e "\t${purpleColour}m)${endColour} Buscar por un nombre de maquina"
 echo -e "\t${purpleColour}i)${endColour} Buscar por direccion IP"
 echo -e "\t${purpleColour}y)${endColour} Buscar por nombre de la maquina"
 echo -e "\t${purpleColour}d)${endColour} Buscar por la dificultad de una maquina" 
 echo -e "\t${purpleColour}s)${endColour} Buscar por sistema operativo"
 echo -e "\t${purpleColour}h)${endColour} Mostrar este panel de ayuda"
} 

function searchMachine(){
 machineName="$1"
 machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/"  | grep -vE "resuelta:|id:|sku" | tr -d "," | tr -d '"' | sed 's/^ */ /')"

if [ "$machineName_checker" ]; then
 echo -e "${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la maquina${endColour} ${blueColour}$machineName${endColour}${grayColour}:${endColour}\n" 
 
 cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/"  | grep -vE "resuelta:|id:|sku" | tr -d "," | tr -d '"' | sed 's/^ */ /' 
else
 echo -e "\n[!] La maquina proporcionada no existe\n"
fi
}

function updateFiles(){

  tput civis
  if [ ! -f bundle.js ]; then
  tput civis
   echo -e "\n${yellowColour}[+]${endColour}${grayColour}Descargando archivos necesario...${endColour}\n"
   curl -s $main_url > bundle.js
   js-beautify bundle.js | sponge bundle.js
   echo -e "\n${yellowColour}[+]${endColour}${grayColour}Todos los archivos han sido descargados${endColour}\n" 
  tput cnorm
 else
   tput civis
   echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay acutalizaciones pendientes${endColour}\n"
   curl -s $main_url > bundle_temp.js
   js-beautify bundle_temp.js | sponge bundle_temp.js
   md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
   md5_original_value=$(md5sum bundle.js | awk '{print $1}')
   
    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No hay actualizaciones${endColour}\n"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones${endColour}\n"
      sleep 3
      rm bundle.js && mv bundle_temp.js bundle.js 
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Los archivos han sido actualizados${endColour}\n"
    fi

   tput cnorm
  fi
}
function searchIP(){
  ipAddress="$1"

  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  if [ "$machineName" ]; then
  echo -e "\n[+] La IP $ipAddress, corresponde a la maquina $machineName\n"
   else
  echo -e "\n[!] La IP proporcionada no existe\n" 
  fi
}

function getYoutubeLink(){
  machineName="$1"
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep youtube | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$youtubeLink" ]; then
  echo -e "[+] El tutorial para esta maquina esta en el siguiente enlace $youtubeLink"
  else
  echo -e "[+] La maquina proporcionada no existe"
  fi
  }

function getMachinesDifficulty(){
 difficulty="$1"

 results_check="$(cat bundle.js | grep  "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

 if [ "$results_check" ]; then
  echo -e "\n[+] Representando las maquinas que posee la dificultad $difficulty\n"
  cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
 else
  echo -e "\n[!] La dificultad indicada no existe\n" 
 fi
}

function getMachineSistem(){
 sistem="$1"
nameSistem="$(cat bundle.js | grep "so: \"$sistem\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

if [ "$nameSistem" ]; then
  echo "\n[+] Representando todo las maquinas del sistema operativo $sistem"
  cat bundle.js | grep "so: \"$sistem\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
else
  echo -e "\n[!]El sistema operativo ingresado no existe\n"
fi
}
function getSODificult(){
 difficulty="$1"
 sistem="$2"

 check_results="$(cat bundle.js | grep "so: \"$sistem\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name" | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column)"
 if [ "$check_results" ]; then
 echo -e "\n[+] Listando maquinas de dificultad $difficulty que tengan el sistema operativo $sistem\n"

 cat bundle.js | grep "so: \"$sistem\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name" | awk 'NF {print $NF}' | tr -d '"' | tr -d ', ' | column
else
  echo "\n[!] Se ha indicado una dificultad o sistema operativo incorrectos"
fi
}
function getDificultSO(){
 sistem="$1"
 difficulty="$2"
 checkOSDificult="$(cat bundle.js | grep "dificultad: \"$difficulty\""  -C 5 | grep "so: \"$sistem\"" -B 4 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
 if [ "$checkOSDificult" ]; then
echo -e  "\n[+] Listando maquinas que tengan sistema operativo $sistem de dificultad $difficulty"
  cat bundle.js | grep "dificultad: \"$difficulty\""  -C 5 | grep "so: \"$sistem\"" -B 4 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ','
else
echo -e "\n[!] Se ha indicado un sistema operativo o dificultad incorrectos"
 fi
}
# Indicadores
declare -i parameter_counter=0
# Chivatos
declare -i chivatos_dificultad=0
declare -i chivatos_so=0

while getopts "m:ui:y:d:s:h" arg; do
  case $arg in
  m) machineName=$OPTARG; let parameter_counter+=1;;
  u) let parameter_counter+=2;;
  i) ipAddress=$OPTARG; let parameter_counter+=3;;
  y) machineName=$OPTARG; let parameter_counter+=4;;
  d) difficulty=$OPTARG; chivatos_dificultad=1; let parameter_counter+=5;;
  s) sistem=$OPTARG; chivatos_so=1; let parameter_counter+=6;;
  h) ;;
 esac
done

if [ $parameter_counter -eq 1 ]; then
 searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
 updateFiles
elif [ $parameter_counter -eq 3 ]; then
 searchIP  $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $difficulty  
elif [ $parameter_counter -eq 6 ]; then
  getMachineSistem $sistem
elif [ $chivatos_dificultad -eq 1 ] && [ $chivatos_so -eq 1 ]; then
  getSODificult $difficulty $sistem
elif [ $chivatos_so -eq 1 ] && [ $chivatos_dificultad]; then
  getDificultSO $sistem $difficulty
else
 helpPanel
fi
