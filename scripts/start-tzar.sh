export TZAR_DIR="/home/ubuntu/tzar"

if [ ! -d $TZAR_DIR ]; then
  mkdir $TZAR_DIR
fi

/sbin/start-stop-daemon --start --pidfile=$TZAR_DIR/tzar.pid --startas /home/ubuntu/bin/tzar.sh >> $TZAR_DIR/consolelog 2>&1
