export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=999999
export XDG_CONFIG_HOME="${HOME}/.config"
export EDITOR='em'

eval `dircolors`

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

declare -U path

export PAGER='most'
export READNULLCMD="$PAGER"
