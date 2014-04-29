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
  export COPY_SHARED_DIR="${HOME}/Copy"

  export GIST_PATH="${HOME}/repos/gists"
  export VIDEO_DOWNLOAD_DIR="${HOME}/video"
  export PODCASTS_DIR="${COPY_SHARED_DIR}/podcasts"
  export WALLPAPERS_DIR="${COPY_SHARED_DIR}/wallpapers"

  export GOPATH="${HOME}/repos/go"

  path=(
    "${GOPATH}/bin"
    "${HOME}/.cabal/bin"
    "${HOME}/.cask/bin"
    "${HOME}/.rbenv/bin"
    "${HOME}/bin"
    "${HOME}/bin/lib/google-cloud-sdk/bin"
    "${HOME}/bin/lib/copy/x86_64"
    "${HOME}/bin/lib/dart-sdk/bin"
    "${HOME}/bin/lib/odeskteam-3.2.13-1-x86_64/usr/bin"
    "${HOME}/misc/games/bin"
    '/usr/local/heroku/bin'
    $path
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

for var in path manpath infopath; do
  declare -U "${var}"
done
