maybe_load_script() {
  if [ -f "$1" ]; then
    source "$1"
  else
    echo "$1 does not exist"
  fi
}

if [ -d "${HOME}/src/zsh-completions/src" ]; then
  fpath=(
    "${HOME}/src/zsh-completions/src"
    $fpath
  )
else
  echo '~/src/zsh-completions/src directory does not exist'
fi

autoload -Uz compinit
compinit

maybe_load_script "${HOME}/.travis/travis.sh"

zmodload -i zsh/complist

bindkey '^i' complete-word

setopt menu_complete
setopt complete_in_word

# zstyle contexts make-up: ':completion:function:completer:command:argument:tag:'
zstyle ':completion:::::' completer _expand _complete _ignored _approximate

zstyle ':completion:*' format %B%d%b
zstyle ':completion:*:warnings' format '%BNo matches%b: %d'
zstyle ':completion:*:messages' format %B%d%b

zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-separator '#'
zstyle ':completion:*' auto-description 'specify: %d'


bindkey -M menuselect -r '\e[A' '\e[B' '\e[C' '\e[D'
bindkey -M menuselect '^o' accept-and-menu-complete
zstyle ':completion:*' select-prompt '%S%BCurrent selection at %p%b%s'
zstyle ':completion:*' menu 'select=0'


zstyle ':completion:*' matcher-list '+r:|[._-]=* r:|=*'
zstyle ':completion:*:(^approximate):*' matcher-list '+m:{a-z}={A-Z}'


zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' insert-tab true
