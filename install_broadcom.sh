#!/bin/bash

# Broadcom BCM43142 WiFi Driver Installation Script for Debian
# This script installs the driver, enables NetworkManager, and connects to WiFi

set -e  # Exit on error

# Check if script is running as sudo
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as sudo or root"
   echo "Usage: sudo ./install_broadcom.sh"
   exit 1
fi

echo "=== Updating Debian Repository Sources ==="

# Add contrib non-free non-free-firmware to sources.list (excluding security)
echo "Updating /etc/apt/sources.list..."

# Backup original sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Add components to deb and deb-src lines (excluding security.debian.org)
sed -i '/^deb http.*debian.org.*main$/s/$/ contrib non-free non-free-firmware/' /etc/apt/sources.list
sed -i '/^deb-src http.*debian.org.*main$/s/$/ contrib non-free non-free-firmware/' /etc/apt/sources.list

# Display updated sources.list
echo "Updated sources.list (non-security lines):"
grep -v security /etc/apt/sources.list | grep -v "^#" | grep -v "^$"

echo ""
echo "=== Installing Broadcom BCM43142 Driver ==="

# Update package lists
echo "Updating package lists..."
apt update

# Install linux headers
echo "Installing linux headers..."
apt install -y linux-headers-$(uname -r)

# Install broadcom-sta driver
echo "Installing broadcom-sta-dkms..."
apt install -y broadcom-sta-dkms

# Build and install the module
echo "Building and installing DKMS module..."
BROADCOM_VERSION=$(ls /var/lib/dkms/broadcom-sta/ | tail -1)
dkms install broadcom-sta/$BROADCOM_VERSION

# Load the wl module
echo "Loading wl kernel module..."
modprobe wl

# Make it persistent across reboots
echo "wl" | tee /etc/modules-load.d/broadcom-wl.conf > /dev/null

echo "=== Installing NetworkManager ==="

# Install NetworkManager
apt install -y network-manager

# Start and enable NetworkManager
echo "Starting NetworkManager..."
systemctl start NetworkManager
systemctl enable NetworkManager

# Check status
echo "NetworkManager status:"
systemctl status NetworkManager

echo "=== Connecting to WiFi ==="

# Connect to WiFi
read -p "Enter WiFi network name (SSID): " SSID
read -sp "Enter WiFi password: " PASSWORD
echo ""

echo "Connecting to '$SSID'..."
nmcli dev wifi connect "$SSID" password "$PASSWORD"

echo "=== Installation Complete ==="
echo "WiFi connection established!"
echo ""
echo "Backup of original sources.list saved to: /etc/apt/sources.list.backup"
