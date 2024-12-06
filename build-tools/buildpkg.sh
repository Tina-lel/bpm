#!/bin/bash

# Simple tool to build packages for the bpm package manager

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

echo -e "Creating package"
mkdir -p "src_pkgs/$1/src"
mkdir -p "src_pkgs/$1/build"
mkdir -p "pkgs/"
tar -czf "pkgs/$1.tar.gz" "src_pkgs/$1"
