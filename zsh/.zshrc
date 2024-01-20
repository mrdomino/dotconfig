# general ⟬1

setopt extended_glob

# history ⟬1
HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=10000
setopt hist_expire_dups_first
setopt append_history
setopt no_share_history

# prompt ⟬1
prompt='%(?.%F{green}✔.%F{red}☓%(1?.. %?))%f '
[[ "$(hostname)" = (#i)mac* ]] || prompt="${prompt}%F{cyan}%m%f:"
prompt="${prompt}%1~ %# "

# fpath ⟬1
typeset -U fpath
fpath+=(~/.{config,{nix-profile,local}/share}/zsh/site-functions(N))
[[ -n $COSMO ]] && {
  fpath+=($COSMO/tool/zsh(N))
  autoload -Uz mkofs mmake nproc
}
[[ -x "$(which rustup)" ]] &&
  fpath+=${$(rustup which rustc)%/*/*}/share/zsh/site-functions

# aliases ⟬1
ssh_term() { ssh $@ -t tmux -CC new -As0 }
edit_zsh() {
  local f=$1; shift
  ${EDITOR:-vim} "$f" && exec $@ $SHELL
}
scpkey() {
  ssh $1 mkdir -p .ssh &&
  scp ${2:-~/.ssh/joshin.pub} $1:.ssh/joshin.pub
}

[[ "$(hostname)" = cuda ]]    || alias cuda='ssh_term cuda'
[[ "$(hostname)" = dev ]]     || alias dev='ssh_term dev'
[[ "$(hostname)" = freebsd ]] || alias freebsd='ssh_term freebsd'
[[ "$(hostname)" = openbsd ]] || alias openbsd='ssh_term openbsd'
[[ "$(hostname)" = jce ]]     || alias jce='ssh_term jce'
[[ "$(hostname)" = nixos ]]   || alias nixos='ssh_term nixos'
[[ "$(hostname)" = rpi ]]     || alias rpi='ssh_term rpi'
[[ "$(hostname)" = Mac* ]]    && alias nixvm='ssh_term nixvm'
[[ "$(hostname)" = Mac* ]]    && alias fbsdvm='ssh_term fbsdvm'

[[ "$(hostname)" = nix* ]] && {
  nixedit() {
    sudo -e "${1:-/etc/nixos/configuration.nix}" &&
      sudo nixos-rebuild switch
  }
}

src() {
  for d in ~{/src,}; do
    if [[ -e "$d/$1" ]]; then
      cd "$d/$1"
      break
    fi
  done
}
cosmo() {
  src ${1:-cosmo}
}
_src() {
  local paths=(~{,/src})(N)
  _path_files -/ -W "(${(j: :)paths})"
}

[[ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]] &&
  alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale

[[ -x ~/src/vere/bazel-bin/pkg/vere/urbit ]] &&
  alias urbit-dev=~/src/vere/bazel-bin/pkg/vere/urbit

alias venv='source ~/venv/bin/activate'
[[ -x $(which nvim) ]] && {
  alias vim=nvim
  alias vimconf='nvim ~/.config/nvim/init.lua'
}
alias zprofile="edit_zsh $ZDOTDIR/.zprofile -l"
alias zshrc="edit_zsh $ZDOTDIR/.zshrc"
alias :q=sl

autoload -Uz is-at-least zf_cat

# help builtin ⟬2
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help

# autocomplete ⟬1
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
autoload -Uz compinit && {
  if is-at-least 5.9; then
    compinit -d ~/.zcompdump -w
  else
    compinit -d ~/.zcompdump
  fi
}
compdef _src src
compdef _src cosmo

# keys ⟬1
bindkey -e

backward-kill-dir() {
  local WORDCHARS=${WORDCHARS/\/}
  zle backward-kill-word
  zle -f kill
}
zle -N backward-kill-dir
bindkey '' backward-kill-dir

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n "${key[Up]}"   ]] &&
  bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] &&
  bindkey -- "${key[Down]}" down-line-or-beginning-search

# zle app mode ⟬2
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  function zle_application_mode_start { echoti smkx }
  function zle_application_mode_stop { echoti rmkx }
  add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
  add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# tty/hooks ⟬1
ttyctl -f
autoload -Uz add-zsh-hook
function reset_broken_terminal () {
  printf '%b' '\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8'
}
add-zsh-hook -Uz precmd reset_broken_terminal

if [[ -n $TMUX ]]; then
  function refresh_sock () {
    local sock=$(tmux show-environment SSH_AUTH_SOCK)
    if [[ $sock[1] = '-' ]]; then
      unset SSH_AUTH_SOCK
    else
      export $sock
    fi
  }
  add-zsh-hook -Uz preexec refresh_sock
fi

TRAPUSR1() { rehash }

# colophon ⟬1
# vim:fdm=marker fmr=⟬,⟭
