#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Update packages list and update system
apt update
apt upgrade -y

# Install nala
apt install nala -y

# xorg display server installation
sudo nala install -y xorg xbacklight xbindkeys xinput xorg-dev x11-xserver-utils

# INCLUDES make,etc.
sudo nala install -y build-essential  

# Network Manager
sudo nala install -y network-manager-gnome nm-applet

# Installation for Appearance management
sudo nala install -y lxappearance papirus-icon-theme

# Download Nordic Theme
cd /usr/share/themes/
git clone https://github.com/EliverLara/Nordic.git

# File Manager (eg. pcmanfm,krusader)
sudo nala install -y thunar

# Network File Tools/System Events
sudo nala install -y dialog mtools dosfstools avahi-daemon acpi acpid gvfs-backends

sudo systemctl enable avahi-daemon
sudo systemctl enable acpid

# Terminal (eg. terminator,kitty)
#sudo nala install -y tilix

# Sound packages
sudo nala install -y pulseaudio pavucontrol pasystray 

# Neofetch/BTOP
sudo nala install -y neofetch btop

# Printing and bluetooth (if needed)
sudo nala install -y cups
sudo nala install -y bluez blueman

sudo systemctl enable bluetooth
sudo systemctl enable cups

# Browser Installation (eg. chromium)
# sudo nala install -y firefox-esr 

# Desktop background browser/handler 
sudo nala install -y variety 

# Packages needed dwm after installation
sudo nala install -y picom numlockx dunst libnotify-bin unzip lxpolkit

# Install fonts
sudo nala install fonts-font-awesome fonts-ubuntu fonts-liberation2 fonts-liberation fonts-terminus 

# Create folders in user directory (eg. Documents,Downloads,etc.)
xdg-user-dirs-update

# Ly Console Manager
# Needed packages
sudo nala install -y libpam0g-dev libxcb-xkb-dev
cd 
git clone --recurse-submodules https://github.com/fairyglade/ly
cd ly
make
sudo make install installsystemd
sudo systemctl enable ly.service


# XSessions and dwm.desktop
if [[ ! -d /usr/share/xsessions ]]; then
    sudo mkdir /usr/share/xsessions
fi

cat > ./temp << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=dwm
Comment=Dynamic window manager
Exec=dwm
Icon=dwm
Type=XSession
EOF
sudo cp ./temp /usr/share/xsessions/dwm.desktop;rm ./temp


# Creating directories
mkdir ~/.config/suckless

sudo nala install -y libx11-dev libxft-dev libxinerama-dev

# Download dwm
git clone https://github.com/budney76/mydwm.git
cd ~/.config/suckless/mydwm
sudo make install
cd ~

# Move install directory, make, and install
cd ~/.config/suckless
tools=( "dmenu" "st" "slstatus" )
for tool in ${tools[@]}
do 
	git clone git://git.suckless.org/$tool
	cd ~/.config/suckless/$tool;make;sudo make clean install;cd ..
done


# Use nala
bash scripts/usenala


sudo nala autoremove


printf "\e[1;32mDone! you can now reboot.\e[0m\n"
