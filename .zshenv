if [ $EUID -ne 0 ]; then
  cdpath=(
    ${HOME}/code/exercises
    ${HOME}/code/gists
    ${HOME}/code/go
    ${HOME}/code/misc
    ${HOME}/code/oss
    ${HOME}/code/sandbox
    ${HOME}/code/src
    ${HOME}/code/work
    $cdpath
  )
fi

declare -U cdpath
