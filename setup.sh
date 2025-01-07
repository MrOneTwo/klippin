mkdir -p run
mkdir -p gcode

docker run \
  --privileged \
  --name klipper \
  -v /dev:/dev
  -v $(pwd)/run:/opt/printer_data/run \
  -v $(pwd)/gcode:/opt/printer_data/gcodes \
  -v $(pwd)/printer.cfg:/opt/printer_data/config/printer.cfg \
  mkuf/klipper:latest

# without privileged I'm getting python thread errors
docker run \
  --privileged \
  --name moonraker \
  -v $(pwd)/run:/opt/printer_data/run \
  -v $(pwd)/gcode:/opt/printer_data/gcodes \
  -v $(pwd)/moonraker.conf:/opt/printer_data/config/moonraker.conf \
  -p 7125:7125 \
  mkuf/moonraker:latest
