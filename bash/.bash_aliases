# ~/.bash_aliases

# Yes, I play league
alias lol='/mnt/c/Riot\ Games/League\ of\ Legends/LeagueClient.exe'
alias exp='explorer.exe'
alias nv='nvim'
alias todo='nvim ~/.scripts/todo.txt'
alias rel='source ~/.bashrc && echo bashrc reloaded'
alias winip='ip route | grep default'
alias nvgd='nv --listen 0.0.0.0:55432'

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

# fzf for a directory
fzfd(){
    find $1 -type d 2>&1 | grep -v "Permission denied" | fzf
}

# fzf and cd to that directory
fcd(){
    TMP=$(fzfd $1)
    cd $TMP
}

# fzf to nvim
fnv(){
    TMP=$(fzf $1)
    nv $TMP
}


# addssh(){
#     eval "$(ssh-agent -s)"
#     ssh-add ~/.ssh/sshgit
# }

