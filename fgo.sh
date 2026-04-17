#! /usr/bin/bash
# // 2024-05-02 Thu 08:46
# // 2024-05-04 Sat 01:04
# // 2026-04-16 Thu 22:30

# Name: fgo.sh
# Location: .../shell-scripts/fgo_search/fgo.sh

#------------------------------------------------------------


# Check the script is sourced; has o be sourced in order to cd
if [ -z "$PS1" ]; then
    echo "This script must be sourced. Use \"source <script>\" instead."
    exit
fi


#------------------------------------------------------------


# fd='fdfind --hidden --exclude .git'
fd='fdfind --hidden --no-ignore --exclude .git'
  # --no-ignore : do not obey git ignore files

STYLE="--border --margin=1 --prompt=: --header=————————————————————————————————"
OPTION='--preview-window=right:40%:wrap'
  # OPTION="--preview='head -n50 {}'"  <---- Can't seem to put this in a variable; the {} errors;
  # It seems that if you quote STYLE, Bash interprets that as a single string rather \
  # than separate flags and options; so it doesn't seem to work; have to remove the quotes;



ARGS=''
START_DIR=''
# TFLAG='d'  # default is directory ALL search
TFLAG='a'  # default is directory ALL search
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
  $ fgo [-a | -f | -d | -l] [start_directory] [-h | --help]

FLAG OPTIONS
  -h | --help       Display this help
  -a                Path by any file/directory (default)
  -d                Path by directory
  -f                Path by file
  -l                Path by symlink

EXAMPLES
  $ fgo --help      Show help
  $ fgo             Path by any from current directory
  $ fgo .           Path by any from current directory (default)
  $ fgo ~/          Start path from user's home directory
  $ fgo -f ~/       Path by file from home directory
  $ fgo -d          Path by directory from current directory
  $ fgo -l /        Path by any from root directory
  $ fgo /etc        Start from /etc directory
  $ fgo projects    Start from alias 'projects' directory
  $ fgo home        Start from alias 'home' directory
  $ fgo ebooks      Start from alias 'ebooks' directory

ALIASES
  home
  ebook, ebooks, eBooks, eBook
  code, project, projects
  shell, shellscripts
  web, webdev
  codedocs
  tv, tv-movies, Movies
  dlp/movies, movies
  music
  classical
EOF
  OKAY=false
  return
}

# Aliases to use:
# alias fgo=". ./path_to/fgo.sh"
# alias fgof=". ./path_to/fgo.sh -f"


#------------------------------------------------------------

function _check_dir_alias() {

    case "$START_DIR" in
      "home")
          START_DIR="$HOME"
          ;;
      "ebook" | "ebooks" | "eBooks" | "eBook")
          START_DIR="$HOME/XMEDIA/MMedia/eBooks"
          ;;
      "code" | "projects" | "project")
          START_DIR="$HOME/DATA/zData/Coding/Projects"
          ;;
      "shellscripts"| "shell")
          START_DIR="$HOME/DATA/zData/Coding/Projects/shell-scripts"
          ;;
      "webdev"| "web")
          START_DIR="$HOME/DATA/zData/Coding/Projects/webdev"
          ;;
      "codedocs")
          START_DIR="$HOME/DATA/zData/Coding/CodeDocs"
          ;;
      "tv" | "tv-movies" | "Movies")
          START_DIR="$HOME/XMEDIA/TV-Movies"
          ;;
      "dlp/movies" | "movies")
          START_DIR="$HOME/Downloads/dlp/movies"
          ;;
      "music")
          START_DIR="$HOME/XMEDIA/Music"
          ;;
      "classical")
          START_DIR="$HOME/XMEDIA/Music/1-Classical"
          ;;
    esac

}

function _check_dir() {

    # Check if user used special directory aliases
    _check_dir_alias

    # Check valid directory
    if [[ ! -d "$START_DIR" ]]; then
        echo "Bad directory."
        OKAY=false
    fi
}

function _check_params() {

    if [[ -z "$F1" ]]; then
        START_DIR="."
        # TFLAG='d'  # d is default
    elif [[ "$F1" == "-h" || "$F1" == "--help" ]]; then
        _show_help

    # fgo -d /etc yyy
    # Check for 3rd parameter; if so, bad parameter; There should be max 2 parameters;
    elif [[ -n $F3 ]]; then
        echo "Bad parameter."
        _show_help

    # fgo /etc     # this is ok
    # fgo xx /etc  # if not -f or -d, then bad
    elif [[ "$F1" != "-d" && "$F1" != "-f" && "$F1" != "-a" && "$F1" != "-l" ]]; then
        if [[ "$F2" != '' ]]; then
            echo "Bad option"
            _show_help
        else
            START_DIR="$F1"
            _check_dir
        fi

    # fgo -f or fgo -f ~/
    elif [[ -z "$F2" ]]; then
        TFLAG="$F1"
        START_DIR="."

    # fgo -f /etc
    # fgo -d /etc
    else
        TFLAG="$F1"
        START_DIR="$F2"
        _check_dir
    fi

    TFLAG="${TFLAG#-}"  # remove negative

    if [[ $TFLAG == "a" ]]; then
        TFLAG=""
    elif [[ $TFLAG == "l" ]]; then
        TFLAG="-tl"
    elif [[ $TFLAG == "f" ]]; then
        TFLAG="-tf"
    elif [[ $TFLAG == "d" ]]; then
        TFLAG="-td"
    else
        echo "Bad option"
        _show_help
    fi


}

function _fgo() {

    # if [[ "$OKAY" == true ]]; then return; fi;
    local result
    # result="$($fd . -t $TFLAG $START_DIR | fzf $STYLE $OPTION)"
    # Can also denote types multiple times:
    # fd -tf -td -tl  # types file, directory, link

    result="$($fd . $TFLAG $START_DIR | fzf $STYLE $OPTION)"
    # Why the '.'? Seems to be a FD quirk; it suggests it when doing some kinds of searches;
    # fd warning:
      # [fd error]: The search pattern '/home/h5/XMEDIA/' contains a path-separation character ('/') and will not lead to any search results.
      # If you want to search for all files inside the '/home/h5/XMEDIA/' directory, use a match-all pattern:
      # fd . '/home/h5/XMEDIA/'

    # After getting back the result, check if that result is a file or directory;
    # If file, then strip out the filename; get only the directory to cd into it;
    # -f : check if file; -d : check if directory
    if [[ -f "$result" ]]; then
        result=$(dirname "$result")
    fi

    # # After we get back the result, strip out the file name in order to cd into the dir;
    # if [[ "$TFLAG" == '-tf' ]]; then
    #     result=$(dirname "$result")
    # fi


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
  # Can be 1 or 2 params, but not 3; Error if 3rd param;

# echo "OUTPUT: f1=$F1 . f2=$F2 . f3=$F3"


# Check parameters and flags
_check_params

# If OKAY, then run;
if $OKAY; then _fgo; fi;

# Since the script must be sourced, can't just "exit" on error;
# So resorting to this check; xxx
