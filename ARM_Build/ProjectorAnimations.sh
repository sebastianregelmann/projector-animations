#!/bin/sh
printf '\033c\033]0;%s\a' ProjectorAnimations
base_path="$(dirname "$(realpath "$0")")"
"$base_path/ProjectorAnimations.arm64" "$@"
