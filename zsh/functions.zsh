#!/usr/bin/env bash

new() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: new [db <name> | file/dir ...]"
        return 1
    fi

    # [db|database <name>] creates a new MySQL database with the given name.
    if [[ $# -eq 2 && $1 =~ ^(db|database)$ ]]; then
        mysql -uroot -e "create database $2;" && echo "Database '$2' created."
    # [file/dir ...] creates new files or directories.
    else
        for target in "$@"; do
            if [[ "$target" == */ ]]; then
                mkdir -p "$target"
            else
                local dir="$(dirname "$target")"
                [[ "$dir" != "." ]] && mkdir -p "$dir"
                touch "$target"
            fi
        done
    fi
}

daemonize() {
    "$@" > /dev/null 2>&1 & disown
}

archive() {
    zip -r "$1".zip -i "$1"
}

fs() {
    if du -b /dev/null >/dev/null 2>&1; then
        local arg=-sbh
    else
        local arg=-sh
    fi
    if [[ -n "$@" ]]; then
        du $arg -- "$@" 2>/dev/null
    else
        du $arg * .[^.]* 2>/dev/null
    fi
}

fso() {
    fs "$@" | gsort -hr
}

json() {
    if [ -t 0 ]; then # argument
        python -mjson.tool <<<"$*" | pygmentize -l javascript
    else # pipe
        python -mjson.tool | pygmentize -l javascript
    fi
}

count() {
    if [ -t 0 ]; then # argument
        wc -l "$*"
    else # pipe
        wc -l
    fi
}

digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

o() {
    if [ $# -eq 0 ]; then
        open .
    else
        open "$@"
    fi
}

c() {
    if [ $# -eq 0 ]; then
        code .
    else
        code "$@"
    fi
}

pstorm() {
    if [ $# -eq 0 ]; then
        phpstorm .
    else
        phpstorm "$@"
    fi
}

tre() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

emptytrash() {
    sudo rm -rf /Volumes/*/.Trashes/*
    sudo rm -rf ~/.Trash/*
    sudo rm -rf /private/var/log/asl/*.asl
    sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'
    echo 'Whirrrshhhhhhhcccchhh'
}

phpini() {
    php --ini | grep Loaded | cut -d" " -f12
}

xon() {
    sed -i '' 's/^;zend_extension="xdebug\.so"/zend_extension="xdebug\.so"/' $(phpini)
}

xoff() {
    sed -i '' 's/^zend_extension="xdebug\.so"/;zend_extension="xdebug\.so"/' $(phpini)
}

phpunitc() {
    xon
    phpunit --coverage-html build
    xoff
}

scheduler() {
    while :; do
        php artisan schedule:run
        echo "Sleeping 60 seconds..."
        sleep 60
    done
}

homestead() {
    (cd ~/Homestead && vagrant $*)
}

php80() {
    brew unlink php@8.1
    brew link --force php@8.0
}

php81() {
    brew unlink php@8.0
    brew link --force php@8.1
}
