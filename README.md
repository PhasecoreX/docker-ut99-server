# Unreal Tournament 99 Server
UT99 Server, packaged nicely in a container

[![Docker Pulls](https://img.shields.io/docker/pulls/phasecorex/ut99-server)](https://hub.docker.com/r/phasecorex/ut99-server)
[![Build Status](https://github.com/PhasecoreX/docker-ut99-server/workflows/build/badge.svg)](https://github.com/PhasecoreX/docker-ut99-server/actions?query=workflow%3Abuild)
[![BuyMeACoffee](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-orange)](https://buymeacoff.ee/phasecorex)
[![PayPal](https://img.shields.io/badge/paypal-donate-blue)](https://paypal.me/pcx)

## Some Notes
This image contains no server data. Instead, it downloads all the data it needs:
 - UT99 Server 436
 - All four official bonus packs
 - Latest OldUnreal Patch (469d at the time of writing)
 - File casing fixes for Linux (Botpack, De, and MultiMesh)

It downloads them on first launch, keeping the image size down and allowing for it to be updated without redownloading all of the unchanging UT99 server files. If there is an update to the contents of the server, there is an updater system in place. Additionally, this updater will not overwrite any .ini files, as they are stored elsewhere.

This image supports standard 64 bit AMD/Intel machines, as well as 64 bit ARM based devices (Raspberry Pi 3 and later, for example).

Looking for a UT2004 Server? [Check out my container for that!](https://github.com/PhasecoreX/docker-ut2004-server)

## How To Run
This is the base command:
```
docker run -v /path/to/data:/data -p 7777:7777/udp -e PUID=1000 phasecorex/ut99-server
```
- `-v /path/to/data:/data`: The path to a data directory. The entire server and all data will be downloaded here. This NEEDS to have a volume mounted to it for the container to start.
- `-p 7777:7777/udp`: Port for the game server to listen on. You need this for game clients to connect to the server.
- `-e PUID=1000`: The user ID you want this server to run as.
- `-e PGID=1000`: You can also specify a group ID. If not specified, it defaults to whatever PUID is set to.
- `-e TZ=America/Detroit`: You can specify the timezone that you want the server to run in. Useful for logging.

## Folder Layout
The `/data` folder will have two main folders:
- `server`: The base server files that were downloaded. If you can help it, don't modify anything in here.
- `addons`: Same layout as the `server` folder. You can add all of your custom maps and mutators here. Your config files will also be moved here.

## Addons
Simply extract your custom maps and mutators to the `/data/addons` folder (it has the same layout as the server folder structure) and then restart your server. All of your addons will then be present in the server. This keeps your addons and the core server maps nice and separate. Additionally, your configuration ini files will be in here.

## Ports
Here are the ports you can expose on the Docker image:
- 7777:7777/udp  (Game Port)
- 7778:7778/udp  (Query Port; game port + 1)
- 7779:7779/udp  (Query Port; game port + 2)
- 7780:7780/udp  (GameSpy Query Port; game port + 3)
- 7781:7781/udp  (GameSpy Query Port; game port + 4)
- 8777:8777/udp  (LAN Query Port; game port + 1000)

The right number is the port (and protocol) defined in your `UnrealTournament.ini` file, and the left is what it is exposed as outside of Docker. You will want to have the `/udp` part included on those ports, otherwise no clients will be able to connect to your server! At minimum you will need the game port defined, and if you want other clients to query information from your server, you'd want the query ports defined.

For UT99, there is only the `Port=7777` configuration option in the `UnrealTournament.ini` file. If you change it, you will have to recalculate the other ports to open based on it and what is listed above.

## Other Environment Variables
- `MAP_NAME` (default is "DM-Agony") - This is the initial map that will be loaded.
- `GAME_TYPE` (default is "Botpack.DeathMatchPlus") - This is the initial gametype that will be loaded.
- `MUTATORS` (default is empty) - Any mutators you want to load should be listed here, separated by comma (no spaces). For example: "MapVoteLA13.BDBMapVote,WhoPushedMe.WhoPushedMe".
- `SERVER_START_EXTRAS` (default is empty) - If you need to add any other parameters to the server launch command, put them in this variable. This must start with a question mark ("?"), as it will be appended to the end of the mutators list in the built server start command.
- `SERVER_START_COMMAND` (default is empty) - If you don't want to use the above 4 environment variables to specify map/gametype/mutators/extras, you can just specify the entire server start command here. All of the above 4 environment variables will be ignored.
- `COMPRESS_DIR` (default is empty) - If you want to compress all of your server files to set up a redirect download server, set this environment variable to a directory (such as `/compressed`). Then, have a volume mount to that directory to access the compressed files. Any file not found in that folder will be compressed there.
- `SKIP_INSTALL` (default is empty) - If you don't want to download/update your server files, set this to `true`. I assume you know what you're doing. Maybe manually installing your own server to the `/data/server` folder or something? I don't know.

## A Note On Downloading the Server
All of the official server downloads hosted in various locations all had issues, such as incorrect filename casing (leading to duplicated non-patched files on Linux) or archives extracting incorrectly. I have taken the time to compile the server, all bonus packs, and the latest patches and made a nice compressed archive. However, I can't host a ~160MB file myself, due to residential bandwith caps and upload speeds. If for some reason my chosen host does not work (link is too popular), let me know and I will update the installer.

## A Note On Unraid (or Other FUSE Filesystems)
UT99 Server does NOT work with FUSE filesystems. This is the filesystem that Unraid uses for it's `/mnt/user/` folder in order to merge all of your disks into one large folder. Not sure why it doesn't work, [I just know it doesn't](https://github.com/PhasecoreX/docker-ut2004-server/issues/5). For best results, just point the `/data` volume somewhere in `/mnt/cache/appdata` or `/mnt/diskX/appdata`, since those are pointed directly at a disk instead of a FUSE filesystem.
