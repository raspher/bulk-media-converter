#!/usr/bin/env bash

supportedExtensions="\.webm$|\.flv$|\.vob$|\.ogg$|\.ogv$|\.drc$|\.gifv$|\.mng$|\.avi$|\.mov$|\.qt$|\.wmv$|\.yuv$|\.rm$|\.rmvb$|/.asf$|\.amv$|\.mp4$|\.m4v$|\.mp*$|\.m?v$|\.svi$|\.3gp$|\.flv$|\.f4v$"

function getDestination {
    local lenght=${#1}
    local destination=${2:$lenght}
    echo "$destination"
}

function getSources {
    echo "$(find "$1" -type f | grep -E "$supportedExtensions" |  tr '\n' ':')"
}

function convert {
    ffmpeg -loglevel error -nostdin -stats -i "$1" -c:v libvpx-vp9 -fpsmax 2 -speed 8 -quality realtime -row-mt 1 -c:a aac -b:a 64k -ar 44100 -ac 1 "$2"
}

function usage {
    echo "Usage: [input_directory] [output_directory]"
}

if [ $# -ne 2 ] ; then
    usage
    exit
fi

filesFrom=$(realpath "$1")
filesTo=$(realpath "$2")

sources=$(getSources "$filesFrom")

while read line
do
    absPath=$(realpath "${line}")
    fileName=$filesTo${absPath:${#filesFrom}}
    dirName="$(dirname "$fileName")"
    destination="${fileName%.*}.mp4"
    mkdir -p "$dirName"
    echo "Converting $absPath ---> $destination"
    convert "$absPath" "$destination"
done < <(echo "$sources" | tr ':' '\n')
