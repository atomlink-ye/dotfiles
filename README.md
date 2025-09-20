# Dotfiles

dotfiles synced by chezmoi

## QuickStart

> prerequirement: `git`, `curl`

on a new machine:

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply atomsi7 && \
cd  ~/.local/share/chezmoi && \
sh install.sh
```
