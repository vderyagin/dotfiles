mcd() {
  mkdir "$1"
  cd "$1"
}

rcd() {
  local P="$PWD"
  cd .. && rmdir "$P" || cd "$P"
}

rename() {
  local name="$1"
  if [ -e "$1" ]; then
    vared -c -p 'rename to: ' name
    command mv -v "$1" "$name"
  else
    echo "file '$1' does not exist." 1>&2
    return 1
  fi
}
