export ZDOTDIR="$HOME/.config/zsh"
[[ ! -o interactive ]] && TRAPUSR1(){}

if [[ -f "$ZDOTDIR/.zshenv.local" ]]; then
  source "$ZDOTDIR/.zshenv.local"
fi

export LANG=${LANG:-en_US.UTF-8}
