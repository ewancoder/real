# Rad Ewancoder Arch Linux installation script

This script automates installing Arch Linux, handling errors in the process and allowing you to re-run (or even change) any command during the script execution.

## How to run

1. Download all scripts (or clone the repository).
2. Edit `config.sh`, `finish-install.sh` and `custom.sh`.

> `custom.sh` is being run during the installation, from the `root` user; `finish-install.sh` script is copied to the installed system to be run by you manually after rebooting into the system. These two are your custom scripts, erase their content if you don't need them.

3. Run `./install.sh` under root.
4. Enjoy :)
