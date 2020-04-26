# Counter-Strike 1.6 Dedicated Server

This image installs:
* HLDS (via SteamCMD)
* Metamod v1.21.1-am
* AMX Mod X v1.8.2 (with Counter-Strike Addon)

## Prerequisites

* Docker

## Running

Clone this repo:

```sh
git clone git@github.com:oevseev/cstrike-server.git
cd cstrike-server
```

Build the container:

```
docker build . -t cstrike-server
```

Run the container:

```
docker run -d --network host cstrike-server +map de_dust2
```

**Note that if you don't specify the default map, the server will crash on player connection!**
