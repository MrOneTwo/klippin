set -o errexit
set -o nounset

mkdir -p run
mkdir -p gcode

stop_container() {
  local what=$1
  if docker stop ${what}; then
    CONTAINER_ID=$(docker ps --filter status=exited | awk -v what=${what} '{ if (index($2, what) != 0) print $1}')
    docker rm $CONTAINER_ID
  fi
}


# --- KLIPPER ---

start_klippy() {
  docker run \
    --privileged \
    --name klipper \
    -v /dev:/dev
    -v $(pwd)/run:/opt/printer_data/run \
    -v $(pwd)/gcode:/opt/printer_data/gcodes \
    -v $(pwd)/printer.cfg:/opt/printer_data/config/printer.cfg \
    mkuf/klipper:latest
}

stop_klippy() {
  stop_container "klipper"
}

# --- MOONRAKER ---

start_moonraker() {
  # without privileged I'm getting python thread errors
  docker run \
    --privileged \
    --name moonraker \
    -v $(pwd)/run:/opt/printer_data/run \
    -v $(pwd)/gcode:/opt/printer_data/gcodes \
    -v $(pwd)/moonraker.conf:/opt/printer_data/config/moonraker.conf \
    -p 7125:7125 \
    mkuf/moonraker:latest
}

stop_moonraker() {
  stop_container "moonraker"
}

"$@"
