# INSTALL GPU DRIVERS. Important to do after reboot into the actual system!
# - and "steam" package


# These steps need to be done after rebooting into your installed system.

ln -rsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
iws
pacman -S nvidia-open steam lib32-nvidia-utils

# Check driver is nvidia
lspci -k -d ::03xx

# !!! EDIT THESE 3 FILES for your system (if on another machine):
# .config/mako/config (set proper output)
#   - change `output=DP-3` into the output on which you want to display notifications (or remove this line)
# .config/sway/config
#   - configure all outputs: DPs, position, resolution, wallpapers
#   - configure workspaces bound to these outputs, and switching/moving to these workspaces
#     -- configure windows mapped to workspaces (messengers on work-view)
#   - configure input (if not dvorak - remove variant), en/ru layouts
#   - configure status bars for specific outputs
#   - remove EXECs if not needed: dropbox, telegram-desktop
# .local/bin/rdpwin
#   - change IP address if needed
#   - change user name







# (optional)
# xwayland disable (in sway config) - will only enable wayland apps

# logs
sudo docker run \
    --name seq
    -d
    --restart unless-stopped
    -e ACCEPT_EULA=Y
    -p 5341:5341
    -p 80:80
    -v /mnt/data/seq:/data
    datalust/seq:latest

# plex
sudo docker run \
    -d
    --name=plex
    -v /mnt/data/plex/library:/config
    -v /mnt/data/plex/tv:/tv
    -v /mnt/data/plex/movies:/movies
    --restart unless-stopped
    -e PUID=1000
    -e PGID=1000
    -e TZ=Etc/UTC
    -e VERSION=docker
    --net=host
    lscr.io/linuxserver/plex:latest

!!!! i needed to disable autologin on tty1: for some reason it doesn't work and hangs the whole system
!!!!! ALSO i need to NOT install nvidia-open & steam straight away, install them AFTER I reboot into the system
sign in to dropbox (unlink previous device)
install
- vim extension to code
- set up white theme in code (light modern)
- angular service in code
reload sway now that wallpapers should be downloaded (or reload multiple times later until it's done)

# sign in to skype, zoom, discord, telegram, chrome, firefox, slack
# -turn off meeting when joining meeting, turn off microphone, autojoin, soft revellio, uncheck show status as away, all notifications off
# -skype also turn off message notification sounds
# - telegram no sounds for notifications, do not show muted folders on tray icon
# - discord no sound notifications
# Disable zoom notifications completely.
# Remove all irrelevant folders from /home
# sign in to steam, install what i need
# - make myself invisible straight away
# - do not show notifications for frinds joining game

# add all needed btrfs volumes & rebalance

# qbittorrent: 33222 port for pc, 33223 for laptop
# (MAYBE)? follow the guide from wininstall? consolidate these guides - make a separate guide for software configuration
# - and consider adding software configuration to the dotfiles

# run gh auth login

#turn off steam overlay?
# sync anki data

# connecto to bluetooth devices bluetoothctl, +trust

# TODO:
# Cache DATA stuff to a separate /mnt/data volume (maybe not the Games YET, because space is limited)
# - anki cards
# - Dropbox

# !! configure /etc/systemd/resolved.conf if needed:
# DNS=8.8.8.8 8.8.4.4 (probably better to do this on router level)





1. chrome needs to be configured for wayland, otherwise it uses xwayland
2. rider: -Dawt.toolkit.name=WLToolkit

to their VM options (Help | Edit Custom VM Options…).

! todo: remap alt+shift+\ for AI autocomplete to some better combination
ctrl+/ - opens prompt to initiate changing by AI

can write docs: all actions -> write documentation. alternatively: settings -> tools -> ai assistent -> prompt library -> write docs
-- hm this can be useful I guess

also can generate unit tests - need to check this

tesseract tesseract-data-eng
imagemagick (installs magick command)
- for jetbrains - wallaby




!! TODO: add to install: tweat /etc/systemd/timesyncd.conf: NTP=time.google.com
and timesyncd set-ntp true

!! install & start CADDY on a localc pc (for dev env)



docker swarm init --advertise-addr <public ip address>
- will be given a command to join a worker - run on sub-machines
docker network create --driver overlay --attachable tyr-overlay

attachable says regular containers (non swarm ones) can attach it




# install: yay vmware-workstation
# todo: add this to install script
start vmware-networks-configuration.service
enable vmware-networks.service

# probably install here linux-headers
# and also yay vmware-host-modules
# hm still doesn't work needs investigation

modprobe -a vmw_vmci vmmon

# Ensure direct RAM access (already done on image):
Virtual_machine_name.vmx

MemTrimRate = "0"
sched.mem.pshare.enable = "FALSE"
prefvmx.useRecommendedLockedMemSize = "TRUE"
mainmem.backing = "swap"




# for virtualbox:
virtualbox virtualbox-host-modules-arch
virtualbox-guest-iso - guest addition for running on VM
reboot to load modules (lazy to load manually)
