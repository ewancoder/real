#!/usr/bin/env bash
set -euo pipefail

# TODO:
# 2. pacman cleanup at the end fails for some reason due to a dash -
# 3. if aur already installed - skip installing it

source env.sh

clear
mess -t "$title\nVersion $version"

if [ ! "$(id -u)" -eq 0 ]; then
    mess -w "You have to be ROOT to run this script. Exiting."
    exit
fi

mess -w "Before proceeding:\n\t1) Edit 'config.sh' configuration file\n\t2) Format your partitions (including swap if needed) & mount them to /mnt as required.\n\nOnly continue after you've done this, or press Ctrl+C to cancel script execution."
source config.sh

prepare() {
    echo "source ./env.sh" > "$2"
    echo "source ./config.sh" >> "$2"
    while read -r p; do
        if [ "$p" == "" ] ||
           [ "${p:0:1}" == "#" ] ||
           [ "${p:0:2}" == "fi" ] ||
           [ "${p:0:3}" == "if " ] ||
           [ "${p:0:4}" == "for " ] ||
           [ "${p:0:4}" == "else" ] ||
           [ "${p:0:4}" == "done" ] ||
           [ "${p:0:4}" == "' > " ] ||
           [ "${p:0:5}" == "mess " ] ||
           [ "${p:0:5}" == "elif " ] ||
           [ "${p:0:7}" == "source " ] ||
           [ "${p:0:11}" == "cd \`dirname" ]; then  
            echo "$p" >> "$2"
        elif [ "${p:0:8}" == "set -euo" ]; then
            # Skip adding set -euo if configured.
            if [ $extra_safe -eq 1 ]; then
                echo "$p" >> "$2"
            fi
        else
            #cmd=$(echo "$p" | sed -r 's/(.)/\\\\\1/g')
            cmd=$(echo "$p" | sed -r 's/(.)/\\\1/g')
            echo "cmd=\$(echo $cmd)" >> "$2"

            # Left for history, substitution is BROKEN for now.
            #if [ $substitute -eq 1 ]; then
            #    parsed=$(perl -pe 's/\$(?:{.*?}|\w+)(*SKIP)(*F)|(.)/\\$1/g' <<< "$p")
            #    echo 'parsed ' + $parsed
            #else
                parsed=$cmd
            #fi
            echo "parsed=\$(echo $parsed)" >> "$2"

            if [ $verbose -eq 1 ]; then
                echo 'mess -v "$cmd"' >> "$2"
                if [ $auto -eq 0 ]; then
                    {
                        echo -e 'read -rep $'"'"'\\e[33m-> '"'"' -i "$parsed" parsed'
                        echo -e 'echo $'"'"'\\e[0m'"'"''
                    } >> "$2"
                fi
            fi
            {
                echo -e 'until eval "$parsed"; do'
                echo -e '    ans=""'
                echo -e '    mess -q "Error occured on step [$step]. Retry? (Y/n)"'
            } >> "$2"
            if [ $timeout -eq 0 ]; then
                echo -e "    read ans" >> "$2"
            else
                {
                    echo -e "    mess -q \"Auto-repeating in $timeout seconds\""
                    echo -e "    if read -t $timeout ans; then"
                } >> "$2"
            fi
            {
                echo -e '        if [ "$ans" == "n" -o "$ans" == "N" ]; then'
                echo -e '            break'
                echo -e '        elif [ "$ans" == "givemebash" ]; then'
                echo -e '            /bin/bash'
                echo -e '            ans=""'
                echo -e '            mess -q "Retry [$step]? (Y/n)"'
                echo -e '            read ans'
                echo -e '            if [ "$ans" == "n" -o "$ans" == "N" ]; then'
                echo -e '                break'
                echo -e '            fi'
                echo -e '        elif [ "$ans" == "exit" ]; then'
                echo -e '            exit'
            } >> "$2"
            if [ "$verbose" -eq 1 ]; then
                {
                    echo -e '        elif [ ! "$ans" == "" ] || [ $auto -eq 0 ]; then'
                    echo -e '            read -rep $'"'"'\\e[33m-> '"'"' -i "$parsed" parsed'
                    echo -e '            echo $'"'"'\\e[0m'"'"''
                } >> "$2"
            fi
            {
                echo -e '        fi'
                if [ $timeout -eq 1 ]; then
                    echo -e '    fi'
                fi
                echo -e 'done'
            } >> "$2"
        fi
    done < "$1"
}

mess -t "Prepare installation scripts (add error handling)"
mess "Make temporary 'eal' directory where all installation files will be kept"
mkdir -p $install_folder

mess "Copy env.sh, config.sh"
cp env.sh config.sh $install_folder

mess "Copy packages & scripts folders"
cp -r packages $install_folder/
cp -r scripts $install_folder/

mess "Prepare eal.sh, make it executable"
prepare eal.sh $install_folder/eal.sh
chmod +x $install_folder/eal.sh

if [ $hostinstall -eq 1 ]; then
    mess "Prepare heal.sh, make it executable"
    prepare heal.sh $install_folder/heal.sh
    chmod +x $install_folder/heal.sh
fi

mess "Prepare peal.sh, make it executable"
prepare peal.sh $install_folder/peal.sh
chmod +x $install_folder/peal.sh

if [ -f custom.sh ]; then
    mess "Prepare custom.sh, make it executable"
    prepare custom.sh $install_folder/custom.sh
    chmod +x $install_folder/custom.sh
fi

for script in scripts/*; do
    filename=$(basename "$script")
    mess "Prepare $filename, make it executable"
    prepare "$script" "$install_folder/scripts/$filename"
    chmod +x "$install_folder/scripts/$filename"
done

mess "Copy firstboot.sh"
sed -i "s/firstboot_packages=()/firstboot_packages=( $firstboot_packages )/g" firstboot.sh
sed -i "s/wifi_ssid=''/wifi_ssid='$wifi_ssid'/g" firstboot.sh
sed -i "s/wifi_password=''/wifi_password='$wifi_password'/g" firstboot.sh
sed -i "s/username=''/username='$username'/g" firstboot.sh
cp firstboot.sh $install_folder/firstboot.sh
chmod +x $install_folder/firstboot.sh

mess "CD into temp folder"
cd $install_folder

mess -t "Start installation"

if [ $hostinstall -eq 1 ]; then
    mess "Run host installation"
    ./heal.sh
else
    mess "Run installation"
    ./eal.sh
fi

mess -p "Remove the temporary folder. This is the last step, feel free to Ctrl+C if you want to keep it"
rm -rf $install_folder

mess -p "That's it, your system is installed. Run /firstboot.sh after booting in, then reboot again. [REBOOT]"
mess -w "After reboot - login as ROOT, and run /firstboot.sh to finish the installation"
reboot
