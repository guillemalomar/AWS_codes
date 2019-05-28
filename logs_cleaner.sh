#!/usr/bin/env bash

# This script is used to delete logs from a Kibana endpoint.
# You might need to change not only the endpoint of your Kibana server, but also the format of the dates

ENDPOINT="https://XXXXX.XXXXX.es.amazonaws.com/project_logs-"
LIMIT_DAYS=10
FIRST_DAY=$((LIMIT_DAYS+1))
CURR_DATE=$(date +'%Y.%m.%d')

delete_date_range () {
  DAYS=`expr ${DAYS_TO_DELETE} + ${LIMIT_DAYS}`
  for (( i=FIRST_DAY; i<=$DAYS; i++ )); do
    DATE_TO_DEL=$(date -j -v-"$i"d -f "%Y.%m.%d" ${CURR_DATE} "+%Y.%m.%d")
    delete_file
  done
}

past_date () {
  if [[ ${DATE_TO_DEL} > ${CURR_DATE} ]]; then
    echo false
  else
    echo true
  fi
}

old_enough () {
  for (( i=0; i<=$LIMIT_DAYS; i++ )); do
    PREV_DATE=$(date -j -v-"$i"d -f "%Y.%m.%d" ${CURR_DATE} "+%Y.%m.%d")
    if [[ "${DATE_TO_DEL}" = "${PREV_DATE}" ]]; then
      echo false
      return
    fi
  done
  echo true
}

delete_file () {
  echo Deleting file ${DATE_TO_DEL}
  curl -X DELETE "$ENDPOINT""$DATE_TO_DEL"
  echo '\n'
}

if [[ "$#" -eq 0 ]]; then                                    # If there are no parameters
  DAYS_TO_DELETE=14
  delete_date_range
elif [[ "$#" -eq 1 ]]; then                                  # If there are parameters
  if [[ -n "$1" ]] && [[ "$1" -eq "$1" ]] 2>/dev/null; then  # If the parameter is an integer
    DAYS_TO_DELETE=$1
    delete_date_range
  else                                                       # If the parameter is a string
    DATE_TO_DEL=$1
    IS_PAST_DATE="$(past_date)"
    if [[ ${IS_PAST_DATE} = "false" ]]; then
      echo The provided day is from the future.
      exit 1
    fi
    IS_OLD_ENOUGH="$(old_enough)"
    if [[ ${IS_OLD_ENOUGH} = "false" ]]; then
      echo The provided day is too recent. No logs from the last 10 days can be deleted.
      exit 1
    fi
    delete_file
  fi
elif [[ "$#" -ge 2 ]]; then
  echo Wrong input. It should be:
  echo logs_cleaner.sh \(date in YYYY.MM.DD format / amount of days to delete\)
fi
