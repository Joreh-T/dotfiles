#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

# Mapping: source -> destination
declare -A LINKS=(
    ["$DOTFILES_DIR/nvim"]="$HOME/.config/nvim"
    ["$DOTFILES_DIR/yazi"]="$HOME/.config/yazi"
    ["$DOTFILES_DIR/vim/vimrc"]="$HOME/.vimrc"
)

echo "Creating symlinks..."

for SRC in "${!LINKS[@]}"; do
    DST="${LINKS[$SRC]}"
    # Backup existing target
    if [ -e "$DST" ] || [ -L "$DST" ]; then
        echo "Backing up existing $DST -> $DST.bak"
        mv "$DST" "$DST.bak"
    fi
    # Create parent directory if needed
    mkdir -p "$(dirname "$DST")"
    # Create symbolic link
    ln -s "$SRC" "$DST"
    echo "Created symlink: $DST -> $SRC"
done

echo "Symlinks created."

# Check if yazi is installed
if command -v ya >/dev/null 2>&1; then
    echo "yazi detected, upgrading packages..."
    ya pkg upgrade
else
    echo "yazi not installed, skipping package upgrade."
fi

echo "Done!"

