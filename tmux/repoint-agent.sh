sid=$1
sock=$(tmux show-environment -t "$sid" SSH_AUTH_SOCK 2>/dev/null)
case $sock in SSH_AUTH_SOCK=*) sock=${sock#SSH_AUTH_SOCK=}; [ -S "$sock" ] \
  && ln -sfn "$sock" "$HOME/.ssh/agent-tmux-${sid#\$}.sock" ;; esac
