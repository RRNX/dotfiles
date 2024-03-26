if status is-interactive
    # Commands to run in interactive sessions can go here
end
set PATH $PATH:/home/hannes/.local/bin
zoxide init fish | source
alias ls="ls --color=auto"
alias ll="ls -la"
alias cd=z
alias vim=nvim
set -g fish_greeting
neofetch
