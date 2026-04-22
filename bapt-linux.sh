#!/bin/bash
#WARNING: If you change the CONFIG_PATH, please make sure the folder exists.
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

CONFIG_PATH=$HOME/.bapt/bapt-cfg.conf
DATA_PATH=$HOME/.bapt
TEMP_PATH=/tmp/bapt
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

precheck() {
    echo BAPT Pre-check
    echo Please wait...
    echo Making directories...
    echo "(~/.bapt)"
    mkdir -p $DATA_PATH 2> /dev/null #Comment this out if you don't want any folder to be created
    echo "(/tmp/bapt)"
    mkdir -p $TEMP_PATH 2> /dev/null
    echo "Creating files..."
    echo "(~/.bapt/bapt-cfg.conf)"
    touch $CONFIG_PATH
    echo Finished.
    echo Please wait...
    sleep 5
    clear
}

settings() {
    clear
    if [[ "$PACKAGE_MANAGER" == "bapt" ]]; then echo -e "${RED}Error: Package Manager is invalid! Please select another one.${NC}"; fi
    echo bapt Settings
    echo =================
    echo "[1] Package Manager: $PACKAGE_MANAGER"
    echo "[H]: Help"
    echo "[R]: Reset settings"
    echo "[E]: Exit"
    echo -n "Option:"
    read setopt
    if [[ "$setopt" == "1" ]]; then
        clear
        echo "bapt Settings - Package Manager"
        echo =================
        echo "[1] apt (recommended)"
        echo "[2]: bapt (NOT WORKED ON)"
        echo "[B]: Back"
        echo -n "Option:"
        read pkgmgropt
        if [[ "$pkgmgropt" == "1" ]]; then
            echo 1
            #: > $CONFIG_PATH #NOTE: Uncomment this when there are more options so it gets cleared
            echo "PACKAGE_MANAGER=apt" > $CONFIG_PATH
            echo Refreshing config...
            source $CONFIG_PATH
            clear
            settings
        elif [[ "$pkgmgropt" == "2" ]]; then
            echo "PACKAGE_MANAGER=bapt" > $CONFIG_PATH
            echo Refreshing config...
            source $CONFIG_PATH
            clear
            settings
        elif [[ "${pkmgropt,,}" == "b" ]]; then
            settings
        else
            echo Invalid option!
            settings
        fi
    elif [[ "${setopt,,}" == "e" ]]; then
        exit 0
    elif [[ "${setopt,,}" == "r" ]]; then
        : > $CONFIG_PATH
        echo "PACKAGE_MANAGER=apt" >> $CONFIG_PATH
        echo Reset all values. Please re-run the app.
    elif [[ "${setopt,,}" == "h" ]]; then
        clear
        echo "bapt Settings - Help Menu"
        echo "=================="
        echo "[1] Changes the package manager (e.g apt, flatpak)"
        echo "[H]: Opens this help menu."
        echo "[R]: Resets the settings to the default values"
        echo "[E]: Exits settings"
        echo "[B]: Goes back to the previous menu."
        echo "Option: Enter the option number/letter here and press enter."
        echo Press enter to return back...
        read pause
        settings
    else
        echo Invalid Option!
        settings
    fi
}

help() {
    echo "Help Menu (--help)"
    echo "="
    echo "--help: Open this help menu."
    echo "Usage: ./bapt.sh --help"
    echo "="
    echo "--settings: Open the settings menu."
    echo "Usage: ./bapt.sh --settings"
    echo "="
    echo "install: Install a package."
    echo "Usage: ./bapt.sh install [PACKAGE]"
    echo "Example: ./bapt.sh install mousepad"
    echo "="
    echo "remove: Removes a package."
    echo "Usage:./bapt.sh remove [PACKAGE]"
    echo "Example: ./bapt.sh remove gimp"
    echo "="
    echo "--fix-sources: Fixes /etc/apt/sources.list"
    echo "Usage: ./bapt.sh --fix-sources"
    echo "Usage (2): ./bapt.sh --fix-sources -r"
    echo "Use -r to restore your previous sources.list if something goes wrong."
    echo "="
    echo "search: searches apt for a package"
    echo "Usage: ./bapt.sh search [term]"
    echo "Example:./bapt.sh search kate"
}

installer() {
    echo This will require sudo! Please enter your password.
    sudo echo Authentication was complete.
    sudo apt install $PACKAGE
    status=$?
    if [ "$status" -eq 0 ]; then
        clear
        echo -e "${GREEN}$PACKAGE was installed.${NC}"
    else
        clear
        echo -e "${RED}[!!!] $PACKAGE was not installed."
        echo -e "apt returned error code $status ${NC}"
    fi
}

remover() {
    echo This will require sudo! Please enter your password.
    sudo echo Authentication was complete.
    sudo apt remove $PACKAGE
    status=$?
    if [ "$status" -eq 0 ]; then
        clear
        echo -e "${GREEN}$PACKAGE was removed.${NC}"
    else
        clear
        echo -e "${RED}[!!!] $PACKAGE was not removed."
        echo -e "apt returned error code $status ${NC}"
    fi
}

searcher() {
    if apt-cache search "$1" | \grep -q "$1"; then
        echo "Search query: $1 - Results"
        echo "============="
        apt-cache search "$1" | \grep -i  "$1"
        echo "============="
        echo "To install a package you found, run ./bapt.sh install [PKG]"
        exit 0
    else
        echo "Search query: $1 - Results"
        echo "============="
        echo -e "${RED}No results found for: $1${NC}"
        echo "============="
        echo "To install a package you found, run ./bapt.sh install [PKG]"
        exit 1
    fi
}

sourcefix() {
    clear
    echo "/etc/apt/sources.list fix"
    echo "==============="
    echo "DO NOT pick the wrong distrubition, or it could break your system."
    echo "If your distrubition is NOT here, it means it is not supported as of right now."
    echo "==============="
    echo "[1] elementaryOS 8: circe"
    echo "[2]: Debian 13: trixie"
    echo "[I]: Get info about sources"
    echo "[E]: Exit"
    echo -n "Choose: "
    read sourceopt
    if [[ "$sourceopt" == "1" ]]; then
        echo This operation requires sudo. Please enter your password.
        sudo echo Authentication Complete
        echo Creating backup of sources.list...
        mkdir -p "$DATA_PATH/sourcebackup"
        sudo cp -f /etc/apt/sources.list "$DATA_PATH/sourcebackup/sources_($TIMESTAMP).list.bak"
        echo Success!
        echo Clearing sources.list...
        sudo sh -c ': > /etc/apt/sources.list'
        echo Success!
        echo Writing to sources.list...
        sudo sh -c 'echo "# deb cdrom:[elementary OS 8.0 _circe_ - stable amd64 (20250314)]/ noble contrib main non-free" > /etc/apt/sources.list'
        echo "Wrote # deb cdrom:[elementary OS 8.0 _circe_ - stable amd64 (20250314)]/ noble contrib main non-free"
        sudo sh -c 'echo "deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse" >> /etc/apt/sources.list'
        echo "Wrote deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse"
        sudo sh -c  'echo "deb-src http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse" >> /etc/apt/sources.list'
        echo "Wrote deb-src http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse"
        sudo sh -c 'echo "deb http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list'
        echo "Wrote deb http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse"
        sudo sh -c 'echo "deb-src http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list'
        echo "Wrote deb-src http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse"
        sudo sh -c 'echo "deb http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list'
        echo "Wrote deb http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse"
        sudo sh -c 'echo "deb-src http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list'
        echo "Wrote deb-src http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse"
        echo Finished writing to sources.list.
        echo "Running apt update to update the sources..."
        echo "Please wait for apt update..."
        sudo apt update 2> /dev/null
        echo "Finished updating apt"
        echo "======"
        echo Your sources.list is now fixed.
        echo =======
        echo "If not fixed, and now sources.list is broken, please run ./bapt.sh --fix-sources -r"
        echo "If something goes wrong, please open the 'sourcebackup' folder in the source code when you downloaded it and read the README.md"
        exit 0
    elif [[ "$sourceopt" == "2" ]]; then
        echo This operation requires sudo. Please enter your password.
        sudo echo Authentication Complete
        echo Creating backup of sources.list...
        mkdir -p "$DATA_PATH/sourcebackup"
        sudo cp -f /etc/apt/sources.list "$DATA_PATH/sourcebackup/sources_($TIMESTAMP).list.bak"
        echo Success!
        echo Clearing sources.list...
        sudo sh -c ': > /etc/apt/sources.list'
        echo Success!
        echo Writing to sources.list...
        sudo sh -c 'echo "#deb cdrom:[Debian GNU/Linux 13.4.0 _Trixie_ - Official amd64 DVD Binary-1 with firmware 20260314-11:54]/ trixie contrib main non-free-firmware" >> /etc/apt/sources.list'
        echo "Wrote #deb cdrom:[Debian GNU/Linux 13.4.0 _Trixie_ - Official amd64 DVD Binary-1 with firmware 20260314-11:54]/ trixie contrib main non-free-firmware"
        sudo sh -c 'echo "deb http://deb.debian.org/debian/ trixie main non-free-firmware" >> /etc/apt/sources.list'
        echo "Wrote deb http://deb.debian.org/debian/ trixie main non-free-firmware"
        sudo sh -c 'echo "deb-src http://deb.debian.org/debian/ trixie main non-free-firmware" >> /etc/apt/sources.list'
        echo "Wrote deb-src http://deb.debian.org/debian/ trixie main non-free-firmware"
        sudo sh -c 'echo >> /etc/apt/sources.list'
        echo "Wrote \n"
        sudo sh -c 'echo "deb http://security.debian.org/debian-security trixie-security main non-free-firmware" >> /etc/apt/sources.list'
        echo "Wrote deb http://security.debian.org/debian-security trixie-security main non-free-firmware"
        sudo sh -c 'echo "deb-src http://security.debian.org/debian-security trixie-security main non-free-firmware" >> /etc/apt/sources.list'
        echo "Wrote deb-src http://security.debian.org/debian-security trixie-security main non-free-firmware"
        sudo sh -c 'echo "# trixie-updates, to get updates before a point release is made;" >> /etc/apt/sources.list'
        echo "Wrote # trixie-updates, to get updates before a point release is made;"
        sudo sh -c 'echo "# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports" >> /etc/apt/sources.list'
        echo "Wrote # see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports"
        sudo sh -c 'echo "deb http://deb.debian.org/debian/ trixie-updates main non-free-firmware" >> /etc/apt/sources.list'
        echo "Wrote deb http://deb.debian.org/debian/ trixie-updates main non-free-firmware"
        sudo sh -c 'echo "deb-src http://deb.debian.org/debian/ trixie-updates main non-free-firmware" >> /etc/apt/sources.list'
        echo "Wrote deb-src http://deb.debian.org/debian/ trixie-updates main non-free-firmware"
        sudo sh -c 'echo >> /etc/apt/sources.list'
        echo "Wrote \n"
        sudo sh -c 'echo >> /etc/apt/sources.list'
        echo "Wrote \n"
        sudo sh -c 'echo "# This system was installed using removable media other than" >> /etc/apt/sources.list'
        echo "Wrote # This system was installed using removable media other than"
        sudo sh -c 'echo "# CD/DVD/BD (e.g. USB stick, SD card, ISO image file)." >> /etc/apt/sources.list'
        echo "Wrote # CD/DVD/BD (e.g. USB stick, SD card, ISO image file)."
        sudo sh -c 'echo "# The matching "deb cdrom" entries were disabled at the end" >> /etc/apt/sources.list'
        echo "Wrote # The matching "deb cdrom" entries were disabled at the end"
        sudo sh -c 'echo "# of the installation process." >> /etc/apt/sources.list'
        echo "Wrote # of the installation process."
        sudo sh -c 'echo "# For information about how to configure apt package sources," >> /etc/apt/sources.list'
        echo "Wrote # For information about how to configure apt package sources,"
        sudo sh -c 'echo "# see the sources.list(5) manual." >> /etc/apt/sources.list'
        echo "Wrote # see the sources.list(5) manual."
        echo Finished writing to sources.list.
        echo "Running apt update to update the sources..."
        echo "Please wait for apt update..."
        sudo apt update 2> /dev/null
        echo "Finished updating apt"
        echo "======"
        echo Your sources.list is now fixed.
        echo =======
        echo "If not fixed, and now sources.list is broken, please run ./bapt.sh --fix-sources -r"
        echo "If something goes wrong, please open the 'sourcebackup' folder in the source code when you downloaded it and read the README.md"
        exit 0
    elif [[ "${sourceopt,,}" == "e" ]]; then
        exit 0
    elif [[ "${sourceopt,,}" == "i" ]]; then
        clear
        echo "/etc/apt/sources.list fix"
        echo "==============="
        echo "DO NOT pick the wrong distrubition, or it could break your system."
        echo "If your distrubition is NOT here, it means it is not supported as of right now."
        echo "==============="
        echo "[1] Last updated: 3/27/2025"
        echo "[2]: Last updated: 4/22/2025 (Debian V13.4)"
        echo "[I]: Get info about sources"
        echo "[B]: Back"
        echo -n "Choose: "
        read sourcedistinfo
        if [[ ${sourcedistinfo,,} == "b" ]]; then
            sourcefix
        else
            echo Invalid option! Returning to main menu...
            sourcefix
        fi
    else
        echo "Invalid option! (press enter to return)"
        read pause
        sourcefix
    fi
}

sourcerestore() {
    ls -1 "$DATA_PATH/sourcebackup" | column
    echo -n "Choose a file (type name or type e to exit):"
    read sourcerestoreopt
    if [[ -f "$DATA_PATH/sourcebackup/$sourcerestoreopt" ]]; then
        echo "Restoring..."
        sudo cp -f "$DATA_PATH/sourcebackup/$sourcerestoreopt" /etc/apt/sources.list
        echo "Restore Finished!"
        echo "==========="
        echo "If restore was uncomplete, please open the sourcebackup folder in the source code, or when you downloaded it, and read the README.md file."
        exit 0
    elif [[ "$sourcerestoreopt" == "e" ]]; then
        exit 0
    else
        echo "File was not found! ($sourcerestoreopt)"
        echo "Please try again. (press enter to return)"
        read pause
        clear
        sourcerestore
    fi
}

baptstatus() {
    echo bapt Status
    echo =====================
    echo "Please wait... collecting information.."
    command -v sudo
    command -v apt
    echo bapt Status
    echo =====================
    echo "OS: "
    echo "Network status: "
    echo ""
}

if [[ -f "$CONFIG_PATH" ]]; then
    source $CONFIG_PATH
else
    precheck
fi

if [[ "${1,,}" == "--settings" ]]; then
    settings
elif [[ "$1" == "" ]]; then
    echo No args specified.
    echo "Usage: bapt [ARGS]"
    echo "Type bapt --help for arguements"
elif [[ "$1" == "--help" ]]; then
    help
elif [[ "$1" == "install" ]]; then
    PACKAGE=$2
    installer "$2"
elif [[ "$1" == "remove" ]]; then
    PACKAGE=$2
    remover "$2"
elif [[ "$1" == "--fix-sources" ]]; then
    if [[ "$2" == "-r" ]]; then
        sourcerestore
    elif [[ "$2" == "" ]]; then
        sourcefix
    else
        echo "Invalid 2nd arg! ($2)"
        echo "Run ./bapt.sh --help for args for '$1'"
    fi
elif [[ "$1" == "search" ]]; then
    SEARCH=$2
    searcher "$2"
else
    echo "Invalid option! ($1)"
    echo "Type bapt --help for arguements."
fi
