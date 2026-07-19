#!/bin/sh
printf '\033c\033]0;%s\a' Koi Batter
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Koi Batter.x86_64" "$@"
