# Pocket Computer

A battery-powered pocket computer featured on my YouTube channel: [Mostly Functional Engineering](https://www.youtube.com/@MostlyFunctionalEngineering).
It uses a Raspberry Pi Zero 2 W with a 4.2" e-paper
screen (400×300) and an M5Stack CardKB keyboard, in a 3D-printed case. The Linux
console runs on the e-paper display, you type on the CardKB, and it charges over USB-C
from a 10000 mAh battery. It features custom aliased commands for e-ink refreshing / clearing. 

Here's my youtube video showcasing the build process: https://youtu.be/sdcX1ghOkFM

![YTThumbnail](docs\yt_thumbnail.jpg)

## Build it

1. **Buy the parts** → [docs/parts-list.md](docs/parts-list.md)
2. **Print the case** → [cad/](cad/)
3. **Wire it up** → [docs/wiring.md](docs/wiring.md)
4. **Install the OS and software** → [docs/os-setup.md](docs/os-setup.md)

> **Heads-up on the case:** the 3D-printed assembly doesn't go together very well on
> its own. Expect to glue a lot. It did work, and the video shows where
> everything is placed, but this could use some work.

Built and tested on Raspberry Pi OS Lite (64-bit), Debian 12 "Bookworm" (May 2025 release).

## How it works

```
 CardKB --I2C(0x5F)--> cardkb.service --uinput--> virtual keyboard --> Linux console (tty1)
                                                                            |
                                                                  /dev/fb0 (400x300)
                                                                            |
 e-paper <--SPI-- eink-framebuffer.service (main_display.py) <--reads-------+
```

1. **Fake HDMI mode.** `config.txt` forces a 400×300 HDMI mode so the console
   framebuffer matches the panel (`system/config.txt.snippet`). With the default console
   font that gives a 50-column by 37-row terminal.
2. **Display mirroring.** `eink-framebuffer.service` runs `src/main_display.py`
   once a second. It reads `/dev/fb0`, thresholds it to black and white, and pushes it
   to the panel with the Waveshare `epd4in2_V2` driver. Changed frames use a partial
   refresh, and every 15 minutes it does a full refresh to clear ghosting.
3. **Manual refresh.** The `refresh` and `clear` aliases (`system/bash_aliases`) touch
   `/tmp/eink_force_refresh`. `main_display.py` sees the file, deletes it and does a
   full refresh. This works over SSH too.
4. **Keyboard.** `cardkb.service` runs the `cardkb` driver (upstream:
   ian-antking/cardkb). It polls the CardKB over I2C and emits keystrokes through
   `uinput`, so the console sees a normal keyboard. It runs as root.

Upstream code isn't copied into this repo. `scripts/install.sh` clones it:

- Waveshare e-Paper, pinned to commit `f97f1ae168a14cf37525d4aedaa442833ca2dcc0`
  (sparse checkout of `RaspberryPi_JetsonNano` only). They made the display, so I figured best to leave the link there. 
- ian-antking/cardkb. This runs the keyboard.

No pip packages are needed. Everything comes from apt.

## Repo layout

```
cad/                            3D-printable case files
docs/parts-list.md              what to buy
docs/wiring.md                  power + pin tables, wiring diagram
docs/wiring-diagram.jpg
docs/os-setup.md                flash the OS, run the installer, verify
src/main_display.py             framebuffer -> e-paper mirror
system/eink-framebuffer.service
system/cardkb.service
system/config.txt.snippet       HDMI/framebuffer settings
system/bash_aliases             refresh / clear aliases
scripts/install.sh              sets up everything on a fresh OS
```

## Credits

This project uses Waveshare's e-Paper library and ian-antking's CardKB driver. Neither is
copied here; the installer downloads them from their original repositories. See
[CREDITS.md](CREDITS.md).

## Handy commands

```bash
systemctl status eink-framebuffer cardkb
journalctl -u eink-framebuffer -f
sudo i2cdetect -y 1                # CardKB should show at 0x5f
refresh                            # force a full e-paper refresh
```
