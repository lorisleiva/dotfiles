#!/usr/bin/env bash

mkd() {
    mkdir -p "$@" && cd "$_";
}

fire() {
    if [ "$1" = "" ]; then
        eval "cd ~/🔥"
    else
        eval "cd ~/🔥 && j $1"
    fi
}

commit() {
    commitMessage="$1"

    if [ "$commitMessage" = "" ]; then
        commitMessage=":pencil: Small changes"
    fi

    git add .
    eval "git commit -a -m '${commitMessage}'"
}

clone() {
    if [[ $1 =~ "hub|lab" ]]; then
        provider="$1"
        shift
    else
        provider="hub"
    fi

    eval "git clone git@git${provider}.com:$1.git $2"
}

new() {
    if [[ $1 =~ "db|database" ]]; then
        mysql -uroot -e "create database $2;"
    fi
}

archive () {
    zip -r "$1".zip -i "$1" ;
}

weather() {
    city="$1"

    if [ -z "$city" ]; then
        city="Alhaurin+el+grande"
    fi

    eval "curl http://wttr.in/${city}"
}

fs() {
    if du -b /dev/null > /dev/null 2>&1; then
        local arg=-sbh;
    else
        local arg=-sh;
    fi
    if [[ -n "$@" ]]; then
        du $arg -- "$@" 2> /dev/null;
    else
        du $arg * .[^.]* 2> /dev/null;
    fi;
}

fso() {
    fs "$@" | gsort -hr
}

json() {
    if [ -t 0 ]; then # argument
        python -mjson.tool <<< "$*" | pygmentize -l javascript;
    else # pipe
        python -mjson.tool | pygmentize -l javascript;
    fi;
}

count() {
    if [ -t 0 ]; then # argument
        wc -l "$*";
    else # pipe
        wc -l;
    fi;
}

digga() {
    dig +nocmd "$1" any +multiline +noall +answer;
}

o() {
    if [ $# -eq 0 ]; then
        open .;
    else
        open "$@";
    fi;
}

tre() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

emptytrash() {
    sudo rm -rf /Volumes/*/.Trashes/*;
    sudo rm -rf ~/.Trash/*;
    sudo rm -rf /private/var/log/asl/*.asl;
    sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent';
    echo 'Whirrrshhhhhhhcccchhh';
}

update() {
    sudo softwareupdate -i -a;
    brew update; 
    brew upgrade; 
    brew cleanup; 
    npm install npm -g;
    npm update -g; 
    sudo gem update --system; 
    sudo gem update; 
    sudo gem cleanup;
}

phpini() {
    php --ini | grep Loaded | cut -d" " -f12
}

xon() {
    sed -i '' 's/^;zend_extension="xdebug\.so"/zend_extension="xdebug\.so"/' `phpini`
}

xoff() {
    sed -i '' 's/^zend_extension="xdebug\.so"/;zend_extension="xdebug\.so"/' `phpini`
}