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
    echo "[+] Delete the old directory and source code..."
    run_command "rm -rf /tmp/usr"
    run_command "rm -rf usr"
    run_command "rm -rf ${TARGET_PYTHON_TARBALL}"
    run_command "rm -rf Python-${TARGET_PYTHON_VERSION}"
    run_command "rm -rf DEBIAN"
    run_command "rm -rf python3.10.deb"
}

install_dep() {
    echo "[+] Installing dependencies ..."
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
    gcc \
    make \
    automake \
    autoconf \
    liblzma-dev"
}

prepare_build() {
    echo "[+] Downloading source tarball ${TARGET_PYTHON_TARBALL} ..."
    run_command "wget ${TARGET_PYTHON_TARBALL_URL}"

    echo "[+] Extracting source tarball ..."
    run_command "tar -xJf  ${TARGET_PYTHON_TARBALL}"

    echo "[+] Creating directory ..."
    run_command "mkdir /tmp/usr"
    run_command "mkdir DEBIAN"

    echo "[+] Patching file ..."
    echo -e "${GREEN}-> sed -i -e 's|^#.* /usr/local/bin/python|#!/usr/bin/python|' Python-${TARGET_PYTHON_VERSION}/Lib/cgi.py
 ${RESET}"
    sed -i -e "s|^#.* /usr/local/bin/python|#\!/usr/bin/python|" Python-${TARGET_PYTHON_VERSION}/Lib/cgi.py

}

run_build() {
    echo "[+] Entering directory Python-${TARGET_PYTHON_VERSION}"
    run_command "cd Python-${TARGET_PYTHON_VERSION}"

    echo "[+] Running python${TARGET_PYTHON_VERSION} configure script ..."
    run_command "./configure \
	ax_cv_c_float_words_bigendian=no \
	--prefix=/tmp/usr \
	--enable-shared \
	--with-computed-gotos \
	--enable-optimizations \
	--with-lto=no \
	--enable-ipv6 \
	--with-system-expat \
	--with-dbmliborder=gdbm:ndbm \
	--with-system-libmpdec \
	--enable-loadable-sqlite-extensions \
	--with-ensurepip=install \
	--with-tzpath=/usr/share/zoneinfo"

   echo "[+] Starting build ..."
   run_command "make -j$(nproc)"

   echo "[+] Leaving directory Python-${TARGET_PYTHON_VERSION}"
   run_command "cd .."
}

create_package() {
    echo "[+] Entering directory Python-${TARGET_PYTHON_VERSION}"
    run_command "cd Python-${TARGET_PYTHON_VERSION}"

    echo "[+] Installing compiled file from temp..."
    run_command "make altinstall"
    
    echo "[+] Leaving directory Python-${TARGET_PYTHON_VERSION}"
    run_command "cd .."

    echo "[+] Moving data ..."
    run_command "mv /tmp/usr ./"

    echo "[+] Creating control file ..."
    echo "Package: python3.10" > DEBIAN/control
    echo "Version: ${TARGET_PYTHON_VERSION}" >> DEBIAN/control
    echo "Maintainer: $(id -un)" >> DEBIAN/control
    echo "Architecture: $(dpkg --print-architecture)" >> DEBIAN/control
    echo "Description: Unofficial Python 3.10" >> DEBIAN/control

    echo "[+] Creating target python3.10.deb file"
    run_command "dpkg-deb --build ./ python3.10.deb"
    echo "[+] Done!"

}

install_package() {
    printf "Installing the created package?(y): "
    read ASK_INSTALL
    if  [ "$ASK_INSTALL" != "n" ]; then
        echo ""
        run_command "sudo dpkg -i python3.10.deb"
    fi
}


main() {
    setup_color
    clean_env
    install_dep
    prepare_build
    run_build
    create_package
    install_package
    exit 0
}

main