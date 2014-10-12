eval `dircolors`

unset RUBYOPT

export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=50000
export SAVEHIST=999999
export XDG_CONFIG_HOME=${HOME}/.config
export EDITOR=em
export PAGER=most
export READNULLCMD=$PAGER

declare -T INFOPATH infopath

if [ $EUID -ne 0 ]; then
  export COPY_SHARED_DIR=${HOME}/Copy

  export GIST_PATH=${HOME}/repos/gists
  export VIDEO_DOWNLOAD_DIR=${HOME}/video
  export PODCASTS_DIR=${COPY_SHARED_DIR}/podcasts
  export WALLPAPERS_DIR=${COPY_SHARED_DIR}/wallpapers
  export DOTFILES_DIR=${HOME}/.dotfiles

  export GOPATH=${HOME}/.go

  path=(
    ${GOPATH}/bin
    ${HOME}/.cabal/bin
    ${HOME}/.cask/bin
    ${HOME}/.rbenv/bin
    ${HOME}/misc/games/bin
    /usr/lib64/go/bin
    $path
  )

  manpath=(
    ${HOME}/misc/man
    $manpath
  )

  infopath=(
    ${HOME}/misc/info
    $infopath
  )
else
  path=(
    /home/vderyagin/.bin
    $path
  )
fi

for var in path manpath infopath; do
  declare -U $var
done
