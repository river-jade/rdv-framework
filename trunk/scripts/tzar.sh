#!/bin/bash

echo -n "Starting tzar node client:"

export TZAR_DB="jdbc:postgresql://arcs-01.ivec.org:5432/rdv?user=rdv&password=YRxGRhq5"

export TZAR_DIR="/home/ubuntu/tzar"
if [ ! -d  $TZAR_DIR ]; then
  mkdir $TZAR_DIR
fi

# run tzar as rdv role user
java -jar /home/ubuntu/bin/tzar.jar pollandrun --runnerclass JythonRunner --svnurl=https://rdv-framework.googlecode.com/svn/trunk/ &

# write the process id of the running process to a file
echo $! > $TZAR_DIR/tzar.pid
