# ASUS Debian Setup Scripts

This repository contains automation scripts for setting up a fresh Debian installation on ASUS laptops, particularly those with Broadcom wireless hardware.

## Scripts Overview

### `install_broadcom.sh`

**Purpose:** Automates the installation of Broadcom BCM43142 WiFi driver on Debian-based systems.

**Target Hardware:** ASUS laptops with Broadcom BCM43142 wireless network adapters.

**Target OS:** Debian Linux (tested with recent stable releases).

---

## Prerequisites

Before running the scripts, ensure the following:

1. **System Requirements:**
   - Debian Linux installed (fresh installation recommended)
   - Internet connection via Ethernet (wired) - *required for package downloads*
   - Sudo/root access

2. **Dependencies:**
   - `bash` (included by default on Debian)
   - `sudo` (included by default on Debian)
   - `apt` package manager
   - `systemd` (for NetworkManager service management)

---

## Usage Instructions

### Installing Broadcom WiFi Driver

The `install_broadcom.sh` script automates the complete process of enabling WiFi on ASUS laptops with Broadcom BCM43142 adapters.

#### Step-by-Step Guide:

1. **Download the Script:**
   ```bash
   # Clone this repository or download the script directly
   git clone https://github.com/your-repo/setupAsus-Debian.git
   cd setupAsus-Debian
   ```

2. **Make the Script Executable:**
   ```bash
   chmod +x install_broadcom.sh
   ```

3. **Run the Script as Root:**
   ```bash
   sudo ./install_broadcom.sh
   ```

4. **Follow the Prompts:**
   - The script will automatically update repositories and install required packages
   - When prompted, enter your WiFi network name (SSID)
   - Enter your WiFi password when requested

5. **Completion:**
   - The script will display a completion message once installation is successful
   - WiFi connection will be established automatically
   - Reboot to ensure all changes persist (optional but recommended)

---

## What the Script Does

The `install_broadcom.sh` script performs the following actions:

### 1. Repository Configuration
- Creates a backup of the original `/etc/apt/sources.list`
- Adds `contrib`, `non-free`, and `non-free-firmware` components to Debian repository sources
- This enables access to proprietary drivers and firmware packages

### 2. Package Installation
- Updates the package list (`apt update`)
- Installs Linux headers for the current kernel version
- Installs `broadcom-sta-dkms` package (the proprietary Broadcom driver)

### 3. Driver Setup
- Builds and installs the DKMS (Dynamic Kernel Module Support) module for the Broadcom driver
- Loads the `wl` kernel module
- Configures the module to load automatically on system boot

### 4. Network Management
- Installs NetworkManager for WiFi connection management
- Starts and enables the NetworkManager service
- Verifies NetworkManager is running

### 5. WiFi Connection
- Prompts the user for WiFi SSID (network name)
- Prompts the user for WiFi password (secure input, not displayed)
- Connects to the specified WiFi network using `nmcli`

---

## Script Behavior

### Error Handling
- The script uses `set -e` which causes it to exit immediately if any command fails
- It checks for root/sudo privileges before starting and will error if not run as root

### Backups
- The original `/etc/apt/sources.list` is backed up to `/etc/apt/sources.list.backup`
- This allows easy restoration if needed

### Persistence
- The `wl` module is configured to load at boot via `/etc/modules-load.d/broadcom-wl.conf`
- NetworkManager is enabled to start on system boot

---

## Troubleshooting

### Common Issues

1. **Script fails with permission error:**
   - Solution: Run the script with `sudo` or as root user
   
2. **No Internet connection:**
   - Ensure you have a wired Ethernet connection before running the script
   - The script requires Internet access to download packages

3. **Driver not loading after reboot:**
   - Verify the `wl` module is loaded: `lsmod | grep wl`
   - Check if the module is in the boot configuration: `cat /etc/modules-load.d/broadcom-wl.conf`

4. **WiFi connection fails:**
   - Verify NetworkManager is running: `systemctl status NetworkManager`
   - Check WiFi interface status: `ip link show`
   - Verify SSID and password were entered correctly

5. **DKMS build errors:**
   - Ensure Linux headers are installed for your kernel version
   - Check for error messages during the DKMS build step

---

## Manual Verification

After running the script, you can verify the installation:

```bash
# Check if wl module is loaded
lsmod | grep wl

# Check if Broadcom driver is recognized
lspci -k | grep -A 3 -i broadcom

# Check NetworkManager status
systemctl status NetworkManager

# Check WiFi connection
nmcli connection show

# Check if firmware is loaded
dmesg | grep -i broadcom
dmesg | grep -i wl
```

---

## Restoring Original State

If you need to revert the changes made by the script:

1. **Restore sources.list:**
   ```bash
   sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list
   ```

2. **Remove Broadcom driver:**
   ```bash
   sudo apt remove --purge broadcom-sta-dkms
   sudo dkms remove broadcom-sta/VERSION --all
   ```

3. **Disable wl module:**
   ```bash
   sudo rm /etc/modules-load.d/broadcom-wl.conf
   sudo modprobe -r wl
   ```

4. **Reinstall default driver (if applicable):**
   ```bash
   sudo apt install firmware-b43-installer b43-fwcutter
   ```

---

## File Structure

```
setupAsus-Debian/
├── install_broadcom.sh    # Broadcom BCM43142 WiFi driver installation script
└── readme.md              # This file
```

---

## Compatibility

- **Tested on:** Debian 12 (Bookworm) and newer
- **Hardware:** ASUS laptops with Broadcom BCM43142 WiFi adapters
- **Kernel:** Linux kernel 5.x and newer

---

## License

This project is open source. The scripts are provided as-is without warranty.

---

## Contributing

Contributions are welcome. Please open an issue or submit a pull request for any improvements or additional scripts.

---

## Notes

- This script is designed specifically for Broadcom BCM43142 adapters. It may not work with other Broadcom models.
- The script installs proprietary firmware and drivers, which are not part of the default Debian free software repository.
- A wired Internet connection is required to download the necessary packages during installation.