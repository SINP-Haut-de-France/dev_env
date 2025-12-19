#!/usr/bin/env fish
# =============================================
# Script d'installation Arch Linux (fish)
# Pacman + AUR (yay)
# Nettoyé des doublons
# =============================================

function msg
    echo "\n==> $argv"
end

function err
    echo "Erreur: $argv" >&2
    exit 1
end

# ---- Vérifications de base ----
if test (id -u) -eq 0
    err "Ne pas lancer ce script en root. Utilise un utilisateur avec sudo."
end

if not type -q sudo
    err "sudo n'est pas installé"
end

# ---- Mise à jour système ----
msg "Mise à jour du système"
sudo pacman -Syu --noconfirm

# ---- Paquets officiels (pacman) ----
set PACMAN_PKGS \
    alembic \
    btop \
    digikam \
    dbeaver \
    discord \
    docker \
    docker-compose \
    firefox-esr-bin \
    gimp \
    git \
    inkscape \
    krita \
    ntfs-3g \
    onlyoffice-bin \
    remmina \
    ripgrep \
    thunderbird \
    timeshift \
    variety \
    vlc \
    yay

msg "Installation des paquets officiels"
sudo pacman -S --needed --noconfirm $PACMAN_PKGS

# ---- Docker ----
msg "Activation de Docker"
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# ---- Vérification yay ----
if not type -q yay
    err "yay n'est pas disponible après installation"
end

# ---- Paquets AUR (doublons supprimés) ----
set AUR_PKGS \
    anytype-bin \
    drawio \
    docker-compose-bin \
    google-chrome \
    gtkd \
    joplin-desktop \
    mongodb-compass-bin \
    neovim-git \
    nerdfonts-installer-bin \
    notepad++ \
    obsidian-bin \
    onedrivegui \
    pgloader \
    pulse-secure \
    pycharm \
    redisinsight-bin \
    teams-for-linux-bin \
    tilix \
    tufw-git \
    visual-studio-code-bin \
    webkit2gtk

msg "Installation des paquets AUR"
yay -S --needed --noconfirm $AUR_PKGS

# ---- ZSH + Oh-My-Zsh (ezsh) ----
msg "Installation de ZSH + Oh-My-Zsh (ezsh)"

if not test -d $HOME/ezsh
    git clone https://github.com/jotyGill/ezsh $HOME/ezsh
end

cd $HOME/ezsh
./install.sh -c

msg "Installation terminée"
echo "⚠️ Déconnexion/reconnexion requise pour Docker"
echo "⚠️ Tilix, tufw et certains outils nécessitent une configuration manuelle"
