#!/bin/bash

set -eu

if [ "$(id -u)" = '0' ]; then
  chown -R "${PUID}:${PGID}" "${HOME}" && \
  exec gosu "${PUID}:${PGID}" "$@"
else
  exec "$@"
fi
