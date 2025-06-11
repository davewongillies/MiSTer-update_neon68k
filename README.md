# Neon68K Updater Script

## Overview

A script for keeping your [Neon68K](https://neon68k.com/) collection update to
date on your MiSTer.

## Installation

1. Add the following to `/media/fat/downloader.ini` on your MiSTer

```ini
[update_neon68k]
db_url = https://raw.githubusercontent.com/Neon68K/Automatic-Updater-Script/db/db.json.zip
```

2. Run `update_all` from the `Scripts` menu to install

## Usage

1. Goto the Scripts menu on your MiSTer and run the `update_neon68k` script
2. The first time the script is run choose your scaler preference:
   - Do you have a **4K Scaler** or the **MiSTer Scaler**?
       - If you have a [Retrotink 4K](https://consolemods.org/wiki/AV:RetroTINK-4K)
         or a [Morph4K](https://junkerhq.net/xrgb/index.php?title=Morph_4k),
         you'll want to select the **4K Scaler** option.
       - If not, select **MiSTer Scaler**.
   - The script will use that information and will download all the games in the
     archive the first time it is run.
   - On subsequent runs it will download anything that has been added from the
     last time it was run.
   - Optionally when running `update_neon68k` you have the option to run the following
     options when it first starts:
     - `*Press <UP>`,    To select scaler option.
     - `*Press <LEFT>`,  To exit.
     - `*Press <RIGHT>`, To force a full download.
     - `*Press <DOWN>`,  To check for updates.

   After that, all you need to do is sit back, relax, and enjoy.

## Configuration

### `GAMES_PATH`

`GAMES_PATH`: by default `update_neon68k` searches the following paths in order
to find your `games` directory; `/media/usb0`, `/media/usb1`, `/media/usb2`,
`/media/usb3`, `/media/usb4`, `/media/usb5`, `/media/fat/cifs`, `/media/fat`.

This can be overridden by setting the variable `GAMES_PATH` in `/media/fat/Scripts/update_neon68k.ini`
eg:

```ini
GAMES_PATH=/media/fat/nfs
```

**NOTE** If your `GAMES_PATH` changes run `update_neon68k` and press `<RIGHT>`
to force a full download to download the games to your new `GAMES_PATH`.

### `scaler`

Set the scaler type. The variable `scaler` should be set to in integer:

- `1`: "External 4K Upscaler"
- `2`: "MiSTer Upscaler"

Example `update_neon68k.ini`:

```ini
scaler=1
```
