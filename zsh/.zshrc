source "$ZDOTDIR/alias.zsh"

autoload -U compinit
compinit

autoload {cn,g,t,zp,tn,scratch}

compdef {g=git,t=tmux}

# configure zvm on source
ZVM_INIT_MODE=sourcing
source $(zp load https://github.com/jeffreytse/zsh-vi-mode.git)

source $(zp load https://github.com/Aloxaf/fzf-tab.git)
source $(zp load https://github.com/zsh-users/zsh-syntax-highlighting.git)
source $(zp load https://github.com/zsh-users/zsh-autosuggestions.git)

eval "$(zoxide init --cmd=c zsh)"
eval "$(fzf --zsh)"
