# /etc/bash.bashrc — system-wide bash config
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi
alias ls='ls --color=auto'
alias ll='ls -la'
alias grep='grep --color=auto'