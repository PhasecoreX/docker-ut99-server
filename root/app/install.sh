#!/usr/bin/env sh
set -euf

download_install() {
    set -e
    url=$1
    md5=$2
    filename=$3

    download_path="${version_directory}/${filename}"

    # If the user knows what they're doing, skip all downloads
    if [ "${SKIP_INSTALL:-}" = "true" ]; then
        return
    fi

    # If this pack is up to date, skip downloading it
    if [ "${force_update}" = 0 ] && [ -f "${download_path}.txt" ] && [ "$(cat "${download_path}.txt")" = "${md5}" ]; then
        base_pack_installed=1
        return
    fi

    # If we are updating this pack, all packs after it must also be updated
    force_update=1
    rm -f "${download_path}.txt"

    # If this is the first pack to be installed, delete the entire server folder
    if [ "${base_pack_installed}" = 0 ]; then
        rm -rf "${server_directory}"
    fi

    echo "Downloading ${filename} archive..."
    mkdir -p "${version_directory}"
    if [ -z "${url##*'google.com'*}" ]; then
        curl -#SL -c "${version_directory}/cookies.txt" "${url}" | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' >"${version_directory}/confirm.txt"
        curl -#SL -b "${version_directory}/cookies.txt" -o "${download_path}" "${url}&confirm=$(cat "${version_directory}/confirm.txt")"
        rm -f "${version_directory}/confirm.txt" "${version_directory}/cookies.txt"
    else
        curl -#SL "${url}" -o "${download_path}"
    fi

    echo "Verifying md5 checksum ${md5}"
    echo "${md5} ${download_path}" | md5sum -c -

    echo "Extracting ${filename} archive..."
    mkdir -p "${server_directory}"
    tar -xf "${download_path}" -C "${server_directory}"

    echo "Removing ${filename} archive"
    rm "${download_path}"

    mkdir -p "${version_directory}"
    echo "${md5}" >"${download_path}.txt"
    base_pack_installed=1
}

server_directory="$1"
version_directory="${server_directory}/.versions"

force_update=0
base_pack_installed=0

# Install base server 436
download_install \
    "https://drive.google.com/uc?export=download&id=1cIXhXQ-VFKSFQLOw1DkYAB1xPJaDqjaW" \
    7c24dfbc4e6fc68a272f3817590d3857 \
    ut99server_436_base

# Install OldUnreal UTPatch 469c
download_install \
    "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469c/OldUnreal-UTPatch469c-Linux-amd64.tar.bz2" \
    6cd032e70460b1393d9514ffe81dcb1a \
    oldunreal_utpatch
