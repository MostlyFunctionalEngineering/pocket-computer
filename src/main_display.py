#!/usr/bin/python
# -*- coding:utf-8 -*-
# Mirrors the Linux framebuffer (/dev/fb0, forced to 400x300 by config.txt)
# onto a Waveshare 4.2" V2 e-paper display.
#
# Installed to: ~/e-Paper/RaspberryPi_JetsonNano/python/examples/main_display.py
# Run by:       eink-framebuffer.service
# Full refresh: touch /tmp/eink_force_refresh   (the `refresh` and `clear` aliases do this)
import sys
import os
basedir = os.path.abspath(os.path.dirname(__file__))
picdir = os.path.join(basedir, '..', 'pic')
libdir = os.path.join(basedir, '..', 'lib')
if os.path.exists(libdir):
    sys.path.append(os.path.abspath(libdir))

import mmap
import logging
from waveshare_epd import epd4in2_V2
import time
from PIL import Image,ImageDraw,ImageFont,ImageOps
import traceback

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

first_update = True  # Global flag
SOFT_REFRESH_INTERVAL = 15 * 60  # 15 minutes (in seconds)
last_soft_refresh = 0  # Epoch time

FB_PATH = '/dev/fb0'
FB_WIDTH = 400
FB_HEIGHT = 300
FB_BPP = 32  # bits per pixel (RGBA = 4 bytes)

last_hash = None

def read_framebuffer(width, height, bpp):
    fb_size = width * height * (bpp // 8)
    with open(FB_PATH, 'rb') as f:
        mm = mmap.mmap(f.fileno(), fb_size, mmap.MAP_SHARED, mmap.PROT_READ)
        img = Image.frombuffer("RGBA", (width, height), mm[:], "raw", "BGRA")
        mm.close()
    return img

def render_to_epaper(epd, image):
    global last_hash, first_update, last_soft_refresh

    refresh_signal_path = "/tmp/eink_force_refresh"

    # Check for external full refresh signal
    force_refresh = os.path.exists(refresh_signal_path)
    if force_refresh:
        logger.info("Received manual full refresh request")
        os.remove(refresh_signal_path)

    gray = image.convert("L")
    inverted = ImageOps.invert(gray)
    bw_image = inverted.point(lambda x: 0 if x < 175 else 255, mode='1') #was 128, set to 90

    content_hash = hash(bw_image.tobytes())
    now = time.time()
    buffer = epd.getbuffer(bw_image)

    do_soft_refresh = now - last_soft_refresh > SOFT_REFRESH_INTERVAL
    content_changed = content_hash != last_hash

    if first_update:
        logger.info("Initial update — using display_Fast()")
        epd.display_Fast(buffer)
        first_update = False
        last_soft_refresh = now
        last_hash = content_hash
        return

    if do_soft_refresh or force_refresh:
        logger.info("Performing periodic full refresh — display()")
        epd.init()
        epd.Clear()
        epd.display_Fast(buffer)
        last_soft_refresh = now
        last_hash = content_hash
        return

    if content_changed:
        logger.info("Framebuffer changed — using display_Partial()")
        epd.display_Partial(buffer)
        last_hash = content_hash
    else:
        logger.debug("No change — skipping refresh")

def main():
    global first_update

    epd = epd4in2_V2.EPD()
    epd.init_fast(epd.Seconds_1S)
    epd.Clear()

    try:
        while True:
            try:
                fb_image = read_framebuffer(FB_WIDTH, FB_HEIGHT, FB_BPP)
                render_to_epaper(epd, fb_image)
                time.sleep(1)
            except Exception as e:
                logger.error(f"Error: {e}")
                time.sleep(1)
    except KeyboardInterrupt:
        logger.info("Interrupted — clearing screen and sleeping")
        epd.init()
        epd.Clear()
        epd.sleep()

if __name__ == '__main__':
    main()
