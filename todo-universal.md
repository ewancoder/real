# Instructions to make the script universal.

## .zprofile

- (consider in future) Remove source ~/.secrets if no need for RDP
  - Right now RDP is mandatory in this install setup

## .zshrc

- (consider) Change export EDITOR=vi to the editor you need (also change it to vim for my script)
- (consider) Edit networks aliases file if needed.

## .gitconfig & .gitconfig-work

- (consider) Change editor & mergetool if needed
- (consider) Change work folder if needed (~/work/)

## Maintenance

- Run pacman -Syu and yay -Syu sometimes.
- Use this to remove all orphans: pacman -Qdtq | pacman -Rns -
