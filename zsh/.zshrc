# general ⟬1

setopt extended_glob

# history ⟬1
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=20000
SAVEHIST=10000
setopt hist_expire_dups_first
setopt append_history
setopt no_share_history

# prompt ⟬1
prompt='%(?.%F{green}✔.%F{red}☓%(1?.. %?))%f '
[[ ${(L)HOST[1]} = $HOST[1] ]] && prompt="${prompt}%F{cyan}%m%f:"
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

if [[ -d /opt/local/share/zsh/site-functions ]]; then
  fpath+=(/opt/local/share/zsh/site-functions)
fi

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
[[ "$(hostname)" = freebsd ]] || alias freebsd='ssh_term freebsd'
[[ "$(hostname)" = openbsd ]] || alias openbsd='ssh_term openbsd'
[[ "$(hostname)" = jce ]]     || alias jce='ssh_term jce'
[[ "$(hostname)" = devbox ]]  || alias devbox='ssh_term devbox'
[[ "$(hostname)" = devbox3 ]] || alias devbox3='ssh_term devbox3'
[[ "$(hostname)" = nixos ]]   || {
  alias nixos='ssh_term nixos'
  alias wol_nixos='wol -i 192.168.8.255 f0:de:f1:5f:ee:a9'
}
[[ "$(hostname)" = rpi ]]     || alias rpi='ssh_term rpi'
[[ "$(hostname)" = Mac* ]]    && alias nixvm='ssh_term nixvm'
[[ "$(hostname)" = Mac* ]]    && alias fbsdvm='ssh_term fbsdvm'

[[ "$(hostname)" = nix* ]] && {
  nixedit() {
    sudo -e "${1:-/etc/nixos/configuration.nix}" &&
      sudo nixos-rebuild switch
  }
}

github() {
  local repo=$1
  shift
  git lazy "git@github.com:$repo" "$@"
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
sw() {
  src ${1:-stairwell}
}
_src() {
  local paths=(~{,/src})(N)
  _path_files -/ -W "(${(j: :)paths})"
}

[[ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]] &&
  alias -g tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale

[[ -x ~/src/vere/bazel-bin/pkg/vere/urbit ]] &&
  alias urbit-dev=~/src/vere/bazel-bin/pkg/vere/urbit

alias venv='source ~/venv/bin/activate'
[[ -x $(which nvim) ]] && {
  alias vi=nvim
  alias vim=nvim
  alias vimconf='nvim ~/.config/nvim/init.lua'
}

! type fd >/dev/null 2>&1 && whence fdfind >/dev/null 2>&1 && {
  alias fd=fdfind
}
alias zprofile="edit_zsh $ZDOTDIR/.zprofile -l"
alias zshrc="edit_zsh $ZDOTDIR/.zshrc"
alias l="ls --color=auto"
alias ll="ls --color=auto -la"
alias scp="scp -o ForwardAgent=yes"
c() {
  cd "$@"
  l
}
alias :q=sl

autoload -Uz is-at-least wol zf_cat

# writing folder ⟬2
# cf. https://github.com/mrdomino/writing-scripts
wrime() {
  tmpdir=$(mktemp -d -t writing.XXXXXX)
  gpg -d "$HOME/Downloads/writing.git.tar.gz.gpg" |
    tar xz -C "$tmpdir"
  git clone -- "$tmpdir/writing.git" "$tmpdir/writing"
  pushd "$tmpdir/writing"
}

unwrime() {
  basename=$(basename "$PWD")
  [[ writing == "$basename" ]] ||
    { echo "$basename is not writing!" >&2
      return 1
    }
  tmpdir=$(dirname "$PWD")
  popd &&
    rm -rf "$tmpdir"
}

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
    compinit -w
  else
    compinit
  fi
}
compdef _src src
compdef _src cosmo
compdef _src sw
whence fdfind >/dev/null 2>&1 && {
  compdef _fd fdfind
}

local gcloud_paths=(~ /opt/local/libexec /usr/share)
for p in $gcloud_paths; do
  if [[ -f $p/google-cloud-sdk/completion.zsh.inc ]]; then
    source $p/google-cloud-sdk/completion.zsh.inc
    break
  fi
done

# keys ⟬1
bindkey -e

autoload -z edit-command-line
zle -N edit-command-line
bindkey '' edit-command-line

backward-kill-dir() {
  local WORDCHARS=${WORDCHARS/\/}
  zle backward-kill-word
  zle -f kill
}
zle -N backward-kill-dir
bindkey '' backward-kill-dir

if [[ -z ${(t)key} || ${(t)key} != array ]]; then
  typeset -g -A key
  [[ -n "$terminfo[kcuu1]" ]] && key[Up]=$terminfo[kcuu1]
  [[ -n "$terminfo[kcud1]" ]] && key[Down]=$terminfo[kcud1]
fi

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
[[ -n "${key[Up]}"   ]] && {
  zle -N up-line-or-beginning-search
  bindkey -- "${key[Up]}"   up-line-or-beginning-search
}
[[ -n "${key[Down]}" ]] && {
  zle -N down-line-or-beginning-search
  bindkey -- "${key[Down]}" down-line-or-beginning-search
}

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

# iTerm2 integration ⟬2
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=1
source "$ZDOTDIR/iterm2.zsh"

# hacky paranoid hostname verification ⟬1
autoload -Uz sha256sum
hostchecksum() {
  local host
  if [[ $# -eq 1 ]]; then
    host=$1
  else
    host=${HOST%%.*}
  fi
  echo -n "rHSUdV1IFRY6:$host" | sha256sum | cut -f1 -d' '
}
if ! grep -Fxq "$(hostchecksum)" "$ZDOTDIR/hostnames"; then
  echo $'\e[31mzsh: strange hostname:' "$HOST"$'\e[0m' >&2
  hostchecksum >&2
fi

# colophon ⟬1
# vim:fdm=marker fmr=⟬,⟭
