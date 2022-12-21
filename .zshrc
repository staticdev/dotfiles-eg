# Set up the prompt
autoload -Uz promptinit vcs_info
precmd() {
    vcs_info
    if [[ -n ${vcs_info_msg_0_} ]]; then
        # vcs_info found something (the documentation got that backwards
        # STATUS line taken from https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/git.zsh
        STATUS=$(command git status --porcelain 2> /dev/null | tail -n1)
        if [[ -n $STATUS ]]; then
            PROMPT='%F{green}%n%F{orange}@%F{yellow}%m:%F{6}%3~%f %F{red}${vcs_info_msg_0_} %f%# '
        else
            PROMPT='%F{green}%n%F{orange}@%F{yellow}%m:%F{6}%3~%f %F{green}${vcs_info_msg_0_} %f%# '
        fi
    else
        # nothing from vcs_info
        PROMPT='%F{green}%n%F{orange}@%F{yellow}%m:%F{6}%3~%f %# '
    fi
}
promptinit
zstyle ':vcs_info:git:*' formats '> %b'
setopt histignorealldups sharehistory prompt_subst

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Custom $PATH with extra locations.
export PATH=$PATH:~/.local/bin

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Git aliases.
alias gs='git status'
alias gc='git commit'
alias gp='git pull --rebase'
alias gcam='git commit -am'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

alias gps='gitp status'
alias gpc='gitp commit'
alias gpp='gitp pull --rebase'
alias gpcam='gitp commit -am'

# some more ls aliases
alias c='code'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias k='kubectl'
alias tm='tmux'


# thefuck script
eval $(thefuck --alias)
eval $(thefuck --alias FUCK)

# Use modern completion system
autoload -Uz compinit
compinit
source <(kubectl completion zsh)

# Git upstream branch syncer.
# Usage: gsync main (checks out main, pull upstream, push origin).
function gsync() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a branch."
     return 0
 fi

 BRANCHES=$(git branch --list $1)
 if [ ! "$BRANCHES" ] ; then
    echo "Branch $1 does not exist."
    return 0
 fi

 git checkout "$1" && \
 git pull upstream "$1" && \
 git push origin "$1"
}

# Enter a running Docker container.
function denter() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a container ID or name."
     return 0
 fi

 docker exec -it $1 bash
 return 0
}

# Delete a given line number in the known_hosts file.
knownrm() {
 re='^[0-9]+$'
 if ! [[ $1 =~ $re ]] ; then
   echo "error: line number missing" >&2;
 else
   sed -i '' "$1d" ~/.ssh/known_hosts
 fi
}

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

source ~/pyenv/.pyenvrc
