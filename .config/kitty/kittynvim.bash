#!/usr/bin/env bash
sock="unix:/tmp/kittynvim_u$(id -u)"
sock1="p$$.socket"
export KITTYNVIM_SOCKET="${sock}_${sock1}"
kitty --session ~/.config/kitty/kittynvim.conf --listen-on="${sock}_${sock1}"
