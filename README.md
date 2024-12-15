# Bash Package Manager

<p align="left">
    <!-- Stars Badge -->
	<a href="https://github.com/Tina-lel/bpm/stargazers"><img src="https://img.shields.io/github/stars/Tina-lel/bpm?colorA=1e1e2e&colorB=b7bdf8&style=for-the-badge"></a>
    <!-- Issues Badge -->
	<a href="https://github.com/Tina-lel/bpm/issues"><img src="https://img.shields.io/github/issues/Tina-lel/bpm?colorA=1e1e2e&colorB=f5a97f&style=for-the-badge"></a>
    <!-- Contributors Badge -->
	<a href="https://github.com/Tina-lel/bpm/contributors"><img src="https://img.shields.io/github/contributors/Tina-lel/bpm?colorA=1e1e2e&colorB=a6da95&style=for-the-badge"></a>
</p>

<p align="left">
    <!-- License Badge -->
    <a href="https://github.com/Tina-lel/bpm/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Tina-lel/bpm?logo=Github&colorA=1e1e2e&colorB=cba6f7&style=for-the-badge"></a>
    <!-- Version Badge -->
    <a href="https://github.com/Tina-lel/bpm/blob/main/bpm"><img src="https://img.shields.io/badge/Version-0.1-blue?colorA=1e1e2e&colorB=cdd6f4&style=for-the-badge"></a>
</p>

A ~fully functioning~ package manager for linux written in bash

# Information

> [!NOTE]
> This is work in progress,
> proceed with caution.

# Installation

```shell
git clone https://github.com/Tina-lel/bpm
cd bpm/
 ./install.sh
```

# Usage

```shell
usage:  bpm <operation> [...]
operations:
    bpm add     [package(s)]
    bpm del     [package(s)]
    bpm update
    bpm upgrade
    bpm config
    bpm search  [package]
    bpm info    [package]
    bpm list
    bpm index
    bpm clean
    bpm depclean
    bpm help
    bpm version

```

# Todo

## Frontend

- [X] File Checksums
- [X] Full Tool Arguments
- [X] Local packages list
- [X] ~/.config/bpm.conf for various stuff
- [X] Search by package name and description
- [X] Update function with new version display
- [X] Installed, Upgraded, Removed Packages net size
- [ ] x86 64bit, 32bit and arm support

## Backend

- [X] Package builder script with checksum generation
