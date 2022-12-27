#!/bin/bash
set -e
bc_createUser() {
    read -p "enter username: "  username && sudo echo "%$username ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers && sudo adduser $username && sudo usermod -aG sudo $username su - $username
}
bc_createUser;