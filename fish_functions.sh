#!/bin/bash

declare -a FISH_FUNCS=(
# function| switch     | usage                  | sub commands
'carroll  | -c         | print a Carroll quote  | no'
'carroll  | --carroll  |                        | no'
'bukowski | -b         | print a Bukowski quote | no' 
'bukowski | --bukowski |                        | no'
'quote    | -q         | print a quote          | yes'
);

#-------------------
#
#-------------------
function carroll {
  echo "If you don't know where you are going, any road will take you there. Lewis Carroll";
}

function bukowski {
  echo "Find what you love and let it kill you. Bukowski";
}

function quote {
  #----------
  declare -a LOCALSUBCOMMANDS=(
  # switch|alias| usage
  '-b     |-b   | display bukowski quote'
  '-c     |-c   | display carroll quote'
  );
  if [ "$1" == "--subcommands" ]; then
    SUBCOMMANDS=("${LOCALSUBCOMMANDS[@]}")
    return
  fi
  #----------

  for var in "$@"
  do
    case "$var" in
    "-b") bukowski;;
    "-c") carroll;;
    esac
  done
}

