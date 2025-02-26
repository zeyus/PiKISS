#!/bin/bash
#
# Description : GemRB (EXPERIMENTAL)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (27/Jun/21)
# Compatible  : Raspberry Pi 4
# Repository  : https://github.com/gemrb/gemrb
# Help        : https://github.com/gemrb/gemrb/blob/master/INSTALL
#             : https://gemrb.org/Manpage.html
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libvorbisidec1 libopenal1 libsdl2-mixer-2.0-0 libpng12-0 libglu1-mesa)
readonly PACKAGES_DEV=(cmake libsdl2-dev libvorbis-dev libopenal-dev libsdl2-mixer-dev libpng-dev libfontconfig1-dev libfreetype6-dev libglew-dev libgles2-mesa-dev)
readonly BINARY_URL="https://misapuntesde.com/res/gemrb-0.8.8-rpi.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/gemrb/gemrb/archive/refs/tags/v0.8.8.zip"
readonly GAME_DATA_PATH="$INSTALL_DIR/gemrb/data"
readonly GEMRBCFG_PATH="$INSTALL_DIR/gemrb/etc/gemrb/GemRB.cfg"
readonly MAGIC_AIR_NAME="GEMRB"
INPUT=/tmp/temp.$$

runme() {
    if [[ ! -f $INSTALL_DIR/gemrb/bin/gemrb ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/gemrb/bin && ./gemrb
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/gemrb ~/.local/share/applications/gemrb.desktop
}

uninstall() {
    read -p "Do you want to uninstall GemRB (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/gemrb ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/gemrb ]]; then
    echo -e "GemRB already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/gemrb.desktop ]]; then
        cat <<EOF >~/.local/share/applications/gemrb.desktop
[Desktop Entry]
Name=GemRB
Version=0.8.8
Type=Application
Comment=Game engine made with preRendered Background
Exec=${INSTALL_DIR}/gemrb/bin/gemrb
Icon=${INSTALL_DIR}/gemrb/gemrb-logo.png
Path=${INSTALL_DIR}/gemrb/
Terminal=false
Categories=Game;RolePlaying;Emulator;
EOF
    fi
}

compile() {
    # Tip: Better use cmake-gui | git clone form repo broke the compilation: Use the release.
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    download_and_extract "$SOURCE_CODE_URL" "$HOME/sc" && cd "$HOME/sc/gemrb-0.8.8"
    mkdir build && cd "$_" || exit 1
    cmake .. -DSDL_BACKEND=SDL2 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DOPENGL_BACKEND=GLES -DDISABLE_WERROR=1 -DSTATIC_LINK=enabled -DCMAKE_INSTALL_PREFIX=$HOME/games/gemrb -DUSE_SDLMIXER=disabled -DSDL2MAIN_LIBRARY=/usr/lib/arm-linux-gnueabihf/libSDL2.so -DDISABLE_VIDEOCORE=1
    make_with_all_cores
    read -p "Do you want to install globally the app (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        [[ ! -e $HOME/sc/gemrb/gemrb.desktop ]] && touch "$HOME/sc/gemrb/gemrb.desktop" # This file is missing and needed in latest compilations
        sudo make install
    fi
    echo -e "\nDone!. Check the code at $HOME/sc/gemrb."
    exit_message
}

set_game_path() {
    local DATA_PATH
    DATA_PATH="$GAME_DATA_PATH/bgate"

    if [[ ! -e $GEMRBCFG_PATH ]]; then
        return
    fi

    if [[ -e $GEMRBCFG_PATH ]]; then
        echo -e "\nChanging GamePath to $DATA_PATH on $GEMRBCFG_PATH"
        sed -i -e "s|GamePath=.*|GamePath=${DATA_PATH}|g" "$GEMRBCFG_PATH"
    fi
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$MAGIC_AIR_NAME")
    if [[ $DATA_URL == "" ]]; then
        false
        return
    fi
    message_magic_air_copy "$DATA_URL"
    download_and_extract "$DATA_URL" "$INSTALL_DIR/gemrb/data"
    true
    return
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    if exists_magic_file && download_data_files; then
        set_game_path
        echo -e "\nDone!. You can play typing $INSTALL_DIR/gemrb/bin/gemrb or opening the Menu > Games > GemRB.\n"
        runme
    else
        echo -e "\nCopy all the data files from your copy inside $GAME_DATA_PATH.\n\nYou can play typing $INSTALL_DIR/gemrb/bin/gemrb or opening the Menu > Games > GemRB"
        exit_message
    fi
}

install_script_message
echo "
GemRB (Infinite Engine) for Raspberry Pi
========================================

 · Supported games: Baldur's Gate, Baldur's Gate 2 : SoA or ToB, Icewind Dale : HoW or ToTL, Icewind Dale 2 & Planescape Torment.
 · Thanks to @foxhound311 for his help with compilation issues.
 · Optimized for Raspberry Pi 4 with OpenGL ES.
 · It has a glitch and you can't play video sequences atm.
 · You must to set the GamePath of the game you want to play in the file GemRB.cfg
 · IMPORTANT: All settings are changed in the file $GEMRBCFG_PATH
"
read -p "Press [Enter] to continue..."

install
