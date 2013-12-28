if [ $EUID -ne 0 ]; then
  eval "$(rbenv init -)"
  source '/usr/bin/virtualenvwrapper.sh'
fi
