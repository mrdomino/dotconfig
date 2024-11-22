[[ -e ~/.bun ]] && export BUN_INSTALL=~/.bun
[[ -e ~/.gem ]] && export GEM_HOME=~/.gem
export PARINIT='rTbgqR B=.,?_A_a Q=_s>|'
export EDITOR=vim
export RIPGREP_CONFIG_PATH=~/.config/ripgrep/rc
for d in ~{,/src}/cosmo; do
  if [ -e $d ]; then
    export COSMO=$d
    break
  fi
done

# le sigh...
export CLOUDSDK_PYTHON_SITEPACKAGES=1

# le somewhat heavier sigh...
if [[ $0[1] = - && $SHELL != **/zsh* ]]; then
  () {
    local newshell=$1
    [[ -n $newshell ]] && {
      echo zsh: \$SHELL: \""$SHELL"\" → \""$newshell"\"
      SHELL=$newshell
    }
  } "$(whence -p ${0#-})" >&2
fi

if [[ -d ~/.pyenv/bin ]]; then
  export PYENV_ROOT=~/.pyenv
  path+=(~/.pyenv/bin)

  # slightly saner version of `eval "$(pyenv init -)"`...
  path=(~/.pyenv/shims $path)
  export PYENV_SHELL=zsh
  source ~/.pyenv/completions/pyenv.zsh
  command pyenv rehash 2>/dev/null
  pyenv() {
    local command
    command="${1:-}"
    if [ "$#" -gt 0 ]; then
      shift
    fi

    case "$command" in
    activate|deactivate|rehash|shell)
      eval "$(pyenv "sh-$command" "$@")"
      ;;
    *)
      command pyenv "$command" "$@"
      ;;
    esac
  }
fi

typeset -U path
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
path+=(/{usr/local/go,opt/cosmocc/current}/bin(N))
path+=(~/bin)
path+=(~/{go,.{cargo,bun,gem}}/bin(N))
path+=(~/.local/share/bob/nvim-bin(N))
path+=(~/venv/bin(N))
path+=(~/.npm-packages/bin(N))
path+=(~/google-cloud-sdk/bin(N))

typeset -U manpath
manpath=('')
manpath+=(~/.nix-profile/share/man(N))
manpath+=(~/.local/share/man(N))
export MANPATH

[[ -x $(which nvim) ]] && EDITOR=$(which nvim)
