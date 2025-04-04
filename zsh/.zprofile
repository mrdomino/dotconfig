export TZ=America/Los_Angeles
export EDITOR=vim
export PARINIT='rTbgqR B=.,?_A_a Q=_s>|'
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

[[ -x $(which nvim) ]] && EDITOR=nvim
