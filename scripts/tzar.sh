#!/bin/bash
export TZAR_DIR="/home/ubuntu/tzar"

echo -n "Starting tzar node client:"

if [ ! -d $TZAR_DIR ]; then
  mkdir $TZAR_DIR
fi

# run tzar
java -jar /home/ubuntu/bin/tzar.jar pollandrun \
    --repository-prefixes=http://rdv-framework.googlecode.com/svn/trunk/,https://rdv-framework.googlecode.com/svn/trunk/,http://tzar-framework.googlecode.com/svn/trunk/,https://tzar-framework.googlecode.com/svn/trunk/ \
    --scpoutputhost=glass.eres.rmit.edu.au \
    --scpoutputpath=/mnt/rdv/tzar_output \
    --scpoutputuser=ubuntu \
    --pemfile=/home/ubuntu/glass.pem $EXTRA_TZAR_FLAGS &

# write the process id of the running process to a file
echo $! > $TZAR_DIR/tzar.pid
