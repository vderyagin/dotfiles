for file in `/bin/ls ${HOME}/.zsh/*.zsh`; do
  source "${file}"
done

source "${HOME}/bin/init.zsh"
