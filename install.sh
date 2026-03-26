#!/bin/bash

# =============================================================================

# kxjr dotfiles restore script

# Run this on a fresh Arch install to restore your setup

# =============================================================================

set -e

DOTS=”$(cd “$(dirname “${BASH_SOURCE[0]}”)” && pwd)”
GREEN=’\033[0;32m’
YELLOW=’\033[1;33m’
CYAN=’\033[0;36m’
NC=’\033[0m’

log() { echo -e “${GREEN}[+]${NC} $1”; }
warn() { echo -e “${YELLOW}[!]${NC} $1”; }
section() { echo -e “\n${CYAN}━━━ $1 ━━━${NC}”; }

# =============================================================================

section “1 — Base system”

# =============================================================================

log “Setting locale…”
sudo cp “$DOTS/system/locale.conf” /etc/locale.conf
sudo cp “$DOTS/system/vconsole.conf” /etc/vconsole.conf
sudo bash -c ‘grep -q “en_US.UTF-8” /etc/locale.gen || echo “en_US.UTF-8 UTF-8” >> /etc/locale.gen’
sudo bash -c ‘grep -q “es_ES.UTF-8” /etc/locale.gen || echo “es_ES.UTF-8 UTF-8” >> /etc/locale.gen’
sudo locale-gen

log “Setting keymap…”
sudo localectl set-keymap es
sudo localectl set-x11-keymap es

log “Enabling multilib…”
if grep -q “^#[multilib]” /etc/pacman.conf; then
sudo sed -i ‘/^#[multilib]/{s/^#//;n;s/^#//}’ /etc/pacman.conf
sudo pacman -Sy
fi

log “Updating mirrors…”
sudo pacman -S –needed –noconfirm reflector
sudo reflector –latest 10 –sort rate –save /etc/pacman.d/mirrorlist
sudo pacman -Sy

# =============================================================================

section “2 — HyDE”

# =============================================================================

if [ ! -d “$HOME/HyDE” ]; then
log “Cloning HyDE…”
git clone –depth=1 https://github.com/HyDE-Project/HyDE.git “$HOME/HyDE”
fi

log “Running HyDE installer (this takes a while)…”
cd “$HOME/HyDE/Scripts”
./install.sh

# =============================================================================

section “3 — yay”

# =============================================================================

if ! command -v yay &>/dev/null; then
log “Installing yay…”
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si –noconfirm
fi

# =============================================================================

section “4 — Packages”

# =============================================================================

log “Installing official packages…”

# Remove packages HyDE already installed to avoid conflicts

comm -23
<(sort “$DOTS/packages-official.txt”)
<(pacman -Qqe | sort) |
xargs -r sudo pacman -S –needed –noconfirm

log “Installing AUR packages…”
comm -23
<(sort “$DOTS/packages-aur.txt”)
<(pacman -Qqm | sort) |
xargs -r yay -S –needed –noconfirm

# =============================================================================

section “5 — BlackArch”

# =============================================================================

if ! grep -q “[blackarch]” /etc/pacman.conf; then
log “Adding BlackArch repo…”
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
rm strap.sh
fi

# =============================================================================

section “6 — swww”

# =============================================================================

if ! command -v swww &>/dev/null; then
log “Building swww from source…”
sudo pacman -S –needed –noconfirm rust cargo
cd “$HOME”
git clone https://github.com/LGFae/swww.git
cd swww
cargo build –release
sudo install -Dm755 target/release/swww /usr/local/bin/swww
sudo install -Dm755 target/release/swww-daemon /usr/local/bin/swww-daemon
fi

# =============================================================================

section “7 — Dotfiles”

# =============================================================================

log “Installing omenu scripts…”
mkdir -p “$HOME/.config/omenu”
cp “$DOTS/config/omenu/”*.sh “$HOME/.config/omenu/”
chmod +x “$HOME/.config/omenu/”*.sh

log “Adding custom keybinds…”
KEYBINDS=”$HOME/.config/hypr/keybindings.conf”
if [ -f “$KEYBINDS” ] && ! grep -q “omenu” “$KEYBINDS”; then
cat “$DOTS/config/hypr/keybindings.conf” >> “$KEYBINDS”
fi

log “Configuring SDDM for Wayland…”
sudo mkdir -p /etc/sddm.conf.d
sudo bash -c ‘cat > /etc/sddm.conf.d/hyprland.conf’ << ‘EOF’
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=Hyprland
EOF

# =============================================================================

section “8 — Boot entries”

# =============================================================================

log “Restoring boot entries…”
sudo cp “$DOTS/system/loader.conf” /boot/loader/loader.conf
sudo cp “$DOTS/system/arch.conf” /boot/loader/entries/arch.conf

if [ -f “$DOTS/system/windows.conf” ]; then
# Check Windows EFI files are present first
if [ -f “/boot/EFI/Microsoft/Boot/bootmgr.efi” ]; then
sudo cp “$DOTS/system/windows.conf” /boot/loader/entries/windows.conf
log “Windows boot entry restored”
else
warn “Windows EFI files not found in /boot — copy them first:”
warn “sudo mount /dev/nvme0n1p2 /mnt/winefi”
warn “sudo cp -r /mnt/winefi/EFI/Microsoft /boot/EFI/”
fi
fi

# =============================================================================

section “9 — Services”

# =============================================================================

sudo systemctl enable –now bluetooth
sudo systemctl enable –now NetworkManager
sudo systemctl enable –now fstrim.timer
sudo systemctl enable –now systemd-timesyncd
systemctl –user enable –now pipewire 2>/dev/null || true
systemctl –user enable –now pipewire-pulse 2>/dev/null || true
systemctl –user enable –now wireplumber 2>/dev/null || true

# =============================================================================

section “Done!”

# =============================================================================

echo -e “${GREEN}”
echo “ Restore complete! Reboot to finish.”
echo “”
echo “ If brightness keys don’t work after reboot:”
echo “ ls /sys/class/backlight/”
echo “ brightnessctl -d <device> set 50%”
echo -e “${NC}”
