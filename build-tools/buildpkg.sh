#!/bin/bash

# Simple tool to build packages for the bpm package manager

case "$1" in
"ALL")
    echo -e "Building all packages\n"
    mkdir -p "pkgs"
    mkdir -p "pkgs/info"
    cd "src_pkgs" || {
        echo "Error: could not find src_pkgs folder"
        exit 1
    }
    for i in *; do
        source "$i/pkg_info"

        mkdir -p "../pkgs/$SORT"

        echo -e "Building $i"
        mkdir -p "$i/src"
        mkdir -p "$i/build"
        tar -czf "../pkgs/$SORT/$i.tar.gz" "$i"

        echo -e "Writing $i.info"

        echo "DESCRIPTION=\"$DESCRIPTION\"" >> "../pkgs/info/$i.info"
        echo "SORT=\"$SORT\"" >> "../pkgs/info/$i.info"
        echo "SIZE=\"$(du --apparent-size -hs ../pkgs/$SORT/$i.tar.gz | cut -f1)\"" >> "../pkgs/info/$i.info"
        echo "SIZE_EXTRACT=\"$(du --apparent-size -hs $i | cut -f1)\"" >> "../pkgs/info/$i.info"
        echo "DEPENDENCIES=\"$DEPENDENCIES\"" >> "../pkgs/info/$i.info"
        echo "DOWNLOAD=\"$DOWNLOAD\"" >> "../pkgs/info/$i.info"
        echo "COMPILE=\"$COMPILE\"" >> "../pkgs/info/$i.info"
        echo "INSTALLED_FILES=(${INSTALLED_FILES[@]})" >> "../pkgs/info/$i.info"

        md5=($(md5sum "../pkgs/$SORT/$i.tar.gz"))
        echo "$md5  $i.tar.gz" >> "../pkgs/info/$i.info"
    done
    exit 0
    ;;
"CLEAN")
    echo -e "Deleting pkg folder"
    rm -rf pkgs
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

echo "DESCRIPTION=\"$DESCRIPTION\"" >> "../pkgs/info/$1.info"
echo "SORT=\"$SORT\"" >> "../pkgs/info/$1.info"
echo "SIZE=\"$(du --apparent-size -hs ../pkgs/$SORT/$1.tar.gz | cut -f1)\"" >> "../pkgs/info/$1.info"
echo "SIZE_EXTRACT=\"$(du --apparent-size -hs $1 | cut -f1)\"" >> "../pkgs/info/$1.info"
echo "DEPENDENCIES=\"$DEPENDENCIES\"" >> "../pkgs/info/$1.info"
echo "DOWNLOAD=\"$DOWNLOAD\"" >> "../pkgs/info/$1.info"
echo "COMPILE=\"$COMPILE\"" >> "../pkgs/info/$1.info"
echo "INSTALLED_FILES=(${INSTALLED_FILES[@]})" >> "../pkgs/info/$1.info"

md5=($(md5sum "../pkgs/$SORT/$1.tar.gz"))
echo "$md5  $1.tar.gz" >> "../pkgs/info/$1.info"
