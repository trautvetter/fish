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
  # switch|alias | usage
  'more   | m    | display more fish'
  'more   | more | display more fish'
  'heaps  | heaps| display heaps of fish'
  'rev    | rev  | fish face the other direction'
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
    printf '%5s%s\n' "" "${USAGE_SWITCHES[$key]}"
    printf '%10s%s\n' "" "${USAGE_TEXT[$key]}"
    [[ ${USAGE_SUBCOMMANDS[$key]} == "yes" ]] && getSubCommands $key
    echo
  done
}
#//-----------------
# Funtion list
#-------------------
# single quoted, pipe separated, list of functions - one per line
# Fields are:
# function name | switch | usage | has sub commands [yes|no]
# Switch field is split on space and first part is used;
# subsequent arguments are forwarded and handling becomes the responsibility of
# the function that receives them.
# Multiple switches can be defined by creating a new line for the function
# and giving it a different switch. Only the first usage text will be displayed.
#-------------------
declare -a CORE_FUNCS=(
# function   | switch    | usage             | sub commands
'fish        | -f <n>    | do the fish thing | yes'
'fish        | f <n>     | do the fish thing | yes'
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

callFunction() {
  command=$1 # the function to call
  args=
  shift

  # find out of any of the args is an alias
  for element in "${COMBINED_FUNCS[@]}"
  do
    IFS='|' read -a array <<< "$element"
    key=$(trim "${array[0]}")
    hassubcommands=$(trim "${array[3]}")
    if [ "${key}" == "${command}" ] && [ "${hassubcommands}" == "yes" ]; then
      # find out what the passed in argument should really be
      ${command} --subcommands
      # Process
      for ARG in $@
      do
        for item in "${SUBCOMMANDS[@]}"
        do
          IFS='|' read -a arrSubs <<< "$item"
          # see if 2nd item (the alias) equals the passed in argument
          IFS=' ' read -a argstring <<< "$(trim "${arrSubs[1]}")"

          if [ "$(trim "${argstring[0]}")" == "$ARG" ]; then
            ## instead of the alias, put the real switch onto args
            args+="$(trim "${arrSubs[0]}") "
            break
          else
            # The argument is not an alias for anything, so just pass it through as is
            args+="$ARG "
            break
          fi

        done
      done
      unset SUBCOMMANDS
      break
    fi
  done

  ${command} ${args}
}

getSubCommands() {
  declare -A SWITCHES
  declare -A ALIASES
  declare -A USAGE
  $1 --subcommands
  for element in "${SUBCOMMANDS[@]}"
  do
    IFS='|' read -a array <<< "$element"
    switch=$(trim "${array[0]}")
    alias=$(trim "${array[1]}")
    usage=$(trim "${array[2]}")

    isNotSet SWITCHES[$switch]
    if [ $? -ne 0 ]; then
      SWITCHES[$switch]=" $switch"
      ALIASES[$switch]="$alias"
      USAGE[$switch]="$usage"
    else
      ALIASES[$switch]+=", ${alias}"
    fi
  done
  printf '%16s%s\n' "" "Sub commands:"
  for switch in "${!SWITCHES[@]}"
  do
    printf '%22s%s\n' "" "${ALIASES[$switch]}"
    printf '%27s%s\n' "" "${USAGE[$switch]}"
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
    callFunction $(trim "${array[0]}") $@
    exit
  fi
done

# Display usage if nothing else if going on
usage
