#!/bin/bash
set -e
bc_action() {
    read -p "enter Domain: "  DOMAIN
    cd /var/www/$DOMAIN && mkdir actions-runner && cd actions-runner
    SOURCE=${BASH_SOURCE[0]}
    while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
        SOURCE=$(readlink "$SOURCE")
        [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
    sudo chmod -R 777 $DIR
    read -p "enter URL and token: "  URL
    curl -o actions-runner-osx-x64-2.300.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.300.0/actions-runner-osx-x64-2.300.0.tar.gz
    echo "623275e630bf936047bfab4e588f92213bd4481a8234f0a639bbeec01e678060  actions-runner-osx-x64-2.300.0.tar.gz" | shasum -a 256 -c
    sudo tar xzf ./actions-runner-osx-x64-2.300.0.tar.gz
    ./config.sh $URL
    sudo ./svc.sh install && sudo ./svc.sh start && sudo ./svc.sh status
}
bc_action;