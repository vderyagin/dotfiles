autoload -Uz compinit
compinit

zmodload -i zsh/complist

bindkey '^i' complete-word

setopt menu_complete
setopt glob_complete
setopt complete_in_word

zstyle ':completion:*' completer _expand _complete _ignored _approximate

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

zstyle ':completion:*:cd:*' ignore-parents parent pwd
