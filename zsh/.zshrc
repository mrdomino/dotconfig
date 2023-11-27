prompt='%(?.%F{green}✔%f.%F{red}☓%(1?.. %?)%f) %F{cyan}%m%f:%1~ %# '
alias venv='source ~/venv/bin/activate'
alias vim=nvim
alias :q=sl

bindkey -e

backward-kill-dir() {
  local WORDCHARS=${WORDCHARS/\/}
  zle backward-kill-word
  zle -f kill
}
zle -N backward-kill-dir
bindkey '' backward-kill-dir

HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=10000
setopt HIST_EXPIRE_DUPS_FIRST
setopt APPEND_HISTORY

fpath+=(~/.config/zsh/site-functions)
autoload -Uz ssh-reagent

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
autoload -Uz compinit && compinit
