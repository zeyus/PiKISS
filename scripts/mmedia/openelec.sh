#!/bin/bash
#
# Description : OpenELEC Extras
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7 (28/May/15)
#
# HELP		    : zip -r AdvLauncher_uLySeSS.zip /storage/.kodi/addons/emulator.tools.retroarch/ /storage/.kodi/addons/plugin.program.advanced.launcher/ /storage/.kodi/addons/script.module.simplejson/ /storage/.kodi/userdata/addon_data/emulator.tools.retroarch/ /storage
#/.kodi/userdata/addon_data/plugin.program.advanced.launcher/
#							· http://forum.kodi.tv/showthread.php?tid=201354
#							· http://kodi.wiki/view/Raspberry_Pi
#							· resize partition: touch /storage/.please_resize_me
clear

advancedsettings(){
	file="<advancedsettings>
	<network>
	<buffermode>1<\/buffermode>
	<cachemembuffersize>0<\/cachemembuffersize>
	<readbufferfactor>4.0<\/readbufferfactor>
	<\/network>
<\/advancedsettings>"

	echo $file > /storage/.kodi/userdata/advancedsettings.xml
}

optimize(){
	mount /flash -o rw,remount
	# Backup the config file
 	[[ ! -e /flash/config.bak ]] && cp /flash/config.txt /flash/config.bak
	#noram and disable splash decrease boot times
	echo -e "noram\ndisable_splash=1" | tee -a /flash/config.txt
	# I dunno what the hell do the next
	[[ ! -e /flash/config.bak ]] && touch /storage/.config/udev.rules.d/80-io-scheduler.rules
	echo -e 'ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"' | tee -a /storage/.config/udev.rules.d/80-io-scheduler.rules
	#Overclocking 950 Mhz Rpi | 1000 Mhz Rpi2
	if [[ $(cat /proc/cpuinfo | grep 'BCM2708') ]]; then
		echo -e "arm_freq=950\ncore_freq=450\nsdram_freq=450\nover_voltage=6" | tee -a /flash/config.txt
	elif [[ $(cat /proc/cpuinfo | grep 'BCM2709') ]]; then
		echo -e "arm_freq=1000\ncore_freq=500\nsdram_freq=500\nover_voltage=6" | tee -a /flash/config.txt
	fi
	
	# Tweak the system UI and others. It does not work. I don't know why. Grrr!

	# sed -i 's/        <enablerssfeeds>true<\/enablerssfeeds>/        <enablerssfeeds>false<\/enablerssfeeds>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <soundskin default="true">SKINDEFAULT<\/soundskin>/        <soundskin>OFF<\/soundskin>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HomeMenuNoWeatherButton">false<\/setting>/        <setting type="bool" name="skin.confluence.HomeMenuNoWeatherButton">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HomeMenuNoPicturesButton">false<\/setting>/        <setting type="bool" name="skin.confluence.HomeMenuNoPicturesButton">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HomeMenuNoMusicButton">false<\/setting>/        <setting type="bool" name="skin.confluence.HomeMenuNoMusicButton">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HomeMenuNoProgramsButton">false<\/setting>/        <setting type="bool" name="skin.confluence.HomeMenuNoProgramsButton">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HideVisualizationFanart">false<\/setting>/        <setting type="bool" name="skin.confluence.HideVisualizationFanart">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HideBackGroundFanart">false<\/setting>/        <setting type="bool" name="skin.confluence.HideBackGroundFanart">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
}

retroarch(){
	wget http://misapuntesde.com/res/AdvLauncher_uLySeSS.zip
	unzip AdvLauncher_uLySeSS.zip -d /
	rm AdvLauncher_uLySeSS.zip
	killall -9 kodi.bin
}

pelisalacarta(){
	wget http://blog.tvalacarta.info/descargas/pelisalacarta-xbmc-addon-gotham-3.9.99.zip
	unzip pelisalacarta-xbmc-addon-gotham-3.9.99.zip -d /storage/.kodi/addons/
	rm pelisalacarta-xbmc-addon-gotham-3.9.99.zip
	killall -9 kodi.bin
}

backup(){
	DATE=`date +%Y%m%e-%H%M%S`
	zip -r /storage/backup/bckup_$DATE.zip /storage/.kodi/addons/ /storage/.kodi/userdata/
	read -p "backup done!. Enable Samba on OpenELEC and navigate to //OPENELEC/Backup/"
}

echo -e "OpenELEC Extras for Kodi\n"

read -p "Increase video buffer? [y/n]: " option
case "$option" in
    y*) advancedsettings ;;
esac

read -p "Optimize the system? [y/n]: " option
case "$option" in
    y*) optimize ;;
esac

read -p "Install RetroArch emulators? [y/n]: " option
case "$option" in
    y*) retroarch ;;
esac

read -p "Install addon pelisalacarta 3.9.99? [y/n]: " option
case "$option" in
    y*) pelisalacarta ;;
esac

read -p "Backup Addons+Userdata? [y/n]: " option
case "$option" in
    y*) backup ;;
esac

echo -e "Have a nice Day :)\n"
#reboot