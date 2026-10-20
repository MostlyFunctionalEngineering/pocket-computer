# OS and software setup

You'll need the finished wiring ([wiring.md](wiring.md)), a microSD card, and a computer
with [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

## 1. Pick the OS image

This project was built and tested on **Raspberry Pi OS Lite (64-bit) based on Debian 12
"Bookworm"**, build reference 2025-05-06 (the May 2025 release; that's the date in
`/boot/firmware/issue.txt` on the author's Pi).

Raspberry Pi's current release is based on Debian Trixie, which Imager offers by default.
It hasn't been tested with this project. To match what was tested, use a Bookworm image:
Raspberry Pi hosts older images at
https://downloads.raspberrypi.org/raspios_lite_arm64/images/. Download the May 2025
release or a later Bookworm one, then choose the custom image option in Imager to flash it.

The installer warns if the system isn't Bookworm, so you can try Trixie and see.

## 2. Flash the card

In Imager, choose Raspberry Pi Zero 2 W as the device, then the OS image, then your card.
Set these in the customisation options before writing:

- **Username `pocketcomputer`** (required: the service files use `/home/pocketcomputer`, though I will probably fix that at some point).
- A password of your choice
- Your Wi-Fi network (the Zero 2 W is 2.4 GHz only)
- SSH enabled
- Hostname is optional; I used `raspberrypizero`

## 3. First boot

Put the card in the Pi and power it, from the battery board or from USB, but not both at
once. The first boot takes a few minutes. The screen stays blank until the software is
installed, so connect over SSH:

```bash
ssh pocketcomputer@raspberrypizero.local
```

If the name doesn't resolve, find the Pi's IP address in your router and use that.

## 4. Install

```bash
sudo apt-get update && sudo apt-get install -y git
git clone https://github.com/MostlyFunctionalEngineering/pocket-computer.git
bash ~/pocket-computer/scripts/install.sh
sudo reboot
```

The installer is safe to re-run. It:

- installs the apt packages (Python imaging/GPIO/SPI/I2C libraries, i2c-tools, build tools)
- enables SPI and I2C, and loads the `i2c-dev` and `uinput` modules at boot
- adds the 400×300 framebuffer settings to `/boot/firmware/config.txt`
- hides the console cursor
- clones the Waveshare e-Paper library at the pinned commit and installs
  `main_display.py` into it
- clones the CardKB driver
- installs the `refresh` and `clear` aliases
- installs and enables `eink-framebuffer.service` and `cardkb.service`

## 5. Check that it works

After the reboot, the e-paper should show a login prompt within a minute or so. Type with
the CardKB to log in. If something's off, from an SSH session:

```bash
systemctl status eink-framebuffer cardkb
journalctl -u eink-framebuffer -n 50
sudo i2cdetect -y 1                  # CardKB should appear at 5f
ls /dev/spidev0.0 /dev/i2c-1 /dev/fb0
```

| Symptom | Things to check |
|---|---|
| Screen stays blank | `journalctl -u eink-framebuffer`; display wiring; SPI enabled |
| Keyboard types nothing | `i2cdetect` shows 5f?; `systemctl status cardkb`; CardKB wiring |
| Ghosting on the screen | Type `refresh` (or `clear`) for a full refresh |

## Using it

`refresh` and `clear` both force a full e-paper refresh. `clear` also clears the terminal.
The display also does a full refresh by itself every 15 minutes.
