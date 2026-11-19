#!/usr/bin/env bash
# buildpkg.sh v2 lol

# Global Variables
export BUILDTOOL_VERSION="0.1"
export BUILD_TOOL_PATH="$(pwd)"

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
WORKING_DIR="$BUILD_TOOL_PATH/workingdir"

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

    mkdir -p "$BUILD_TOOL_PATH/tmp/$SORT"
    mkdir -p "$BUILD_TOOL_PATH/pkgs/$SORT"

    mkdir -p "$1/src"
    mkdir -p "$1/build"

    tar -czf "$BUILD_TOOL_PATH/pkgs/$SORT/$1.tar.gz" "$1"
}

pkg_info() {
    source "$1/pkg_info"

    echo "DESCRIPTION=\"$DESCRIPTION\"" >"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
    echo "VERSION=\"$VERSION\"" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
    echo "SORT=\"$SORT\"" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
    echo "SIZE=\"$(du --apparent-size -hs --bytes $BUILD_TOOL_PATH/pkgs/$SORT/$1.tar.gz | cut -f1)\"" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
    echo "SIZE_EXTRACT=\"$(du --apparent-size -hs --bytes $1 | cut -f1)\"" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
    echo "DEPENDENCIES=(${DEPENDENCIES[@]})" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
    echo "COMPILE_DEPENDENCIES=(${COMPILE_DEPENDENCIES[@]})" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
    echo "DOWNLOAD=\"$DOWNLOAD\"" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
    echo "COMPILE=\"$COMPILE\"" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
    #echo "INSTALLED_FILES=(${INSTALLED_FILES[@]})" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"

    md5=($(md5sum "$BUILD_TOOL_PATH/pkgs/$SORT/$1.tar.gz"))
    echo "$md5  $1.tar.gz" >>"$BUILD_TOOL_PATH/tmp/$SORT/$1.info"
}

pkg_bpminfo() {
    tar -czf "$BUILD_TOOL_PATH/pkgs/$1/BPMINFO.tar.gz" $1/*
}

pkg_compilecheck() {
    source "$1/pkg_info"
    if [[ "$COMPILE" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

pkg_compile() {
    PKG_DIR="$WORKING_DIR/cache/$1"
    PREFIX="$WORKING_DIR/usr"

    cp -r "$BUILD_TOOL_PATH/src_pkgs/$1" "$PKG_DIR"
    mkdir -p "$PKG_DIR/src"
    mkdir -p "$PKG_DIR/build"

    source "$PKG_DIR/pkg_info"

    if [[ "$DOWNLOAD" == "true" ]]; then
        DOWNLOAD_SRC
    fi
    COMPILE_SRC
    INSTALL_PKG

    mkdir -p "$WORKING_DIR/src_pkgs-bin/${1}_bin/build"
    mv "$PREFIX/"* "$WORKING_DIR/src_pkgs-bin/${1}_bin/build/"

    echo "# Package info (${1}_bin)" >"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
    echo "# Compiled by build-tool on $(date +%Y-%m-%d\ %H:%m)" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
    echo "DESCRIPTION=\"$DESCRIPTION (Binary)\"" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
    echo "VERSION=\"${VERSION}-bin\"" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
    echo "SORT=\"bin\"" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
    echo "COMPILE_DEPENDENCIES=()" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
    echo "DEPENDENCIES=(${DEPENDENCIES[@]})" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
    echo "DOWNLOAD=\"false\"" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
    echo "COMPILE=\"false\"" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"

    grep "ROOT_FOR_INSTALL=\"" "$BUILD_TOOL_PATH/src_pkgs/$1/pkg_info" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
    grep "PREFIX=\"" "$BUILD_TOOL_PATH/src_pkgs/$1/pkg_info" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"

    echo "INSTALLED_FILES=(${INSTALLED_FILES[@]})" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"

    echo -e "INSTALL_PKG() {\n    cp -fr \$PKG_DIR/build/* \$PREFIX/\n}" >>"$WORKING_DIR/src_pkgs-bin/${1}_bin/pkg_info"
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

    cd "$BUILD_TOOL_PATH/src_pkgs" || {
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

        mkdir -p "$WORKING_DIR/cache"
        mkdir -p "$WORKING_DIR/usr"
        mkdir -p "$WORKING_DIR/src_pkgs-bin"

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

        cd "$WORKING_DIR/cache" || {
            echo -e "${ERROR} could not enter temp path"
            exit 1
        }

        counter="1"
        for package in "${compile_array[@]}"; do
            echo -e "\e[1A\e[2K${INFO} Compiling $package... [$counter/${#compile_array[@]}]"
            pkg_compile "$package"
            counter="$(( $counter + 1 ))"
        done
        echo -e "\e[1A\e[2K${SUCCESS} Compiling\n"

        cd "$BUILD_TOOL_PATH/src_pkgs" || {
            echo "${ERROR} could not find src_pkgs folder"
            exit 1
        }

    fi

    while :; do
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

        if [[ "$build_binaries" == "true" && "$compiled_pkgs" != "true" ]]; then
            cd "$WORKING_DIR/src_pkgs-bin" || {
                echo "${ERROR} could not find src_pkgs-bin folder"
                exit 1
            }
            compiled_pkgs="true"
            continue
        fi

        break
    done

    cd "$BUILD_TOOL_PATH/tmp" || {
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
    echo -e "${INFO} Deleting workingdir folder"
    rm -rf workingdir
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
