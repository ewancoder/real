# Rad Ewancoder Arch Linux installation script

This script automates installing Arch Linux, handling errors in the process and allowing you to re-run (or even change) any command during the script execution.

## How to run

1. Boot up from LiveCD
2. Download the script:

```
pacman -Syy
pacman -S --noconfirm git
git clone https://github.com/ewancoder/real
cd real
```

3. Edit `config.sh` file carefully, reviewing each variable.
  - If needed - create your own packages/scripts in `packages`/`scripts` folders
4. Run the script from root:

`sudo ./install.sh`

At some point during the install, you will be prompted to format & mount the drivers to /mnt folder. Format and mount them accordingly.

You will be given a new bash shell session. You can format your drives & mount them, and then type `exit` to exit the interactive shell session.

The installation script will continue executing immediately.

### Running from already running host system (Arch/Debian/anything else)

You can run the script from already running distro (maybe even WSL, though untested).

It uses chroot to prepare "virtual live CD" and use it for the installation.

Other than that, all the steps are the same.
