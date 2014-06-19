if [ $EUID -ne 0 ]; then
  eval "$(rbenv init -)"
  eval "$(~/.bin/bin init)"

  source "${HOME}/.travis/travis.sh"
  source '/usr/bin/virtualenvwrapper.sh'
fi
