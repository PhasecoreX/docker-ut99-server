#!/usr/bin/env sh
set -euf

download_install() {
    set -e
    url=$1
    sha256=$2
    filename=$3

    download_path="${version_directory}/${filename}"

    # If the user knows what they're doing, skip all downloads
    if [ "${SKIP_INSTALL:-}" = "true" ]; then
        return
    fi

    # If this pack is up to date, skip downloading it
    if [ "${force_update}" = 0 ] && [ -f "${download_path}.txt" ] && [ "$(cat "${download_path}.txt")" = "${sha256}" ]; then
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

    echo "Verifying sha256 checksum ${sha256}"
    echo "${sha256} ${download_path}" | sha256sum -c -

    echo "Extracting ${filename} archive..."
    mkdir -p "${server_directory}"
    tar -xf "${download_path}" -C "${server_directory}"

    echo "Removing ${filename} archive"
    rm "${download_path}"

    mkdir -p "${version_directory}"
    echo "${sha256}" >"${download_path}.txt"
    base_pack_installed=1
}

server_directory="$1"
version_directory="${server_directory}/.versions"

force_update=0
base_pack_installed=0

if [ -f "${version_directory}/ut99server_436_base.txt" ];
then
    base_server_hash=$(cat "${version_directory}/ut99server_436_base.txt")

    # Update old MD5 hashes to new SHA256 hash (still same files)
    if [ "${base_server_hash}" = "7c24dfbc4e6fc68a272f3817590d3857" ] || [ "${base_server_hash}" = "c4da91899a56b699fe356563aa8be22b" ];
    then
        echo "f0c16965ed0b2702a9921768f545bc828576dce34d28b0c56cea5d9d94026930" >"${version_directory}/ut99server_436_base.txt"
    fi
fi

# Install base server 436
download_install \
    "https://drive.usercontent.google.com/download?id=1yvOUOqZJ4N9ql6NmvW18IC9h6rzTPwaP&export=download&confirm=t" \
    f0c16965ed0b2702a9921768f545bc828576dce34d28b0c56cea5d9d94026930 \
    ut99server_436_base

# Install OldUnreal UTPatch 469e
if [ "$(uname -m)" = "aarch64" ]; then
    # arm64
    download_install \
        "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469e/OldUnreal-UTPatch469e-Linux-arm64.tar.bz2" \
        4c3978073b12b049c3ffdeb4d275cfc7a2313650f3eb5b94db06fbfee77c3e3b \
        oldunreal_utpatch
else
    # amd64
    download_install \
        "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469e/OldUnreal-UTPatch469e-Linux-amd64.tar.bz2" \
        08c806aa3721b1970045aa158ad90051329d982e8a9a3661153900e9ccbf6b0c \
        oldunreal_utpatch
fi
