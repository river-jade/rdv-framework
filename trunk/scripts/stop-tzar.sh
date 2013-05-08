#!/bin/bash
export TZAR_DIR="/home/ubuntu/tzar"

start-stop-daemon --stop --pidfile=$TZAR_DIR/tzar.pid
