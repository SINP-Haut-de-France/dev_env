#!/usr/bin/env bash
set -e

echo "=== openSUSE Tumbleweed bootstrap ==="

if [[ $EUID -ne 0 ]]; then
  echo "Run as root (sudo)"
  exit 1
fi

# --- Base system ---
zypper refresh
zypper update -y

zypper install -y \
  git curl wget unzip tar \
  docker docker-compose \
  podman \
  vim neovim \
  zsh \
  btop \
  ripgrep \
  fzf \
  ntfs-3g \
  gnome-boxes \
  flameshot \
  alacritty kitty wezterm \
  thunderbird \
  vlc \
  gimp inkscape krita \
  libreoffice \
  dbeaver \
  remmina \
  redis \
  postgresql17 postgresql17-server \
  pgloader \
  mongodb-tools \
  fuse \
  timeshift

# --- Enable Docker ---
systemctl enable docker
systemctl start docker

# --- Flatpak ---
zypper install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
  com.spotify.Client \
  com.discordapp.Discord \
  org.gimp.GIMP \
  md.obsidian.Obsidian \
  org.joplinapp.Joplin \
  com.anytype.Anytype \
  io.github.mimbrero.WhatsAppDesktop \
  com.github.IsmaelMartinez.teams_for_linux \
  com.visualstudio.code \
  org.mozilla.firefox \
  org.mozilla.Thunderbird \
  org.chromium.Chromium \
  com.mongodb.Compass \
  org.torproject.torbrowser-launcher \
  org.libreoffice.LibreOffice

# --- JetBrains PyCharm ---
if [[ ! -d /opt/pycharm ]]; then
  curl -L https://download.jetbrains.com/python/pycharm-professional.tar.gz \
    | tar xz -C /opt
  ln -sf /opt/pycharm-*/bin/pycharm.sh /usr/local/bin/pycharm
fi

# --- Rust ---
if [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y
fi

# --- Zsh / Oh My Zsh ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  su "$SUDO_USER" -c \
    'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

echo "=== Tumbleweed bootstrap done ==="

