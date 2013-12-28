bindkey -e                                # emacs-style bindings

bindkey '\C-xu' universal-argument
bindkey '\e[2~' overwrite-mode            # INS

bindkey '\eq' push-line-or-edit
bindkey '\ep' history-beginning-search-backward
bindkey '\en' history-beginning-search-forward

bindkey '\C-h' backward-delete-char

bindkey '\C-xk' kill-region
bindkey '\e[Z' reverse-menu-complete      # S-tab

bindkey -r '\e[A' '\e[B' '\e[C' '\e[D'    # good bye, arrow keys

autoload -U edit-command-line
zle -N edit-command-line
bindkey '\ee' edit-command-line
