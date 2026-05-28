if (( ! ${+LANG} )); then
  export LANG=en_US.UTF-8
fi
export LC_COLLATE=C
export TZ=America/Los_Angeles

export PARINIT='rTbgqR B=.,?_A_a Q=_s>|'
export EDITOR=vim
export RIPGREP_CONFIG_PATH=~/.config/ripgrep/rc

[[ -e ~/.bun ]] && export BUN_INSTALL=~/.bun
[[ -e ~/.gem ]] && export GEM_HOME=~/.gem
for d in ~{,/src}/cosmo; do
  if [ -e $d ]; then
    export COSMO=$d
    break
  fi
done

if [[ $0[1] = - && $SHELL != **/zsh* ]]; then
  () {
    local newshell=$1
    [[ -n $newshell ]] && {
      [[ -o interactive ]] &&
        echo zsh: \$SHELL: \""$SHELL"\" → \""$newshell"\" >&2
      SHELL=$newshell
    }
  } "$(whence -p ${0#-})" >&2
fi

typeset -U path
path+=(/{usr/local/go,opt/cosmocc/current}/bin(N))
path+=(~/bin)
path+=(~/{go,.{cargo,bun,gem,local,nix-profile}}/bin(N))
path+=(~/.local/share/bob/nvim-bin(N))
path+=(~/venv/bin(N))
path+=(~/.npm-packages/bin(N))
path+=(~/google-cloud-sdk/bin(N))

typeset -U manpath
manpath=('')
manpath+=(~/.nix-profile/share/man(N))
manpath+=(~/.local/share/man(N))
export MANPATH

[[ -x $(which nvim) ]] && EDITOR=nvim

# Use a stable per-tmux-session auth sock. This gets refreshed with a
# client-attached hook in tmux.conf, so it stays up to date with the most
# recent client to attach to this tmux session.
#
# Multiplayer tmux attach is not supported.
if [[ -n $TMUX ]]; then
  local sid=$(tmux display -p '#{session_id}' | tr -d '$')
  link="$HOME/.ssh/agent-tmux-$sid.sock"

  local real=$(tmux show-environment SSH_AUTH_SOCK 2>/dev/null)
  case "$real" in
    SSH_AUTH_SOCK=?*) real=${real#SSH_AUTH_SOCK=} ;;
    *)                real=$SSH_AUTH_SOCK ;;
  esac
  [ -S "$real" ] && [ "$real" != "$link" ] && ln -sfn "$real" "$link"

  export SSH_AUTH_SOCK="$link"
fi
