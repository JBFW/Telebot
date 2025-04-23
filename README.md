# Telebot

A set of simple scripts for interacting with a Telegram bot.

## Scripts

- **`tlg-send`**  
  Reads text from `STDIN` and sends it as a message to a user via the Telegram bot.

- **`tlg-send-photo`**  
  Sends an image file to a user.

- **`tlg-send-video`**  
  Sends a video file to a user.

- **`get-tlg.sh`**  
  Requests new messages from users. Messages are saved to the file system.  
  Can be used in conjunction with `crontab`.

- **`check_new_info.sh`**  
  Checks for new, unsorted messages received by `get-tlg.sh`.

## Usage

Each script is designed for command-line use and can be integrated into larger automation workflows.  
Ensure your Telegram bot token and chat ID are properly configured in the environment or scripts.

---


