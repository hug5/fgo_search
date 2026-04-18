# fgo : find & go cd / open Sublime Project


### Description:
- Find and cd to directory 
- Find and open Sublime-Text project


#### Requirement:
- fd find
- fzf


```
SYNOPSIS
  ▫ cd directory to file location or directory w/ fzf
  ▫ Open Sublime Project

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
  $ fgo -SP code    Open Sublime Project from alias 'code' directory
  $ fgo projects    Start from alias 'projects' directory

ALIASES
  ⬚  home                     ⬚  web, webdev
  ⬚  ebook, ebooks            ⬚  codedocs      ⬚  dlp/movies
  ⬚  proj, project, projects  ⬚  coding        ⬚  music
  ⬚  shell, shellscripts      ⬚  tv, movies    ⬚  classical
  
```
  