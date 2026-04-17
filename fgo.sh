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
SUBL_PROJ=false  # Is this a sublime project open?


#------------------------------------------------------------

function _show_help() {
cat << EOF
fgo : find & go cd / open Sublime Project

SYNOPSIS
  • cd directory to file location or directory w/ fzf
  • Open Sublime Project

SYNTAX
  $ fgo [-a | -f | -d | -l | -SP] [start_directory] [-h | --help]

FLAG OPTIONS
  -h | --help       Display this help
  -a                Path by any file/directory (default)
  -d                Path by directory
  -f                Path by file
  -l                Path by symlink
  -SP               Open Sublime-Project file

EXAMPLES
  $ fgo --help      Show help
  $ fgo             Path by any from current directory
  $ fgo .           Path by any from current directory (default)
  $ fgo ~/          Start path from user's home directory
  $ fgo -f ~/       Path by file from home directory
  $ fgo -d          Path by directory from current directory
  $ fgo -l /        Path by any from root directory
  $ fgo -SP code    Open Sublime Project from alias code directory
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

    # echo "$START_DIR"

    # Check valid directory
    if [[ ! -d "$START_DIR" ]]; then
        # echo $TFLAG
        # echo  "$START_DIR"
        echo "Bad directory."
        OKAY=false
        # Could end up here if user puts in bad option, like
         # combining multiple flags;
    fi
}

function _check_params() {

    if [[ -z "$F1" ]]; then
        START_DIR="."
        # TFLAG='d'  # d is default
    elif [[ "$F1" == "-h" || "$F1" == "--help" ||
            "$F2" == "-h" || "$F2" == "--help" ]]; then
        # Checking both f1 and f2 because the alias I set up may have
         # -a, -l, -f as the first parameter by default;

        _show_help

    # fgo -d /etc yyy
    # Check for 3rd parameter; if so, bad parameter; There should be max 2 parameters;
    elif [[ -n $F3 ]]; then
        echo "Too many parameter."
        _show_help

    # fgo /etc     # this is ok
    # fgo xx /etc  # if not -f or -d, then bad
    # elif [[ "$F1" != "-d" && "$F1" != "-f" && "$F1" != "-a" && "$F1" != "-l" ]]; then
    elif [[ "$F1" != "-SP" && "$F1" != "-d" && "$F1" != "-f" &&
            "$F1" != "-a" && "$F1" != "-l" ]]; then

        # if none of the above flags and there's a 2nd param:
        if [[ "$F2" != '' ]]; then
            echo "Bad option."
            _show_help

        # if it contains - with some other misc letters
        elif [[ "$F1" == "-"* ]]; then
            echo "Bad option."
            _show_help

        # This then must be the user's directory:
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


    if ! "$OKAY"; then
        return
    fi


    TFLAG="${TFLAG#-}"  # remove negative

    if [[ $TFLAG == "a" ]]; then
        TFLAG=""
    elif [[ $TFLAG == "SP" ]]; then
        TFLAG=""
        SUBL_PROJ=true
    elif [[ $TFLAG == "l" ]]; then
        TFLAG="-tl"
    elif [[ $TFLAG == "f" ]]; then
        TFLAG="-tf"
    elif [[ $TFLAG == "d" ]]; then
        TFLAG="-td"
    else
        # Don't think we should come here because we already checked
         # for these flags earlier;
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

    # fd='fdfind --hidden --no-ignore --exclude .git'

    # Let's change into the directory so that we minimize the long path;
    cd "$START_DIR" || return

    # result="$($fd . $TFLAG $START_DIR | fzf $STYLE $OPTION)"
    result="$($fd . $TFLAG | fzf $STYLE $OPTION)"
    # Why the '.'? Seems to be a FD quirk; it suggests it when doing some kinds of searches;
    # Seems . is used when searching a path with '/' in the path;

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


    if [[ -n $result ]]; then
        # In order for cd to work, the script has to be sourced;
        cd "$result" || return
        # doing || return is an extra safety; but since we
         # checked for valid directory, shouldn't have a problem;
    fi
}

function _fgo_subl() {

    local result

    # filter find by sublime-project extension
    fd="${fd} -e sublime-project"

    # Let's change into the directory so that we minimize the long path;
    cd "$START_DIR" || return

    result="$($fd . $TFLAG | fzf $STYLE $OPTION)"
    # Seems . is used when searching a path with '/' in the path;

    # not sure why just checking for $result doesn't work
     # if user happens to exit the search;
    # if $result; then  # this always seems to be true
    if [[ -n $result ]]; then
        # Open the sublime project
        # echo $result
        # echo "kkkkkkkkkkkkkkkkkkkk"
        subl --project "$result"
    fi

    # Return back to starting directory;
    cd - || return
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
# if $OKAY; then _fgo; fi;

# Check if this is a standard search/go; or open sublime project;
if $OKAY && $SUBL_PROJ; then
    _fgo_subl;
elif $OKAY; then
    _fgo;
fi;


# Since the script must be sourced, can't just "exit" on error;
# So resorting to this check; xxx
