#!/usr/bin/env bash
set -e

BLACK="\e[0;30m"
BLUE="\e[1;34m"
CYAN="\e[36m"
RESET="\e[0m"
UNDERLINE="\e[4m"
NO_UNDERLINE="\e[24m"

echo -e "${BLACK}"
cat <<'EOF'
                .__         .__   __
        ____  |__|___  ___|__|_/  |_   ____
        /    \ |  |\  \/  /|  |\   __\_/ __ \
        |   |  \|  | >    < |  | |  |  \  ___/
        |__|  /|__|/__/\_ \|__| |__|   \___  >
            \/           \/                \/
EOF

echo -e "${BLUE}    Sit back while we install your linux software"
echo -e "${RESET}Report bugs to ${CYAN}${UNDERLINE}https://github.com/aspizu/nixite/issues${NO_UNDERLINE}${RESET}"
echo

if [[ -f /etc/os-release ]]; then
  source /etc/os-release
else
  echo "File not found: /etc/os-release, are you running Linux?"
  exit 1
fi

install_system() {
  if ! command -v paru &>/dev/null; then
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp || return
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin || return
    makepkg -si --needed
  fi
  paru -S --needed "$@"
}

install_flatpak() {
  if ! command -v flatpak &>/dev/null; then
    sudo pacman -S --needed --noconfirm flatpak
  fi
  flatpak install flathub -y "$@"
}

install_aur() {
  if ! command -v aur &>/dev/null; then
    sudo pacman -S --needed --noconfirm yay
  fi
  yay -S "$@"
}

install_aur neofetch
install_aur docker-compose-bin
install_aur notepad++
install_aur onedrivegui
install_aur mongodb-compass-bin
install_aur redisinsight-bin
install_aur joplin-desktop
install_aur obsidian-bin
install_aur pgloader
install_aur anytype-bin
install_aur drawio
install_aur gtkd
install_aur nerdfonts-installer-bin
install_aur pycharm
install_aur teams-for-linux-bin
install_aur tufw-git
install_aur webkit2gtk
install_aur neovim-git
install_aur pulse-secure
install_aur tilix

install_system firefox
install_system google-chrome
install_system zen-browser-bin
install_system torbrowser-launcher
install_system thunderbird
install_system discord
install_system spotify
install_system vlc
install_system transmission-gtk
install_system gimp
install_system inkscape
install_system krita
install_system libreoffice-fresh
install_system obsidian
install_system git
install_system curl
install_system dbeaver
install_system docker
install_system ntfs-3g
install_system remmina
install_system rigrep
install_system variety
if [[ ! -f "$HOME/.cargo/bin/rustup" ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
install_system visual-studio-code-bin
install_system proton-vpn-gtk-app
install_system flameshot
install_system gnome-boxes
install_system timeshift
install_system btop
install_system alacritty
install_system kitty
install_system wezterm
install_system ghostty
install_system zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
