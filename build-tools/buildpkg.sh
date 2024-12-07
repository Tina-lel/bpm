#!/bin/bash

# Simple tool to build packages for the bpm package manager

if [[ $1 == "ALL" ]]; then
    echo -e "Building all packages\n"
    mkdir -p "pkgs"
    mkdir -p "pkgs/hashes"
    cd "src_pkgs" || {
        echo "Error: could not find src_pkgs folder"
        exit 1
    }
    for i in *; do
        echo -e "Building $i"
        mkdir -p "$i/src"
        mkdir -p "$i/build"
        tar -czf "../pkgs/$i.tar.gz" "$i"
        md5sum "../pkgs/$i.tar.gz" >> "../pkgs/hashes/$i.md5"
    done
    exit 0
fi

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

echo -e "Building $1"
mkdir -p "pkgs"
mkdir -p "pkgs/hashes"
cd "src_pkgs" || {
    echo "Error: could not find src_pkgs folder"
    exit 1
}
mkdir -p "$1/src"
mkdir -p "$1/build"
tar -czf "../pkgs/$1.tar.gz" "$1"
md5sum "../pkgs/$1.tar.gz" >> "../pkgs/hashes/$1.md5"
