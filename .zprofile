unset RUBYOPT

declare -T INFOPATH infopath

if [ $EUID -ne 0 ]; then
  export GIST_PATH="${HOME}/repos/gists"
  export VIDEO_DOWNLOAD_DIR="${HOME}/video"
  export PODCASTS_DIR="${HOME}/podcasts"

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
