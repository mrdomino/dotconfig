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
setopt hist_expire_dups_first
setopt append_history

fpath+=(~/.config/zsh/site-functions)
[[ -d /opt/local/share/zsh/site-functions ]] && \
  fpath+=(/opt/local/share/zsh/site-functions)
[[ dev = "$(hostname)" ]] && autoload -Uz ssh-reagent

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
autoload -Uz compinit && compinit -d ~/.zcompdump
