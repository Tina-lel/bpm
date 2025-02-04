#!/bin/bash

# This tool builds you the packages and structure for hosting a bpm repository

# NEEDS TO BE REWORKED

case "$1" in
"ALL")
    echo -e "Building all packages\n"
    mkdir -p "pkgs"
    mkdir -p "tmp"
    cd "src_pkgs" || {
        echo "Error: could not find src_pkgs folder"
        exit 1
    }
    for i in *; do
        source "$i/pkg_info"

        mkdir -p "../tmp/$SORT"
        mkdir -p "../pkgs/$SORT"

        echo -e "Building $i"
        mkdir -p "$i/src"
        mkdir -p "$i/build"
        tar -czf "../pkgs/$SORT/$i.tar.gz" "$i"

        echo -e "Writing $i.info"

        echo "DESCRIPTION=\"$DESCRIPTION\"" >"../tmp/$SORT/$i.info"
        echo "VERSION=\"$VERSION\"" >>"../tmp/$SORT/$i.info"
        echo "SORT=\"$SORT\"" >>"../tmp/$SORT/$i.info"
        echo "SIZE=\"$(du --apparent-size -hs --bytes ../pkgs/$SORT/$i.tar.gz | cut -f1)\"" >>"../tmp/$SORT/$i.info"
        echo "SIZE_EXTRACT=\"$(du --apparent-size -hs --bytes $i | cut -f1)\"" >>"../tmp/$SORT/$i.info"
        echo "DEPENDENCIES=(${DEPENDENCIES[@]})" >>"../tmp/$SORT/$i.info"
        echo "COMPILE_DEPENDENCIES=(${COMPILE_DEPENDENCIES[@]})" >>"../tmp/$SORT/$i.info"
        echo "DOWNLOAD=\"$DOWNLOAD\"" >>"../tmp/$SORT/$i.info"
        echo "COMPILE=\"$COMPILE\"" >>"../tmp/$SORT/$i.info"
        #echo "ROOT_FOR_INSTALL=\"$ROOT_FOR_INSTALL\"" >>"../tmp/$SORT/$i.info"
        echo "INSTALLED_FILES=(${INSTALLED_FILES[*]})" >>"../tmp/$SORT/$i.info"

        md5=($(md5sum "../pkgs/$SORT/$i.tar.gz"))
        echo "$md5  $i.tar.gz" >>"../tmp/$SORT/$i.info"
    done

    cd "../tmp" || {
        echo "Error: could not find src_pkgs folder"
        exit 1
    }

    for i in *; do
        echo -e "Creating bpminfo for sort $i"
        tar -czf "../pkgs/$i/BPMINFO.tar.gz" $i/*
    done

    exit 0
    ;;
"CLEAN")
    echo -e "Deleting pkg folder"
    rm -rf pkgs
    echo -e "Deleting tmp folder"
    rm -rf tmp
    exit 0
    ;;
esac

if [[ "$1" == "" ]]; then
    echo -e "Requires name"
    exit 1
fi

if [[ ! -d "src_pkgs/$1" ]]; then
    echo -e "No such folder name in src_pkgs/"
    exit 1
fi

if [[ ! -f "src_pkgs/$1/pkg_info" ]]; then
    echo -e "Not a valid packet (missing pkg_info file)"
    exit 1
fi

source "src_pkgs/$1/pkg_info"

mkdir -p "pkgs"
mkdir -p "pkgs/info"
mkdir -p "pkgs/$SORT"

echo -e "Building $1"
cd "src_pkgs" || {
    echo "Error: could not find src_pkgs folder"
    exit 1
}
mkdir -p "$1/src"
mkdir -p "$1/build"
tar -czf "../pkgs/$SORT/$1.tar.gz" "$1"

echo -e "Writing $1.info"

echo "DESCRIPTION=\"$DESCRIPTION\"" >"../pkgs/info/$1.info"
echo "VERSION=\"$VERSION\"" >>"../pkgs/info/$1.info"
echo "SORT=\"$SORT\"" >>"../pkgs/info/$1.info"
echo "SIZE=\"$(du --apparent-size -hs --bytes ../pkgs/$SORT/$1.tar.gz | cut -f1)\"" >>"../pkgs/info/$1.info"
echo "SIZE_EXTRACT=\"$(du --apparent-size -hs --bytes $1 | cut -f1)\"" >>"../pkgs/info/$1.info"
echo "DEPENDENCIES=\"$DEPENDENCIES\"" >>"../pkgs/info/$1.info"
echo "DOWNLOAD=\"$DOWNLOAD\"" >>"../pkgs/info/$1.info"
echo "COMPILE=\"$COMPILE\"" >>"../pkgs/info/$1.info"
echo "ROOT_FOR_INSTALL=\"$ROOT_FOR_INSTALL\"" >>"../pkgs/info/$1.info"
echo "INSTALLED_FILES=(${INSTALLED_FILES[*]})" >>"../pkgs/info/$1.info"

md5=($(md5sum "../pkgs/$SORT/$1.tar.gz"))
echo "$md5  $1.tar.gz" >>"../pkgs/info/$1.info"
