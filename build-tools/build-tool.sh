#!/usr/bin/env bash
# buildpkg.sh v2 lol

# Global Variables
export BUILDTOOL_VERSION="0.1"

# Color variables
export RED="\e[1;31m"
export GREEN="\e[1;32m"
export GRAY="\e[1;90m"
export CYAN="\e[1;36m"
export ENDCOLOR="\e[0m"

# Info variables
export SUCCESS="${GRAY}[${GREEN}✓${GRAY}]${ENDCOLOR}"
export ERROR="${RED}Error:${ENDCOLOR}"
export WARNING="${GRAY}[${RED}!${GRAY}]${ENDCOLOR}"
export INFO="${GRAY}[${CYAN}i${GRAY}]${ENDCOLOR}"

# Compiling variables
# TODO: seperate config
WORKING_DIR="workingdir"

COMMON_FLAGS="-g -O3 -pipe"
CFLAGS="${COMMON_FLAGS}"
CPPFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
MAKEFLAGS="-j$(nproc)"
RUSTFLAGS="--release -j $(nproc)"

set -e

# Functions

dir_check() {
    if [[ ! -f "$(pwd)/$(basename "$0")" ]]; then
        echo -e "${ERROR} Please run $(basename "$0") only from its own directory."
        exit 1
    fi
}

check_args() {
    case "$1" in
        "all")
            shift
            build_all "$@"
            ;;
        "clean")
            clean_all
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

pkg_validity_check() {
    if [[ ! -f "$1/pkg_info" ]]; then
        echo -e "${ERROR} Not a valid packet (missing pkg_info file)"
        exit 1
    fi
}

pkg_build() {
    source "$1/pkg_info"

    mkdir -p "../tmp/$SORT"
    mkdir -p "../pkgs/$SORT"

    mkdir -p "$1/src"
    mkdir -p "$1/build"

    tar -czf "../pkgs/$SORT/$1.tar.gz" "$1"
}

pkg_info() {
    source "$1/pkg_info"

    echo "DESCRIPTION=\"$DESCRIPTION\"" >"../tmp/$SORT/$1.info"
    echo "VERSION=\"$VERSION\"" >>"../tmp/$SORT/$1.info"
    echo "SORT=\"$SORT\"" >>"../tmp/$SORT/$1.info"
    echo "SIZE=\"$(du --apparent-size -hs --bytes ../pkgs/$SORT/$1.tar.gz | cut -f1)\"" >>"../tmp/$SORT/$1.info"
    echo "SIZE_EXTRACT=\"$(du --apparent-size -hs --bytes $1 | cut -f1)\"" >>"../tmp/$SORT/$1.info"
    echo "DEPENDENCIES=(${DEPENDENCIES[@]})" >>"../tmp/$SORT/$1.info"
    echo "COMPILE_DEPENDENCIES=(${COMPILE_DEPENDENCIES[@]})" >>"../tmp/$SORT/$1.info"
    echo "DOWNLOAD=\"$DOWNLOAD\"" >>"../tmp/$SORT/$1.info"
    echo "COMPILE=\"$COMPILE\"" >>"../tmp/$SORT/$1.info"
    echo "INSTALLED_FILES=(${INSTALLED_FILES[*]})" >>"../tmp/$SORT/$1.info"

    md5=($(md5sum "../pkgs/$SORT/$1.tar.gz"))
    echo "$md5  $1.tar.gz" >>"../tmp/$SORT/$1.info"
}

pkg_bpminfo() {
    tar -czf "../pkgs/$1/BPMINFO.tar.gz" $1/*
}

pkg_compilecheck() {
    source "$1/pkg_info"
    if [[ "$COMPILE" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

build_all() {
    case "$1" in
        "--build-binaries")
            echo -e "${WARNING} Compiling Packages\n"
            build_binaries="true"
            ;;
        "")
            ;;
        *)
            echo -e "${ERROR} '$1' not understood."
            exit 1
            ;;
    esac
    echo -e "${INFO} Building all packages\n"
    mkdir -p "pkgs"
    mkdir -p "tmp"

    cd "src_pkgs" || {
        echo "${ERROR} could not find src_pkgs folder"
        exit 1
    }

    package_ammount="$(ls -1 | wc -l)"

    counter="1"
    for package in *; do
        echo -e "\e[1A\e[2K${INFO} Checking validity of $package... [$counter/$package_ammount]"
        pkg_validity_check "$package"
        counter="$(( $counter + 1 ))"
    done
    echo -e "\e[1A\e[2K${SUCCESS} Checking validity\n"

    if [[ "$build_binaries" == "true" ]]; then

        compile_array=()

        counter="1"
        for package in *; do
            echo -e "\e[1A\e[2K${INFO} Checking if $package needs to be compiled... [$counter/$package_ammount]"
            if pkg_compilecheck "$package"; then
                compile_array+=("$package")
            fi
            counter="$(( $counter + 1 ))"
        done
        echo -e "\e[1A\e[2K${SUCCESS} Compile Check"
        echo -e "${INFO} Packages to compile: ${compile_array[@]}\n"

    fi

    counter="1"
    for package in *; do
        echo -e "\e[1A\e[2K${INFO} Compressing $package... [$counter/$package_ammount]"
        pkg_build "$package"
        counter="$(( $counter + 1 ))"
    done
    echo -e "\e[1A\e[2K${SUCCESS} Compressing\n"

    counter="1"
    for package in *; do
        echo -e "\e[1A\e[2K${INFO} Writing info for $package... [$counter/$package_ammount]"
        pkg_info "$package"
        counter="$(( $counter + 1 ))"
    done
    echo -e "\e[1A\e[2K${SUCCESS} Writing info\n"

    cd ../tmp || {
        echo "${ERROR} could not find tmp folder"
        exit 1
    }

    sort_ammount="$(ls -1 | wc -l)"

    counter="1"
    for sort in *; do
        echo -e "\e[1A\e[2K${INFO} Writing bpminfo for $sort... [$counter/$sort_ammount]"
        pkg_bpminfo "$sort"
        counter="$(( $counter + 1 ))"
    done
    echo -e "\e[1A\e[2K${SUCCESS} Writing bpminfo"
}

clean_all() {
    echo -e "${INFO} Deleting pkg folder"
    rm -rf pkgs
    echo -e "${INFO} Deleting tmp folder"
    rm -rf tmp
    exit 0
}

help_message() {
    echo -e "usage: $(basename "$0") <operation>"
    echo -e "operations:"
    echo -e "   build-tool.sh all [--build-binaries]"
    echo -e "   build-tool.sh clean"
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

dir_check
check_args "$@"
