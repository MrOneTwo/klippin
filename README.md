I struggled to setup Klipper on my PC. Usually it's desgined for SBCs, but I wanted
to test it on a laptop - it's PITA.

- make sure the user owns the pre-created directories and files

# Klipper

Install the firmware on the 3D printer mainboard. Put that built firmware on the SD card with
a file `firmware.bin`.

Create `printer.cfg`. For me it's a mix of config file for SKR mini E3 v3.0, Creality LCD and
`mainsail.cfg`.

That's enought to start the Klippy:

```sh
docker run \
  --privileged \
  --name klipper \
  -v /dev:/dev \
  -v `pwd`/run:/opt/printer_data/run \
  -v `pwd`/printer.cfg:/opt/printer_data/config/printer.cfg \
  mkuf/klipper:latest
```

# Moonraker

I had to add `--privileged` because I saw issues with Python creating a thread.

```sh
docker run \
  --privileged \
  --name moonraker \
  -v $(pwd)/run:/opt/printer_data/run \
  -v $(pwd)/gcode:/opt/printer_data/gcodes \
  -v $(pwd)/moonraker.conf:/opt/printer_data/config/moonraker.conf \
  -p 7125:7125 \
  mkuf/moonraker:latest
```


## Consistent name for the serial

The path to the serial device is hardcoded in the `printer.cfg`. OS can assign different
names to that serial. We want a constent name. We can do that with *udev*.

```
udevadm info --attribute-walk --path=$(udevadm info --query=path --name=/dev/ttyACM0)
```

Create a `/etc/udev/rules.d/99-3dprinter.rules`:

```
SUBSYSTEM=="tty", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="614e", SYMLINK+="3dprinter", MODE="0666"
```

This will create a symlink `/dev/3dprinter`.

Reload rules:

```
sudo udevadm control --reload-rules
sudo udevadm trigger
```

# Frontend

Failed to run mainsail or fluidd through docker but http://app.fluidd.xyz/ and
http://my.mainsail.xyz work.
