eval `dircolors`

unset RUBYOPT

export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=999999
export XDG_CONFIG_HOME="${HOME}/.config"
export EDITOR='em'
export PAGER='most'
export READNULLCMD="$PAGER"

declare -T INFOPATH infopath

if [ $EUID -ne 0 ]; then
  export GIST_PATH="${HOME}/repos/gists"
  export VIDEO_DOWNLOAD_DIR="${HOME}/video"
  export PODCASTS_DIR="${HOME}/podcasts"
  export WALLPAPERS_DIR="${HOME}/.wallpapers"

  export GOPATH="${HOME}/repos/go"

  path=(
    "${GOPATH}/bin"
    "${HOME}/bin"
    "${HOME}/bin/lib/dart-sdk/bin"
    "${HOME}/bin/lib/odeskteam-3.2.13-1-x86_64/usr/bin"
    "${HOME}/bin/lib/copy/x86_64"
    "${HOME}/.rbenv/bin"
    "${HOME}/misc/games/bin"
    '/usr/local/heroku/bin'
    $path
  )

  cdpath=(
    "${GOPATH}/src/github.com/${USER}"
    "${HOME}/repos/dev"
    "${HOME}/repos/exercises"
    "${HOME}/repos/forks"
    "${HOME}/repos/misc"
    $cdpath
  )

  manpath=(
    "${HOME}/misc/man"
    $manpath
  )

  infopath=(
    "${HOME}/misc/info"
    $infopath
  )
fi

for var in path cdpath manpath infopath; do
  declare -U "${var}"
done
