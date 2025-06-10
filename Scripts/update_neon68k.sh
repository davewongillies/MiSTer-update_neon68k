#!/bin/bash

ARCHIVE_ID="neon68k"
DEST_DIR="/media/fat"
TMP_DIR="/tmp/neon68k"
ARCHIVE_METADATA="${TMP_DIR}/metadata.json"
CONFIG_DIR="${DEST_DIR}/Scripts/.config/neon68k"
LASTRUN_FILE="${CONFIG_DIR}/lastrun.txt"
SCRIPT_INI="${DEST_DIR}/Scripts/update_neon68k.ini"

[[ -e "${DEST_DIR}" ]]   || mkdir -p "$DEST_DIR"
[[ -e "${TMP_DIR}" ]]    || mkdir -p "$TMP_DIR"
[[ -e "${CONFIG_DIR}" ]] || mkdir -p "${CONFIG_DIR}"

[[ -f "${SCRIPT_INI}" ]] && source "${SCRIPT_INI}"

# Function to get values from an ini file
ini_get() {
  if [ -f ${SCRIPT_INI} ]; then
    grep -E "^${1}=.*$" ${SCRIPT_INI} | cut -d= -f2 ; true
  fi
}

# Function to set values to an ini file
ini_set() {
  ! [ -f ${SCRIPT_INI} ] && touch ${SCRIPT_INI}

  val="$(ini_get ${1} ${2})"

  if [[ -z "${val}" ]]; then
    echo "${1}=${2}" >> ${SCRIPT_INI}
  else
    sed -i -e "s!${1}=.*!${1}=${2}!g" ${SCRIPT_INI}
  fi

  source ${SCRIPT_INI}
}


# Function to URL-encode file paths
url_encode() {
    local str="$1"
    local encoded=""
    local pos c o

    for (( pos=0 ; pos<${#str} ; pos++ )); do
        c=${str:$pos:1}
        case "$c" in
            [a-zA-Z0-9.~_-])
              o="$c" ;;
            *)
              printf -v o '%%%02X' "'$c"
        esac
        encoded+="$o"
    done
    echo "$encoded"
}

# Parse file list from archive.org metadata
parse_file_list() {
    all_files=$(jq -r '.files[].name | match(".*\\.zip$") | .string' < $ARCHIVE_METADATA)

    if [ -z "$all_files" ]; then
        echo "No zip files found."
        return 1
    fi

    echo "$all_files"
    return 0
}

# Download and extract matching files
sync_files() {
    echo "Fetching archive metadata..."
    wget -qO${ARCHIVE_METADATA} "https://archive.org/metadata/$ARCHIVE_ID?output=json"

    echo "Starting sync..."
    echo "Fetching file list..."
    file_list=$(parse_file_list) || exit 1

    if [ "$full_download" -eq 0 ]; then
        last_run=$(cat "$LASTRUN_FILE" 2>/dev/null || echo 0)
        echo "Performing incremental sync since: $(date -d @${last_run})"
    fi

    while IFS= read -r file; do
        [ -z "$file" ] && continue

        if [ "$full_download" -eq 0 ]; then
            mod_time=$(jq --arg file "${file}" -r '.files[] | select(.name==$file) | .mtime' < $ARCHIVE_METADATA)
            if [[ -n "$mod_time" && "$mod_time" -le "$last_run" ]]; then
                echo "Skipping (not newer): $file"
                continue
            fi
        fi

        echo Downloading "${file}"...
        wget -q --show-progress \
          -O "$TMP_DIR/tmp.zip" \
          "https://archive.org/download/$ARCHIVE_ID/$(url_encode "$file")"

        if [ $? -ne 0 ] || [ ! -f "$TMP_DIR/tmp.zip" ]; then
            echo "Download failed: $file"
            continue
        fi

        unzip -q -o "$TMP_DIR/tmp.zip" -d "$TMP_DIR"

        for dir in "_Computer" "config" "games"; do
            if [ -d "$TMP_DIR/$dir" ]; then
                echo "Copying $dir to $DEST_DIR"
                cp -r "$TMP_DIR/$dir" "$DEST_DIR"
            fi
        done

        rm -f "$TMP_DIR/tmp.zip"
        rm -rf "$TMP_DIR/_Computer" "$TMP_DIR/config" "$TMP_DIR/games"

    done <<< "$file_list"

    date +%s > "$LASTRUN_FILE"
    rm -f ${ARCHIVE_METADATA}
}

main_dialog() {
  if [ -f ${LASTRUN_FILE} ]; then
    full_download=0
  else
    full_download=1
  fi

  if [[ -z "$(ini_get scaler)" ]]; then
    # Show dialog prompt for scaler type
    dialog \
      --clear \
      --title "Select Scaler Type" \
      --menu "Choose your display scaler:" 10 50 2 \
        1 "External 4K Upscaler" \
        2 "MiSTer Upscaler" \
      2> "$TMP_DIR/scaler_choice.txt"

    ini_set scaler "$(cat "$TMP_DIR/scaler_choice.txt" 2>/dev/null)"
    rm -f "$TMP_DIR/scaler_choice.txt"
  fi

  # Determine scaler path
  if [ "$(ini_get scaler)" == "1" ]; then
      scaler_dir="External 4K Upscaler"
  else
      scaler_dir="MiSTer Upscaler"
  fi
}

main_dialog
sync_files
echo "Sync complete."
echo "Done."
