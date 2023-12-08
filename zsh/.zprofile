export BUN_INSTALL=~/.bun
export PARINIT='rTbgqR B=.,?_A_a Q=_s>|'
export EDITOR=vim

push_path() {
  [[ -d "$@" ]] && path+=("$@")
}
typeset -U path
push_path /usr/local/go/bin
push_path /opt/cosmocc/bin
push_path ~/bin
push_path ~/.local/share/bob/nvim-bin
push_path ~/go/bin
push_path ~/.cargo/bin
push_path $BUN_INSTALL/bin
unfunction push_path

push_manpath() {
  [[ -d "$@" ]] && manpath+=("$@")
}
push_manpath ~/.nix-profile/share/man
unfunction push_manpath

[[ -x $(which nvim) ]] && EDITOR=$(which nvim)
