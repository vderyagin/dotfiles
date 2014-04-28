if [ $EUID -ne 0 ]; then

  if [ ! -d "${HOME}/.rbenv" ]; then
    git clone "https://github.com/sstephenson/rbenv.git" "${HOME}/.rbenv"
  fi

  if [ ! -d "${HOME}/.rbenv/plugins/ruby-build" ]; then
    git clone 'https://github.com/sstephenson/ruby-build.git' "${HOME}/.rbenv/plugins/ruby-build"
  fi

  eval "$(rbenv init -)"

  if [ -f '/usr/bin/virtualenvwrapper.sh' ]; then
    source '/usr/bin/virtualenvwrapper.sh'
  else
    echo 'virtualenvwrapper is not installed'
  fi
fi
