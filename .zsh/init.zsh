if [ $EUID -ne 0 ]; then
  eval "$(rbenv init -)"

  if [ -f '/usr/bin/virtualenvwrapper.sh']; then
    source '/usr/bin/virtualenvwrapper.sh'
  else
    echo 'virtualenvwrapper is not installed'
  fi
fi
