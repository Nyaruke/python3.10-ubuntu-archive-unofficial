#!/usr/bin/env bash

TARGET_PYTHON_VERSION="3.10.18"
TARGET_PYTHON_TARBALL="Python-${TARGET_PYTHON_VERSION}.tar.xz"
TARGET_PYTHON_TARBALL_URL="https://www.python.org/ftp/python/${TARGET_PYTHON_VERSION}/${TARGET_PYTHON_TARBALL}"

setup_color() {  # Activate color codes.
    RED="\e[31m"
    GREEN="\e[32m"
    YELLOW="\e[33m"
    BLUE="\e[34m"
    RESET="\e[0m"   
}

run_command() {
    TARGET_CMD="$1"

    echo -e "${GREEN}-> $TARGET_CMD ${RESET}"
    $TARGET_CMD

    TARGET_CMD_EXIT_STAT="$?"
    if [ "$TARGET_CMD_EXIT_STAT" != "0" ]; then
        echo -e "${RED}[!!] ERROR: Command failed. exit code: $TARGET_CMD_EXIT_STAT $RESET"
        exit 1
    fi
}

clean_env() {
    echo "Delete the old directory and source code..."
    run_command "rm -rf usr"
    run_command "rm -rf ${TARGET_PYTHON_TARBALL}"
    run_command "rm -rf Python-${TARGET_PYTHON_VERSION}"
}

install_dep() {
    echo "Installing dependencies ..."
    run_command "sudo apt update -y"
    run_command "sudo apt install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev"
}

prepare_build() {
    echo "Downloading source tarball ${TARGET_PYTHON_TARBALL} ..."
    run_command "wget ${TARGET_PYTHON_TARBALL_URL}"

    echo "Extracting source tarball ..."
    run_command "tar -xJf  ${TARGET_PYTHON_TARBALL}"

    echo "Pathing file ..."
}

run_build() {
    echo "Starting build ..."

    run_command "./configure \
	ax_cv_c_float_words_bigendian=no \
	--prefix=/usr \
	--enable-shared \
	--with-computed-gotos \
	--enable-optimizations \
	--with-lto=no \
	--enable-ipv6 \
	--with-system-expat \
	--with-dbmliborder=gdbm:ndbm \
	--with-system-libmpdec \
	--enable-loadable-sqlite-extensions \
	--without-ensurepip \
	--with-tzpath=/usr/share/zoneinfo"

}

main() {
    setup_color
    clean_env
    install_dep
    prepare_build
}

main