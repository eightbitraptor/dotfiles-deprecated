#!/bin/bash
#
sudo apt install -y stow git vim tmux

stow -t $HOME git
stow -t $HOME vim
