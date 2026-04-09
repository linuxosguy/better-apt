#!/bin/bash
#WARNING: If you change the CONFIG_PATH, please make sure the folder exists.
RED='\033[1;31m'
NC='\033[0m'

CONFIG_PATH=$HOME/.bapt/bapt-cfg.conf
TEMP_PATH=/tmp/bapt

precheck() {
    echo BAPT Pre-check
    echo Please wait...
    echo Making directories...
    echo "(~/.bapt)"
    mkdir -p ~/.bapt 2> /dev/null #Comment this out if you don't want any folder to be created
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



if [[ -f "$CONFIG_PATH" ]]; then
    source $CONFIG_PATH
else
    precheck
fi



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
}

installer() {
    echo This will require sudo! Please enter your password.
    sudo echo Authentication was complete.
    sudo apt install $PACKAGE
    clear
    echo "$PACKAGE was installed."
}

remover() {
    echo This will require sudo! Please enter your password.
    sudo echo Authentication was complete.
    sudo apt remove $PACKAGE
    clear
    echo "$PACKAGE was removed."
}

##Arg Check
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
else
    echo "Invalid option! ($1)"
    echo "Type bapt --help for arguements."
fi
