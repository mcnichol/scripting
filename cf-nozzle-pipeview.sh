#!/usr/bin/env bash

SCRIPT_DIR=${BASH_SOURCE%/*}
LOG_FILE=$SCRIPT_DIR/message_rate.log
PID_FILE=$SCRIPT_DIR/.pid_file

function guard_clause {
  if ! $(cf target); then
    echo "You must login to CF first"
    cf login
  fi

  #TODO: Test if JQ is installed
}

case "$1" in
  start)
    while [ true ]
      do date >> $LOG_FILE
      sleep 1
    done &
    TIMESTAMP_PID=$!

    cf nozzle -n | pv -f -l -i 1 -tbra -F '%t %b %r %a' > /dev/null 2>> $LOG_FILE &
    NOZZLE_PID=$!

    echo "{\"TIMESTAMP_PID\": $TIMESTAMP_PID, \"NOZZLE_PID\":$NOZZLE_PID}" > $PID_FILE
    ;;
  stop)
    # TODO: Guard against PID File not existing
    kill $(cat $PID_FILE | jq '.TIMESTAMP_PID')
    kill $(cat $PID_FILE | jq '.NOZZLE_PID')
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
    printf "start\t-\tWill spawn two PID's, `cf nozzle` and `date` both streaming to $LOG_FILE\n"
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
