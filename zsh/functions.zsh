mcd() {
  mkdir "$1"
  cd "$1"
}

rcd() {
  local P="$PWD"
  cd .. && rmdir "$P" || cd "$P"
}

rename() {
  for name in $@; do
    local prev="$name"
    if [ -e "$prev" ]; then
      vared -c -p 'rename to: ' name
      command mv -v "$prev" "$name"
    else
      echo "file '$prev' does not exist." 1>&2
      return 1
    fi
  done
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

zipdirs() {
  for dir in $@; do
    if [[ ! -d $dir ]]; then
        echo "'${dir}' is not a directory" >&2
        return 1
    fi
  done

  for dir in $@; do
    cd "$dir"
    apack "../${dir}.zip" *
    cd -
  done
}
