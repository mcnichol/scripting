#!/usr/bin/env bash

SCRIPT_DIR=${BASH_SOURCE%/*}
LOG_FILE=$SCRIPT_DIR/message_rate.log
PID_FILE=$SCRIPT_DIR/.pid_file
TS_PID_FILE=$SCRIPT_DIR/.ts_pid
NOZZLE_PID_FILE=$SCRIPT_DIR/.nozzle_pid

function guard_clause {
  if ! $(cf target); then
    echo "You must login to CF first"
    cf login
  fi

  #TODO: Test if JQ is installed
}

case "$1" in
  start-ts)
    while [ true ]
      do date >> $LOG_FILE
      sleep 1
    done &

    TIMESTAMP_PID=$!
    echo $TIMESTAMP_PID > $TS_PID_FILE
    ;;
  start-nozzle)
    cf nozzle -n | pv -f -l -i 1 -tbra -F '%t %b %r %a' > /dev/null 2>> $LOG_FILE &
    NOZZLE_PID=$!

    echo $NOZZLE_PID > $NOZZLE_PID_FILE
    #echo "{\"TIMESTAMP_PID\": $TIMESTAMP_PID, \"NOZZLE_PID\":$NOZZLE_PID}" > $PID_FILE

    ;;
  stop)
    # TODO: Guard against PID File not existing
    kill $(cat $TS_PID_FILE )
    kill $(cat $NOZZLE_PID_FILE)
    ;;
  pids)
    cat $PID_FILE | jq .
    ;;
  tail)
    tail -f $LOG_FILE
    ;;
  clean)
    read -r -p "YOU ARE ABOUT TO DELETE: $LOG_FILE and $PID_FILE - Are you sure [y/N]:" confirm
    SANITIZE_CONFIRM=$(echo $confirm | tr '[:upper:]' '[:lower:]')

    if [ ${confirm:0:1} == 'y' ]; then
      kill $(fuser $LOG_FILE 2>/dev/null) >/dev/null 2>&1
      rm $LOG_FILE $PID_FILE >/dev/null 2>&1
    else
      echo "Aborting Cleanup..."
    fi
    ;;
  --help|-h)
    printf "start-ts\t-\tWill spawn `date` PID streaming to $LOG_FILE\n"
    printf "start-nozzle\t-\tWill spawn `cf nozzle` PID streaming to $LOG_FILE\n"
    printf "stop\t-\tKills any PID's in $PID_FILE\n"
    printf "pids\t-\tDisplay PID's in $PID_FILE\n"
    printf "tail\t-\tFollow $LOG_FILE\n"
    printf "cleanup\t-\tClean up any processes uncaught and delete $LOG_FILE and $PID_FILE\n"
    ;;
  *)
    echo "Usage: ./pipe-nozzle.sh (start|stop)"
    exit -1;
    ;;
esac
