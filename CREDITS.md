# Credits and third-party code

This project builds on other people's work. Their code is not copied into this repository.
You intall it from the original source at a pinned commit, so you get it from
the people who wrote it.

## Waveshare e-Paper library

- **By:** Waveshare (waveshareteam)
- **Source:** https://github.com/waveshareteam/e-Paper
- **Pinned commit:** `f97f1ae168a14cf37525d4aedaa442833ca2dcc0` (2025-04-26)
- **Used for:** the `waveshare_epd` Python library from `RaspberryPi_JetsonNano`
  (the `epd4in2_V2` display driver and `epdconfig.py` GPIO/SPI layer).
- **How it's used here:** `scripts/install.sh` sparse-clones the library at the pinned
  commit and uses it unmodified. `src/main_display.py` is original to this project and
  calls the library.
- **License:** the library's source files, including `epd4in2_V2.py`, carry an MIT-style
  permission notice in their header comments, credited to "Waveshare team". The notice
  must stay with any copies of the code. This repository contains none of it; the
  installer downloads the files from Waveshare.

## CardKB driver

- **By:** ian-antking
- **Source:** https://github.com/ian-antking/cardkb
- **Pinned commit:** `abc948872e25f1201908615c82c93734707807fd`
- **Used for:** reading the CardKB over I2C and turning key presses into keyboard input
  through `uinput`.
- **How it's used here:** `scripts/install.sh` clones it at the pinned commit and runs it
  unmodified as `cardkb.service`.
- **License:** the upstream repository doesn't appear to include a license file, so this
  repository contains none of its code. If you reuse or redistribute it, check with the
  upstream author.

## Hardware

- **M5Stack CardKB** keyboard: https://m5stack.com
- **Waveshare 4.2" e-Paper Module:** https://www.waveshare.com

## This project's own files

`src/main_display.py`, the systemd service files, the config snippet, the aliases, the
installer and the documentation are original to this project. License: TODO.
