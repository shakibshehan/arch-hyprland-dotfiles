#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "======================================"
echo " Arch Linux Dotfiles Restore"
echo "======================================"

if ! command -v pacman >/dev/null 2>&1; then
    echo "Error: This script requires Arch Linux or an Arch-based system."
    exit 1
fi

if [[ ! -d "$CONFIG_SRC" ]]; then
    echo "Error: Configuration directory not found: $CONFIG_SRC"
    exit 1
fi

echo
echo "This script will:"
echo "  1. Install packages from the saved package lists."
echo "  2. Back up your existing ~/.config."
echo "  3. Copy the saved configuration into ~/.config."
echo
read -r -p "Continue? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || exit 0

# Install official repository packages, if a list exists.
if [[ -s "$REPO_DIR/packages-official.txt" ]]; then
    echo
    echo "Installing official repository packages..."
    sudo pacman -Syu --needed -- < "$REPO_DIR/packages-official.txt"
fi

# Install AUR packages only if yay is already available.
if [[ -s "$REPO_DIR/packages-aur.txt" ]]; then
    if command -v yay >/dev/null 2>&1; then
        echo
        echo "Installing AUR packages with yay..."
        yay -S --needed -- < "$REPO_DIR/packages-aur.txt"
    else
        echo
        echo "WARNING: yay is not installed."
        echo "AUR packages were not installed."
        echo "Install yay and rerun this script to install them."
    fi
fi

# Back up current configuration before copying.
if [[ -d "$HOME/.config" ]]; then
    echo
    echo "Backing up existing configuration to:"
    echo "$BACKUP_DIR"
    cp -a "$HOME/.config" "$BACKUP_DIR"
fi

mkdir -p "$HOME/.config"

echo
echo "Restoring configuration files..."
cp -a "$CONFIG_SRC/." "$HOME/.config/"

echo
echo "Restore complete."
echo "Your previous configuration backup is at:"
echo "$BACKUP_DIR"
echo
echo "Log out and back in, or restart Hyprland, to apply changes."

