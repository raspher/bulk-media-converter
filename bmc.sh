#!/usr/bin/env bash

if [ $# -ne 2 ] ; then
    usage
    exit
fi

function getDestination {
    local lenght=${#1}
    local destination=${2:$lenght}
    echo "$destination"
}

function getSources {
    echo $(find $1 -type f -printf '%p:')
}

function convert {
    ffmpeg -loglevel error -nostdin -stats -i "$1" -c:v libvpx-vp9 -fpsmax 2 -speed 8 -quality realtime -row-mt 1 -c:a aac -b:a 64k -ar 44100 -ac 1 "$2"
}

function usage {
    echo "Usage: [input_directory] [output_directory]"
}

filesFrom=$(realpath "$1")
filesTo=$(realpath "$2")

sources=$(getSources $1)

while read line
do
    absPath=$(realpath "$line")
    fileName=$filesTo${absPath:${#filesFrom}}
    dirName="$(dirname "$fileName")"
    destination="${fileName%.*}.mp4"
    mkdir -p "$dirName"
    echo "Converting $absPath ---> $destination"
    convert "$absPath" "$destination"
done < <(echo $sources | tr ':' '\n')
