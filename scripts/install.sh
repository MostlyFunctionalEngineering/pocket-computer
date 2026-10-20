#!/usr/bin/env bash
# Rebuilds the pocket computer on a fresh Raspberry Pi OS Lite (Bookworm, 64-bit).
# Flash the card with Raspberry Pi Imager using username "pocketcomputer", boot, SSH in, then:
#
#   git clone <this repo> ~/pocket-computer && bash ~/pocket-computer/scripts/install.sh
#
# Run as the normal user, not root. Safe to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$(id -un)" != "pocketcomputer" ]]; then
  echo "The service files hardcode /home/pocketcomputer. Create the user 'pocketcomputer' in Imager." >&2
  exit 1
fi

CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME:-unknown}")"
if [[ "$CODENAME" != "bookworm" ]]; then
  echo "WARNING: this setup was built and tested on Debian 12 (bookworm); this system is '$CODENAME'." >&2
  echo "It may still work, but it is untested. Press Ctrl-C within 10 seconds to abort." >&2
  sleep 10
fi

# Waveshare upstream commit this setup was built against (Apr 26 2025).
EPAPER_REPO="https://github.com/waveshareteam/e-Paper.git"
EPAPER_REF="f97f1ae168a14cf37525d4aedaa442833ca2dcc0"
# CardKB driver upstream (by ian-antking), pinned to the commit running on the author's Pi.
CARDKB_REPO="https://github.com/ian-antking/cardkb.git"
CARDKB_REF="abc948872e25f1201908615c82c93734707807fd"

echo "==> Installing packages"
sudo apt-get update
sudo apt-get install -y \
  git build-essential i2c-tools fbset rsync htop ncdu \
  python3-pip python3-venv python3-pil python3-numpy \
  python3-gpiozero python3-lgpio python3-rpi.gpio python3-spidev \
  python3-smbus python3-smbus2 python3-uinput \
  libncurses5-dev spi-tools

echo "==> Enabling SPI and I2C"
sudo raspi-config nonint do_spi 0
sudo raspi-config nonint do_i2c 0

echo "==> Kernel modules"
for m in i2c-dev uinput; do
  grep -qx "$m" /etc/modules || echo "$m" | sudo tee -a /etc/modules >/dev/null
done

echo "==> Framebuffer settings in config.txt"
CONFIG=/boot/firmware/config.txt
if ! grep -q "^hdmi_cvt=400 300" "$CONFIG"; then
  { echo; echo "# pocket-computer: fake 400x300 HDMI mode for the e-paper"; cat "$REPO_DIR/system/config.txt.snippet"; } \
    | sudo tee -a "$CONFIG" >/dev/null
fi

echo "==> Hide console cursor"
CMDLINE=/boot/firmware/cmdline.txt
grep -q "vt.global_cursor_default=0" "$CMDLINE" || sudo sed -i '1 s/$/ vt.global_cursor_default=0/' "$CMDLINE"

echo "==> Waveshare e-Paper library (sparse checkout at pinned commit)"
if [[ ! -d "$HOME/e-Paper/.git" ]]; then
  git clone --filter=blob:none --sparse "$EPAPER_REPO" "$HOME/e-Paper"
fi
git -C "$HOME/e-Paper" sparse-checkout set RaspberryPi_JetsonNano
git -C "$HOME/e-Paper" checkout "$EPAPER_REF"
install -m 755 "$REPO_DIR/src/main_display.py" \
  "$HOME/e-Paper/RaspberryPi_JetsonNano/python/examples/main_display.py"

echo "==> CardKB driver"
if [[ ! -d "$HOME/cardkb/.git" ]]; then
  git clone "$CARDKB_REPO" "$HOME/cardkb"
fi
[[ -n "$CARDKB_REF" ]] && git -C "$HOME/cardkb" checkout "$CARDKB_REF"

echo "==> Aliases"
install -m 644 "$REPO_DIR/system/bash_aliases" "$HOME/.bash_aliases"

echo "==> Services"
sudo install -m 644 "$REPO_DIR/system/eink-framebuffer.service" /etc/systemd/system/
sudo install -m 644 "$REPO_DIR/system/cardkb.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable eink-framebuffer.service cardkb.service

echo
echo "Done. Reboot to start everything:  sudo reboot"
