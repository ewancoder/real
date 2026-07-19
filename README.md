# Rad Ewancoder Arch Linux installation script

This script automates installing Arch Linux, handling errors in the process and allowing you to re-run (or even change) any command during the script execution.

## How to run

1. Boot up from LiveCD, connect to network (wifi)
2. (optional) connect via SSH for convenience:

```
(on livecd): passwd # set up password
ssh root@IP
```

3. Download the script:

```
pacman -Syy --noconfirm git
git clone https://github.com/ewancoder/real
cd real
```

4. Edit `configs/CONFIGNAME.sh` file for your machine carefully, reviewing each variable.

5. Run the script from root:

> Consider running it in tmux session.

```
./mount/MOUNT_SCRIPT.sh
./install.sh CONFIGNAME
```

### Running from already running host system (Arch/Debian/anything else)

You can run the script from already running distro (maybe even WSL, though untested).

It uses chroot to prepare "virtual live CD" and use it for the installation.

Other than that, all the steps are the same.
