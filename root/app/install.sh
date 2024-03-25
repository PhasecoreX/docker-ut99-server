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
    curl -#SL -o "${download_path}" "${url}"

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
    "https://drive.usercontent.google.com/download?id=1cIXhXQ-VFKSFQLOw1DkYAB1xPJaDqjaW&export=download&confirm=t" \
    7c24dfbc4e6fc68a272f3817590d3857 \
    ut99server_436_base

# Install OldUnreal UTPatch 469d
if [ "$(uname -m)" = "aarch64" ]; then
    # arm64
    download_install \
        "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469d/OldUnreal-UTPatch469d-Linux-arm64.tar.bz2" \
        cb2ca9b47e74d9255ec659b2f3a5d213 \
        oldunreal_utpatch
else
    # amd64
    download_install \
        "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469d/OldUnreal-UTPatch469d-Linux-amd64.tar.bz2" \
        d0e133165bf1630288583e52a40b90db \
        oldunreal_utpatch
fi
