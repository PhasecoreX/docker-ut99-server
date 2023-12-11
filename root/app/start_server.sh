#!/usr/bin/env sh
set -euf

# Check if the user actually volume/bind mounted the /data directory
if [ "$(stat -c "%d" /)" -eq "$(stat -c "%d" /data)" ]; then
    echo ""
    echo "Try reading the instructions before running this image!" >&2
    exit 1
fi

# Download/update server files
/app/install.sh /data/server

# Switch to the server System directory, make server executible
if [ "$(uname -m)" = "aarch64" ]; then
    rm -rf /data/server/System64
    cd /data/server/SystemARM64
else
    rm -rf /data/server/SystemARM64
    cd /data/server/System64
fi
chmod +x ./ucc-bin

# Make and set up addons directory if it doesn't exist
mkdir -p /data/addons/System
ln -sf /data/addons /config/.utpg

# Move any .ini files in old System directory into /data/addons/System (no overwrite)
set +f
find /data/server/System/ -type f -name '*.ini' -exec mv -n -t /data/addons/System {} +
rm -f /data/server/System/*.ini
set -f

# If $COMPRESS_DIR is defined, compress.sh will compress files into it
if [ -n "${COMPRESS_DIR:-}" ]; then
    /app/compress.sh "${COMPRESS_DIR}"
fi

# Finally, run the server
echo "Starting server..."
server_command="${MAP_NAME:-"DM-Agony"}?game=${GAME_TYPE:-"Botpack.DeathMatchPlus"}"
if [ -n "${MUTATORS:-}" ]; then
    server_command="${server_command}?mutator=${MUTATORS}"
fi
server_command="${server_command}${SERVER_START_EXTRAS:-}"
exec ./ucc-bin server "${SERVER_START_COMMAND:-"${server_command}"}" ini=UnrealTournament.ini -lanplay
