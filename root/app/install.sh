#!/usr/bin/env sh
set -euf

download_install() {
    set -e
    url=$1
    md5=$2
    filename=$3

    # If the user knows what they're doing, skip all downloads
    if [ "${SKIP_INSTALL:-}" = "true" ]; then
        return
    fi

    # If this pack is up to date, skip downloading it
    if [ -f "/data/server/.versions/${filename}.txt" ] && [ "$(cat "/data/server/.versions/${filename}.txt")" = "${md5}" ]; then
        return
    fi

    echo "Downloading ${filename} archive..."
    if [ -z "${url##*'google.com'*}" ]; then
        curl -#SL -c cookies.txt "${url}" | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' >confirm.txt
        curl -#SL -b cookies.txt -o "${filename}" "${url}&confirm=$(cat confirm.txt)"
        rm -f confirm.txt cookies.txt
    else
        curl -#SL "${url}" -o "${filename}"
    fi

    echo "Verifying md5 checksum ${md5}"
    echo "${md5} ${filename}" | md5sum -c -

    echo "Extracting ${filename} archive..."
    tar -xf "${filename}" -C "/data/server"

    echo "Removing ${filename} archive"
    rm "${filename}"

    mkdir -p "/data/server/.versions"
    echo "${md5}" >"/data/server/.versions/${filename}.txt"
}

# Install base server 436
download_install \
    "https://drive.google.com/uc?export=download&id=1gpkEc4_6dKvqHSFC5zZ4DyvuEGmxkLhD" \
    e7a9c99748a11b6f94f2ab136adb1d74 \
    ut99server_436_base

# Install OldUnreal UTPatch 469c
download_install \
    "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469c/OldUnreal-UTPatch469c-Linux-amd64.tar.bz2" \
    6cd032e70460b1393d9514ffe81dcb1a \
    oldunreal_utpatch
