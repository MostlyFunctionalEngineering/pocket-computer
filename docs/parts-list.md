# Parts list

> The Amazon links below are the author's affiliate links; buying through them helps
> support projects like this. Any equivalent part works if it matches the notes.

## Main parts

| Part | Notes | Link |
|---|---|---|
| Raspberry Pi Zero 2 W | The board this repo targets | https://amzn.to/49cc0YQ |
| Waveshare 4.2" e-Paper Module, 400×300, black/white (V2) | Black/white only, see the warning below | https://amzn.to/4urvNMh |
| M5Stack CardKB keyboard | Remove its connector and solder wires directly (see wiring) | https://amzn.to/4v4VToi |
| 5V 2A battery charging / boost board | USB-C charging, 5V output, push-button on/off | https://amzn.to/4dqmJkP |
| 10000 mAh 3.7V LiPo battery | MakerFocus pack with a JST PH2.0 connector | https://link.amazon/B0fbGa4Iq |
| JST PH2.0 right-angle male connector | Soldered to the charging board's battery pads | https://link.amazon/B02EUXIJ5 |
| Momentary push button | The power switch for the charging board | https://link.amazon/B0d4lgHDo |
| 32 GB microSD card | | https://link.amazon/B0bEnbmyj |

> **Buy the black/white display.** The red/black/white version of the 4.2" Waveshare
> module (the "B" variant) won't work. Red displays don't have fast refresh, which this
> setup relies on, and they need a different driver. This repo uses the `epd4in2_V2`
> driver.

## Alternative (warning)

| Part | Notes | Link |
|---|---|---|
| Orange Pi Zero 2W | Don't use it, as the i2c libraries, at least when I was setting mine up, were all out of whack.

## Other things you'll need

Soldering gear, hookup wire, a 3D printer (see [cad/](../cad/)), glue (I like a rubbery style glue for this over a super glue).
