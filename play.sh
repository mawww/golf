#!/usr/bin/env bash

source "$(dirname "$0")/golf_common.sh"

#############################################################################
show_usage() {
  progself="$1"

  read -r -d '' usage << USAGE_END

Usage: ${progself} [OPTION]... <VIMGOLF-CHALLENGE-ID>...
Sets up Kakoune for a vimgolf attempt.

Options:
  -h,?            display this usage information

Examples:
  ${progself} <vimgolf-id>
USAGE_END

  printf "\n${usage}\n\n"
}


#############################################################################
#############################################################################

my_ex=${EX_SUCCESS}


# Check for prerequisites
declare -a prereqs=("basename" "cp" "mkdir" "mktemp" "rm" "rmdir" "tail")
confirm_in_path $prereqs

# Get the name by which this script was called.
PROGSELF=$(basename $0)

# Get command-line options
while getopts "?h" opt; do
  case "${opt}" in
    h|\?)
      show_usage "${PROGSELF}"
      exit ${EX_SUCCESS} # exit with success here since usage was requested
      ;;
  esac
done

shift $((OPTIND-1))

if [[ "$#" -ne "1" ]]; then
  printf "One vimgolf challenge ID is required as a parameter.\n" 1>&2
  show_usage "${PROGSELF}"
  exit ${EX_USAGE}
else
  challenge="$1"
fi

# Color styles
declare -A style=( [BASE]=00 [FAIL]=31 [BEST]=32 [BETTER]=32 [SAME]=33 [OK]=33 [WORSE]=35 )

if [[ ! -d ${challenge} ]]; then
  printf "Not a vimgolf challenge directory: ${challenge}\n"
  my_ex=${EX_FAIL}
else
  # Enter directory and check for necessary files
  cd ${challenge}
  if [[ ! -f in || ! -f out ]]; then
    printf "${challenge} : $(color_seq ${style[FAIL]})FAIL$(color_seq ${style[OK]}) (in our out file missing)$(color_seq ${style[BASE]})\n" 1>&2
    my_ex=${EX_FAIL}
    cd ..
  fi  

  # Create working filenames / file
  tryfile=$(mktemp .try.XXXX)
  cmdfile=$(mktemp .cmd.XXXX)
  cp in ${tryfile}

  # Use single quotes to preserve ${kak_hook_param} from evaluation here in
  # this script and double quotes to allow evaluation of ${cmdfile} here.
  init='map global user q ":write;quit;kill<ret>"
        hook global RawKey .+ %{ outcmd %val{hook_param} }
        define-command outcmd -params 1 %{ nop %sh{ echo -n "${kak_hook_param}" '
  init+=" >> ${cmdfile} } }"

  # Display the in, out, and (if it exists) cmd file
  printf '\n' ; center_heading ' in ' 70 '=' ; printf '\n'
  cat in
  center_heading ' out ' 70 '=' ; printf '\n'
  cat out
  if [ -f cmd ] ; then
    center_heading ' cmd ' 70 '=' ; printf '\n'
    cat cmd
    printf '\n'
  fi
  center_heading '' 70 '=' ; printf '\n'
  read -n 1 -p "Press any key..." input

  # Run Kakoune with no kakrc; run our initialization commands.
  kak ${tryfile} ui ncurses -n -e "${init}"

  # If the ,q mapping was used, the final "q" is not written to the cmd file.
  # Append "q" if the last character is ","
  if [[ "," = $(tail -c 1 ${cmdfile}) ]] ; then
    echo -n "q" >> ${cmdfile}
  fi

  # Show the commands from this attempt.
  printf 'Your latest attempt...\n'
  cat ${cmdfile}
  echo

  # Check to see if we have a successful try.
  $(cmp -s out ${tryfile})
  cmp_ex=$?
  rm --force ${tryfile}
  if [[ ${cmp_ex} -eq 0 ]] ; then
    # Examine our keystrokes to cmd and compute score.
    key_count=$(count_keys "$(<${cmdfile})")
    key_text="${key_count} keys"

    # Is our previous best score stored?
    if [ -f cmd ]; then
      hi_score=$(count_keys "$(<cmd)")
      hi_text=", personal best ${hi_score}"
    else
      hi_score=10000
      hi_text=""
    fi

    # Is the leading vimgolf score stored?
    if [ -f vgscore ]; then
      vim_score=$(cat vgscore)
      vim_text=", vim ${vim_score}"
    else
      vim_score=10000
      vim_text=""
    fi

    tag=OK

    # Did we improve on our personal best?
    if [ ${hi_score} -lt ${key_count} ]; then
      tag=WORSE
    elif [ ${hi_score} -gt ${key_count} ]; then
      cp ${cmdfile} cmd
      tag=BETTER
    
      if [ ${vim_score} -gt ${key_count} ]; then
        tag=BEST
      fi
    fi

  else
    tag=FAIL
    key_text=""
    my_ex=${EX_FAIL}
  fi

  rm --force ${cmdfile}

  color=${style[$tag]}
  echo "${challenge} $(color_seq $color)$tag$(color_seq ${style[BASE]}) (${key_text}${hi_text}${vim_text})$(color_seq ${style[BASE]})"
  cd ..
fi

exit ${my_ex}

