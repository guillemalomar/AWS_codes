#!/usr/bin/env bash

# This script is used to delete logs from a Kibana endpoint.
# You might need to change not only the endpoint of your Kibana server, but also the format of the dates

ENDPOINT="https://stack.region.es.amazonaws.com/project_logs-"
LIMIT_DAYS=10
DAYS_TO_DELETE=14
FIRST_DAY=$((LIMIT_DAYS+1))
CURR_DATE=$(date +'%Y.%m.%d')

if [[ "$#" -eq 0 ]]; then  # If there are no parameters
  DAYS=`expr ${DAYS_TO_DELETE} + ${LIMIT_DAYS}`
  for (( i=FIRST_DAY; i<=$DAYS; i++ )); do
    PREV_DATE=$(date -j -v-"$i"d -f "%Y.%m.%d" ${CURR_DATE} "+%Y.%m.%d")
    echo Deleting file ${PREV_DATE}
    curl -X DELETE "$ENDPOINT""$PREV_DATE"
    echo '\n'
  done
elif [[ "$#" -eq 1 ]]; then  # If there are parameters
  if [[ -n "$1" ]] && [[ "$1" -eq "$1" ]] 2>/dev/null; then  # If the parameter is an integer
    DAYS=`expr $1 + ${LIMIT_DAYS}`
    for (( i=$FIRST_DAY; i<=$DAYS; i++ )); do
      PREV_DATE=$(date -j -v-"$i"d -f "%Y.%m.%d" ${CURR_DATE} "+%Y.%m.%d")
      echo Deleting file ${PREV_DATE}
      curl -X DELETE "$ENDPOINT""$PREV_DATE"
      echo '\n'
    done
  else  # If the parameter is a string
    if [[ $1 > ${CURR_DATE} ]]; then
      echo The provided day is from the future.
      exit 1
    fi
    for (( i=0; i<=$LIMIT_DAYS; i++ )); do
      PREV_DATE=$(date -j -v-"$i"d -f "%Y.%m.%d" ${CURR_DATE} "+%Y.%m.%d")
      if [[ "$1" = "$PREV_DATE" ]]; then
        echo The provided day is too recent. No logs from the last 10 days can be deleted.
        exit 1
      fi
    done
    echo Deleting file ${1}
    curl -X DELETE "$ENDPOINT""$1"
    echo '\n'
  fi
elif [[ "$#" -ge 2 ]]; then
  echo Wrong input. It should be:
  echo kibana_old_logs_cleaner.sh \(date in YYYY.MM.DD format/amount of days to delete\)
fi
