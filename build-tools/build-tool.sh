#!/usr/bin/env bash
# buildpkg.sh v2 lol

# Global Variables
export BUILDTOOL_VERSION="0.1"

# Color variables
export RED="\e[1;31m"
export GREEN="\e[1;32m"
export GRAY="\e[1;90m"
export ENDCOLOR="\e[0m"

# Info variables
export SUCCESS="${GRAY}[${GREEN}✓${GRAY}]${ENDCOLOR}"
export ERROR="${RED}Error:${ENDCOLOR}"
export WARNING="${GRAY}[${RED}!${GRAY}]${ENDCOLOR}"

# Functions
check_args() {
    case "$1" in
        "all")
            build_all
            ;;
        "help")
            help_message
            ;;
        "version")
            version_message
            ;;
        "")
            echo -e "${ERROR} no operation specified. Use $(basename "$0") help"
            exit 1
            ;;
        *)
            echo -e "${ERROR} unrecognized option '$1'. Use $(basename "$0") help"
            exit 1
            ;;
    esac
}

build_all() {
    echo foo
}

help_message() {
    echo -e "usage: $(basename "$0") <operation>"
    echo -e "operations:"
    echo -e "   build-tool.sh all"
    echo -e "   build-tool.sh help"
    echo -e "   build-tool.sh version"
}

version_message() {
    echo -e ""
    echo -e "───▄▄▄         bpm build-tool.sh v$BUILDTOOL_VERSION - bash 5.2.37"
    echo -e "─▄▀░▄░▀▄       Copyright (C) 2024-present Tina-lel"
	echo -e "─█░█▄▀░█       Copyright (C) 2024-present Justus0405"
    echo -e "─█░▀▄▄▀█▄█▄▀"
    echo -e "▄▄█▄▄▄▄███▀    This program may be freely redistributed under"
    echo -e "               the terms of the GNU General Public License v2.0"
    echo -e ""
    exit 0
}

# Program start

check_args "$@"
