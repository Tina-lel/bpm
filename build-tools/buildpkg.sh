#!/bin/bash

# Simple tool to build packages for the bpm package manager

if [[ $1 == "ALL" ]]
then
    echo -e "Building all packages\n"
    mkdir -p "pkgs"
    cd "src_pkgs"
    for i in *
    do
        echo -e "Building $i"
        mkdir -p "$i/src"
        mkdir -p "$i/build"
        tar -czf "../pkgs/$i.tar.gz" "$i"
    done
    exit 0
fi

if [[ "$1" == "" ]]
then
    echo -e "Requires name"
    exit 1
fi

if [[ ! -d "src_pkgs/$1" ]]
then
    echo -e "No such folder name in src_pkgs/"
    exit 1
fi

if [[ ! -f "src_pkgs/$1/pkg_info" ]]
then
    echo -e "Not a valid packet (missing pkg_info file)"
    exit 1
fi

echo -e "Building $1"
mkdir -p "pkgs"
mkdir -p "src_pkgs/$1/src"
mkdir -p "src_pkgs/$1/build"
cd "src_pkgs"
tar -czf "../pkgs/$1.tar.gz" "$1"
