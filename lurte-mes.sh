#!/bin/bash

apikey=$APIKEY_AEMET

error="
La APIKEY esta vacía, sin APIKEY no puedes obtener ningún dato.
Echale un ojo al README: https://github.com/vulturno/lurte#lo-que-necesitas
"

if [ -z "$apikey" ]; then
      printf "%b\n" "\e[31m$error"
      exit
fi

function openAemet {
    # El mes que queremos descargar
    mes=$1
    # El número de estación de la AEMET
    year=$2
    # El año que queremos descargar
    station=$3

    read -r "$1"
      case $1 in
          enero)
             curl --silent --request GET --insecure \
               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-01-01T00:00:00UTC/fechafin/'"${year}"'-01-31T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          febrero)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-02-01T00:00:00UTC/fechafin/'"${year}"'-02-29T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          marzo)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-03-01T00:00:00UTC/fechafin/'"${year}"'-03-31T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          abril)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-04-01T00:00:00UTC/fechafin/'"${year}"'-04-30T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          mayo)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-05-01T00:00:00UTC/fechafin/'"${year}"'-05-31T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          junio)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-06-01T00:00:00UTC/fechafin/'"${year}"'-06-30T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          julio)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-07-01T00:00:00UTC/fechafin/'"${year}"'-07-31T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          agosto)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-08-01T00:00:00UTC/fechafin/'"${year}"'-08-31T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          septiembre)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-09-01T00:00:00UTC/fechafin/'"${year}"'-09-30T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          octubre)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-10-01T00:00:00UTC/fechafin/'"${year}"'-10-31T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  >> "$mes".json
          ;;
          noviembre)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-11-01T00:00:00UTC/fechafin/'"${year}"'-11-30T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"''  > "$mes".json
          ;;
          diciembre)
             curl --silent --request GET --insecure \
                               --url 'https://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/'"${year}"'-12-01T00:00:00UTC/fechafin/'"${year}"'-12-31T23:59:59UTC/estacion/'"${station}"'/?api_key='"${apikey}"'' > "$mes".json
          ;;

          *)
             echo "No has introducido ningún mes, vuelve a probar introduciendo el nombre del mes en minúsculas."
          ;;
      esac

      jq -r '.datos' "$mes".json > temp.json && mv temp.json "$mes".json &&
      while read -r line
      do
          curl --silent --request GET --insecure "$line" >> "$mes".json
      done < "$mes".json

      # Al concatenar todos los meses el objeto JSON no esta bien construido
      # Mierdas varias para que el JSON quede formateado conforme es debido
      sed -i 's/],/,/' "$mes".json &&
      # Mierdas varias para que el JSON final quede formateado conforme es debido
      sed -i '$ s/,/]/' "$mes".json &&
      sed -i '$ s/],/,/' "$mes".json &&
      # Cambiamos el separador de coma por punto
      sed -i 's/\([0-9]\),/\1\./g' "$mes".json &&
      # Cambiamos Ip por 0 ver https://github.com/jorgeatgu/lurte/issues/9
      sed -i 's/Ip/0/' "$mes".json &&
      # Eliminamos las comillas de los números, incluídos los negativos
      sed -i -r 's/"(\-{0,1}[[:digit:]]+(\.[[:digit:]]+){0,1})"/\1/' "$mes".json &&
      # Eliminamos el cero a la izquierda que esta en los resultados de la dirección de viento
      sed -r -i 's/0*([0-9])/\1/' "$mes".json &&
      sed -i '1d' "$mes".json &&
      cp "$mes.json" "$station"-"$mes".json &&
      rm "$mes".json

}

showLoading() {
    mypid=$!
    loadingText=$1

    printf "%s.\r\e[35m" "$loadingText"

    while kill -0 $mypid 2>/dev/null
    do
        printf "%s.\r\e[35m" "$loadingText"
        sleep 0.5
        printf "%s..\r\e[35m" "$loadingText"
        sleep 0.5
        printf "%s...\r\e[35m" "$loadingText"
        sleep 0.5
        printf "\\n"
        printf "%s\r\e[35m" "$loadingText"
        sleep 0.5
    done

    echo "$loadingText...
    \Descarga completada!"
}

openAemet "$1" "$2" "$3" & showLoading "Descargando todos los datos de la AEMET"
