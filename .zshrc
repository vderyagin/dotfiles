for file in `ls ${HOME}/.zsh/*.zsh`; do
  source "${file}"
done

if [ -f "${HOME}/.travis/travis.sh" ]; then
  source "${HOME}/.travis/travis.sh"
fi
