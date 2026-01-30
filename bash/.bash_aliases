# ~/.bash_aliases

# Yes, I play league
alias exp='explorer.exe'
alias nv='nvim'
alias todo='nvim ~/.scripts/todo.txt'
alias rel='source ~/.bashrc'

# Fetch the gitignore file template for a project
gitignore(){
    curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/master/"$1".gitignore
}

# Quickly fetch some file on git
gitget(){
    curl -O https://raw.githubusercontent.com/"$1"/"$2"/"$3"/"$4"
}

# Go to the mounted disk from WSL
cdd(){
    cd /mnt/c/Users/afons/Documents/Dev/"$1"
}

# Get a default makefile
makefile(){
    cp ~/.scripts/resx/makefile $(pwd)/$1/makefile
}

alias ff='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias fnv='nvim "$(fzf --height 40% --reverse --preview "bat --style=numbers --color=always {}" --preview-window=up:30%)"'
alias fcd='cd "$(find . -type d -o -type l -xtype d | fzf --height 40% --reverse --preview "ls -l {}")"'

