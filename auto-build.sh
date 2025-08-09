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

setup_env() {
    echo "clean ..."
    run_command "rm -rf usr"
    run_command "rm -rf ${TARGET_PYTHON_TARBALL}"
    run_command "rm -rf Python-${TARGET_PYTHON_VERSION}"
}

main() {
    setup_color
    setup_env
}

main