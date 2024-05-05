#! /usr/bin/bash
# // 2024-05-02 Thu 08:46
# // 2024-05-04 Sat 01:04

#------------------------------------------------------------


# Check the script is sourced; has o be sourced in order to cd
if [ -z "$PS1" ]; then
    echo "This script must be sourced. Use \"source <script>\" instead."
    exit
fi


#------------------------------------------------------------


fd='fdfind --hidden --exclude .git'

STYLE="--border --margin=1 --prompt=: --header=————————————————————————————————"
OPTION='--preview-window=right:40%:wrap'
  # OPTION="--preview='head -n50 {}'"  <---- Can't seem to put this in a variable; the {} errors;
  # It seems that if you quote STYLE, Bash interprets that as a single string rather \
  # than separate flags and options; so it doesn't seem to work; have to remove the quotes;

ARGS=''
START_DIR=''
TFLAG='d'  # default is directory search
F1=''
F2=''
F3=''
OKAY=true


#------------------------------------------------------------

function _show_help() {
cat << EOF
fgo : find & go cd

SYNOPSIS
  cd directory to file location or directory with fzf

SYNTAX
  $ fgo [-f | -d] [start_directory_path] [-h | --help]

FLAG OPTIONS
  -h | --help       Display this help
  -d                Path by folder (default)
  -f                Path by file

EXAMPLES
  $ fgo --help   Show help
  $ fgo          Path by folder from current directory
  $ fgo .        Path by folder from current directory
  $ fgo ~/       Start path from user's home directory
  $ fgo -f ~/    Path by file from home directory
  $ fgo -d       Path by folder from current directory
  $ fgo /etc     Start from /etc directory; implies -d
  $ fgo -f /etc  Start from /etc directory
EOF
  OKAY=false
  return
}

# Aliases to use:
# alias fgo=". ./path_to/fgo.sh"
# alias fgof=". ./path_to/fgo.sh -f"


#------------------------------------------------------------


function _check_dir() {
    if [[ ! -d "$START_DIR" ]]; then
        echo "Bad directory."
        OKAY=false
        # _show_help
    fi
}

function _check_params() {

    if [[ -z "$F1" ]]; then
        START_DIR="."
        # TFLAG='d'  # d is default
    elif [[ "$F1" == "-h" || "$F1" == "--help" ]]; then
        _show_help

    # cgo xx /etc yyy
    # Check for 3rd parameter;
    elif [[ -n $F3 ]]; then
        echo "Bad parameter."
        _show_help

    # cgo /etc     # this is ok
    # cgo xx /etc  # if not -f or -d, then bad
    elif [[ "$F1" != "-d" && "$F1" != "-f" ]]; then
        if [[ "$F2" != '' ]]; then
            echo "Bad option"
            _show_help
        else
          START_DIR="$F1"
          # TFLAG='d'  # d is default
          _check_dir
        fi

    # cgo -f
    elif [[ -z "$F2" ]]; then
        TFLAG="$F1"
        START_DIR="."

    # cgo -f /etc
    # cgo -d /etc
    else
        TFLAG="$F1"
        START_DIR="$F2"
        _check_dir
    fi

    TFLAG="${TFLAG#-}"  # remove negative

    # echo $START_DIR
    # OKAY=false
}

function _fgo() {

    # if [[ "$OKAY" == true ]]; then return; fi;
    local result
    result="$($fd . -t $TFLAG $START_DIR | fzf $STYLE $OPTION)"

    if [[ "$TFLAG" == 'f' ]]; then
        result=$(dirname "$result")
    fi

    # In order for cd to work, the script has to be sourced;
    cd "$result" || return
    # doing || return is an extra safety; but since we
    # checked for valid directory, shouldn't have a problem;

}

#------------------------------------------------------------

ARGS="$*"

# Using awk because cut doesn't seem to be able to
# catch 2 and 3 if they don't exist; it assumts that 1 is 2;
# or 2 is 3; Maybe there's a fix for this;
F1=$(echo "$ARGS" | awk '{print $1}')
F2=$(echo "$ARGS" | awk '{print $2}')
F3=$(echo "$ARGS" | awk '{print $3}')


# Check parameters and flags
_check_params

# If OKAY, then run;
if $OKAY; then _fgo; fi;

# Since the script must be sourced, can't just "exit" on error;
# So resorting to this check;
