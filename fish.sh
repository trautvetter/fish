#!/bin/bash
#-x # bash debugger thingy

source fish_functions.sh

#-------------------
#
#-------------------
function fish {
  declare -a FUNCS=(
  'fish        | -f [n]    | fish'
  'fish        | fish [n]  | fish'
  'usage       | -h        | display this usage'
  'usage       | --help    | display this usage'
  );

  FISH="<*)))>{"
  FISHREV="}<(((*>"

  for var in "$@"
  do
    case "$var" in
    "rev")   FISH=$FISHREV;;
    "heaps") cnt=50;; #$RANDOM;;
    "more")  cnt=11;;
    esac
  done

  re='^[0-9]+$'
  if [[ -n "$1" ]] && [[ -z "${cnt}" ]] ; then
    if ! [[ "$1" =~ $re ]] ; then
      echo "'$1' is not a number the fish knows" >&2;
      cnt=1
    else
      cnt="$1"
    fi
  fi

  for i in `seq 1 $cnt`;
  do
    echo -n "$FISH  "
  done
}

function usage {
  declare -A USAGE_SWITCHES
  declare -A USAGE_TEXT

  for element in "${FUNCS[@]}"
  do
    IFS='|' read -a array <<< "$element"
    key=$(trim "${array[0]}")
    switch=$(trim "${array[1]}")
    text=$(trim "${array[2]}")
    isNotSet USAGE_SWITCHES[$key]
    if [ $? -ne 0 ]; then
      USAGE_SWITCHES[$key]=" $switch"
      USAGE_TEXT[$key]="$text"
    else
      USAGE_SWITCHES[$key]+=", ${switch}"
    fi
  done

  echo usage: $0 [OPTION]
  echo Options:
  for item in "${!USAGE_SWITCHES[@]}"
  do
    echo "     ${USAGE_SWITCHES[$item]}"
    echo "          ${USAGE_TEXT[$item]}"
  done
}
#//-----------------

#-------------------
# single quoted, pipe separated, list of functions - one per line
# Fields are:
# function name | switch | usage
# Switch field is split on space and first part is used;
# subsequent arguments are forwarded and handling becomes the responsibility of
# the function that receives them.
# Multiple switches can be defined by creating a new line for the function
# and giving it a different switch. Only the first usage text will be displayed.
#-------------------
declare -a FUNCS=(
'fish        | -f [n]    | do the fish thing'
'fish        | fish [n]  |'
'usage       | -h        | display this usage'
'usage       | --help    |'
);
#//-----------------

####################
# Utils
####################
trim() {
  # | tr -d ' ' # this would work too
  local var=$@
  var="${var#"${var%%[![:space:]]*}"}"  # remove leading whitespace
  var="${var%"${var##*[![:space:]]}"}"  # remove trailing whitespace
  echo -n "$var"
}

isNotSet() {
  if [[ ! ${!1} && ${!1-_} ]]
  then
    return 1
  fi
}

####################
# Main
####################

for element in "${FUNCS[@]}"
do
  IFS='|' read -a array <<< "$element"
  # see if 2nd item equals ARG
  IFS=' ' read -a argstring <<< "$(trim "${array[1]}")"
  if [ "$(trim "${argstring[0]}")" == "$1" ]; then
    ## call the function named in first element
    shift # get rid of first, and forward the remaining args
    $(trim "${array[0]}") $@
    exit
  fi
done

if [ -z "$ARG" ]; then
  usage
fi

