#!/bin/sh

PATH=$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; export PATH

TOKEN='<== your bot API token ==>'
API_URL="https://api.telegram.org/bot$TOKEN"

SAVE_DIR="$HOME/NewInfo"
CONFIG_DIR="$HOME/.config/tlg_bot"
OFFSET_FILE="$CONFIG_DIR/seq"

# functions
send_reply() {
  local chat_id=$1
  local message=$2
  curl -s -X POST $API_URL/sendMessage -d chat_id=$chat_id -d text="$message"
}

get_file() {
  local file_id=$1
  local file_name=$2

  file_path=$(curl -s "$API_URL/getFile?file_id=$file_id" | jq -r '.result.file_path')
  file_url="https://api.telegram.org/file/bot$TOKEN/$file_path"

  curl -s "$file_url" -o "$SAVE_DIR/$file_name"
}

# begin

mkdir -p "$SAVE_DIR"
mkdir -p "$CONFIG_DIR"

# read offset
if [ -f "$OFFSET_FILE" ]; then
    OFFSET=$(cat "$OFFSET_FILE")
else
    OFFSET=0
fi

# get updates
response=$(curl -s "$API_URL/getUpdates?offset=$OFFSET&timeout=10")

echo "$response" | jq -c '.result[]' |\
  while read -r item; do
    update_id=$(echo "$item" | jq '.update_id')
    message=$(echo "$item" | jq '.message')

    # save offset
    new_offset=$((update_id + 1))
    echo "$new_offset" > "$OFFSET_FILE"

    message_id=$(echo "$message" | jq '.message_id')
    chat_id=$(echo "$message" | jq '.chat.id')
    date=$(echo "$message" | jq -r '.date')

    if echo "$message" | jq 'has("text")' | grep -q true; then
      text=$(echo "$message" | jq -r '.text')
      filename="$SAVE_DIR/message_${chat_id}_${date}.txt"
      echo "$text" > "$filename"
    fi

    if echo "$message" | jq 'has("document")' | grep -q true; then
      file_id=$(echo "$message" | jq -r '.document.file_id')
      file_name=$(echo "$message" | jq -r '.document.file_name')
      get_file "$file_id" "$file_name"
    fi

    if echo "$message" | jq 'has("video")' | grep -q true; then
      file_id=$(echo "$message" | jq -r '.video.file_id')
      file_name="video_${chat_id}_${message_id}.mp4"
      get_file "$file_id" "$file_name"
    fi

    if echo "$message" | jq 'has("voice")' | grep -q true; then
      file_id=$(echo "$message" | jq -r '.voice.file_id')
      file_name="voice_${chat_id}_${message_id}.ogg"
      get_file "$file_id" "$file_name"
    fi

    if echo "$message" | jq 'has("video_note")' | grep -q true; then
      file_id=$(echo "$message" | jq -r '.video_note.file_id')
      file_name="video_note_${chat_id}_${message_id}.mp4"
      get_file "$file_id" "$file_name"
    fi

    if echo "$message" | jq 'has("photo")' | grep -q true; then
      file_id=$(echo "$message" | jq -r '.photo[-1].file_id')
      file_name="photo_${chat_id}_${message_id}.jpg"
      get_file "$file_id" "$file_name"
    fi

    send_reply "$chat_id" "Copy"
  done

