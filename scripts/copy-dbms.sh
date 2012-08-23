#!/bin/bash
shopt -s nullglob

if [[ $# != 2 ]]; then
    echo "usage: $0 <runset name> <output-path>"
    exit
fi
DB_URL="jdbc:postgresql://rdv1/tzar1?user=postgres&password=rdv_admin"

runset=$1
outputpath=$2

# Takes the 9th field of the printruns output for the given runset. The 9th 
# field is the output_path.
for i in $(java -jar tzar.jar printruns --dburl "$DB_URL" --runset="$runset" --notruncate | \
    tail -n +3 | awk -F \| '{print $9}'); do 
    echo "Looking for files in $i"
    for j in $i/*.dbms; do 
        filename=${j##*/}; # this strips of the leading path, giving just the dbms file name
        filename_with_runid=${filename%*.dbms}.${i##*_}.dbms
        echo "Copying $j to $outputpath/${filename_with_runid}"
        cp $j $outputpath/${filename_with_runid}
    done; 
done
