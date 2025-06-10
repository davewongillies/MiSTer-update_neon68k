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

   After that, all you need to do is sit back, relax, and enjoy.
