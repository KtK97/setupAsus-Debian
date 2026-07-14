#!/usr/bin/env bash
#
# Lock down SSH to Tailscale only.
# Resets all UFW rules, then allows inbound SSH on the tailscale0 interface
# and denies SSH from everything else.
#
# Usage:
#   sudo ./tailscale-ssh-firewall.sh        # interactive (asks for confirmation)
#   sudo ./tailscale-ssh-firewall.sh --yes  # non-interactive (CI / scripts)
#

set -euo pipefail

FORCE="no"
if [[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]]; then
  FORCE="yes"
fi

# --- Sanity checks --------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
  echo "❌  Please run as root (sudo $0)" >&2
  exit 1
fi

if ! command -v ufw >/dev/null 2>&1; then
  echo "❌  ufw is not installed." >&2
  echo "    Install with:  sudo apt install ufw   (or your distro equivalent)" >&2
  exit 1
fi

if ! ip link show tailscale0 >/dev/null 2>&1; then
  echo "⚠️   tailscale0 interface is not up." >&2
  echo "    Bring Tailscale up first:  sudo tailscale up" >&2
  echo "    If you continue, SSH will be locked out until you fix Tailscale." >&2
  if [[ "$FORCE" != "yes" ]]; then
    read -r -p "    Continue anyway? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
  fi
fi

# --- Confirmation ---------------------------------------------------------

if [[ "$FORCE" != "yes" ]]; then
  echo "This will:"
  echo "  1. Reset ALL existing UFW rules"
  echo "  2. Allow SSH (22/tcp) only via the tailscale0 interface"
  echo "  3. Deny SSH from anywhere else"
  echo
  echo "⚠️   If Tailscale is not reachable, you will lock yourself out."
  echo "    Make sure you have console / out-of-band access."
  echo
  read -r -p "Proceed? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

# --- Apply rules ----------------------------------------------------------

echo "→ Resetting UFW..."
ufw --force reset

echo "→ Setting defaults..."
ufw default deny incoming
ufw default allow outgoing

echo "→ Allowing SSH on tailscale0..."
ufw allow in on tailscale0 to any port 22 proto tcp comment 'Tailscale SSH'

echo "→ Denying SSH from everywhere else..."
ufw deny 22/tcp comment 'Block public SSH'

echo "→ Enabling UFW..."
ufw --force enable

echo
echo "✅ Done. Current status:"
echo
ufw status verbose