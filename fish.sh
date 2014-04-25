#!/bin/bash
#-x # bash debugger thingy

# Include functions from other files
source fish_functions.sh

declare -a SUBCOMMANDS=()

#-------------------
#
#-------------------
function fish {
  #----------
  declare -a LOCALSUBCOMMANDS=(
  "more  | display more fish"
  "heaps | display heaps of fish"
  "rev   | fish face the other direction"
  );
  if [ "$1" == "--subcommands" ]; then
    SUBCOMMANDS=("${LOCALSUBCOMMANDS[@]}")
    return
  fi
  #----------

  FISH="<*)))>{"
  FISHREV="}<(((*>"
  re='^[0-9]+$'

  for var in "$@"
  do
    case "$var" in
    "rev")   FISH=$FISHREV;;
    "heaps") cnt=50;; #$RANDOM;;
    "more")  cnt=11;;
    *)
      if [[ -n "$1" ]] && [[ -z "${cnt}" ]] ; then
        if ! [[ "$1" =~ $re ]] ; then
          echo "'$1' is not a number the fish knows" >&2;
          cnt=1
        else
          cnt="$1"
        fi
      fi
      ;;
    esac
  done

  for i in `seq 1 $cnt`;
  do
    echo -n "$FISH  "
  done
}

function usage {
  declare -A USAGE_SWITCHES
  declare -A USAGE_TEXT
  declare -A USAGE_SUBCOMMANDS
  
  for element in "${COMBINED_FUNCS[@]}"
  do
    IFS='|' read -a array <<< "$element"
    key=$(trim "${array[0]}")
    switch=$(trim "${array[1]}")
    text=$(trim "${array[2]}")
    subcommands=$(trim "${array[3]}")

    isNotSet USAGE_SWITCHES[$key]
    if [ $? -ne 0 ]; then
      USAGE_SWITCHES[$key]=" $switch"
      USAGE_TEXT[$key]="$text"
      USAGE_SUBCOMMANDS[$key]="$subcommands"
    else
      USAGE_SWITCHES[$key]+=", ${switch}"
    fi
  done

  echo usage: $0 [OPTION]
  echo Options:
  for key in "${!USAGE_SWITCHES[@]}"
  do
    echo "     ${USAGE_SWITCHES[$key]}"
    echo "          ${USAGE_TEXT[$key]}"
    [[ ${USAGE_SUBCOMMANDS[$key]} == "yes" ]] && getSubCommands $key
  done
}
#//-----------------
# Funtion list
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
declare -a CORE_FUNCS=(
# function   | switch    | usage             | sub commands
'fish        | -f <n>    | do the fish thing | yes'
'fish        | fish <n>  |                   | yes'
'usage       | -h        | display this usage| no'
'usage       | --help    |                   | no'
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

getSubCommands() {
  $1 --subcommands
  for item in "${SUBCOMMANDS[@]}"
  do
    echo "               $item"
  done
  unset SUBCOMMANDS
}

####################
# Main
####################

# Pull functions in from fish_functions.sh
COMBINED_FUNCS=( "${CORE_FUNCS[@]}" "${FISH_FUNCS[@]}" )

# Process
for element in "${COMBINED_FUNCS[@]}"
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

