#!/bin/sh
set -e

wait_for()
{
   until
      until
         inotifywait --event create "$(dirname "$1")"&
         inotify_pid=$!
         [ -e "$1" ] || sleep 2 && [ -e "$1" ]
      do
         wait "${inotify_pid}"
      done
      kill "${inotify_pid}"
      [ -O "$1" ]
   do
      sleep 1
   done
}

if snapctl is-connected wayland
then
   real_xdg_runtime_dir=$(dirname "${XDG_RUNTIME_DIR}")
   export WAYLAND_DISPLAY="${real_xdg_runtime_dir}/${WAYLAND_DISPLAY:-wayland-0}"

   # On core systems may need to wait for real XDG_RUNTIME_DIR
   wait_for "${real_xdg_runtime_dir}"
   wait_for "${WAYLAND_DISPLAY}"

   mkdir -p "$XDG_RUNTIME_DIR" -m 700
elif [ -S $(dirname "${XDG_RUNTIME_DIR}")/${WAYLAND_DISPLAY:-wayland-0} ]
then
   echo "WARNING: wayland interface not connected! Please run as superuser: snap connect retroarch:wayland"
fi

unset DISPLAY

exec "$@"
