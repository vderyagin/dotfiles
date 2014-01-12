if [ $EUID -ne 0 ]; then
  cdpath=(
    "${GOPATH}/src/github.com/${USER}"
    "${HOME}/repos/dev"
    "${HOME}/repos/exercises"
    "${HOME}/repos/forks"
    "${HOME}/repos/misc"
    $cdpath
  )
fi

declare -U cdpath
