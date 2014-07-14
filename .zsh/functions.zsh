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

# print random integer from 1 to $1
rand() {
  if [ -z "$1" ]; then
    echo "no argument specified"
    return 1
  fi

  local upper_bound=32767

  if (( $1 > 1 && $1 < upper_bound )); then
    echo $(( (RANDOM % $1) + 1 ))
  else
    echo "argument must be in range 2..${upper_bound}" >&2
    return 1
  fi
}
