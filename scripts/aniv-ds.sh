#!/bin/bash
set -e

# Variables
MAP="nightmare"
PASSWORD=""

# Constants
INSTALL_DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"
APP_ID="2832030"
SERVER_EXECUTABLE="aniv_server.x86_64"
LOGS_DIR="$INSTALL_DIR/logs"
SERVER_LOG="$LOGS_DIR/server.log"
DB_PATH="$HOME/.config/unity3d/Vellocet/ANEURISM IV/aniv.db"
OPS_CFG="$HOME/.config/unity3d/Vellocet/ANEURISM IV/ops.cfg"
DATE_FORMAT="+%Y-%m-%d %H:%M:%S"

# Function to start the server
start_server() {
    echo "[$(date "$DATE_FORMAT")] Checking if the server is already running..."
    if pgrep -f "$SERVER_EXECUTABLE" > /dev/null; then
        echo "[$(date "$DATE_FORMAT")] Server is already running."
        return 1
    fi

    echo "[$(date "$DATE_FORMAT")] Starting the server..."

    # Ensure the logs directory exists
    mkdir -p "$LOGS_DIR"

    # Move old logs if they exist
    if [ -f "$SERVER_LOG" ]; then
        echo "[$(date "$DATE_FORMAT")] Archiving old logs..."
        mv "$SERVER_LOG" "$LOGS_DIR/server_$(date "+%Y-%m-%d_%H-%M-%S").log"
    fi

    chmod +x "$SERVER_EXECUTABLE"

    # Add more debug information
    echo "[$(date "$DATE_FORMAT")] Starting \"$SERVER_EXECUTABLE\""

    if [ -z "$PASSWORD" ]; then
        nohup ./"$SERVER_EXECUTABLE" -map $MAP -timestamps > "$SERVER_LOG" 2>&1 &
    else
        nohup ./"$SERVER_EXECUTABLE" -map $MAP -password $PASSWORD -timestamps > "$SERVER_LOG" 2>&1 &
    fi

    sleep 2  # Give it some time to start

    if pgrep -f "./$SERVER_EXECUTABLE" > /dev/null; then
        echo "[$(date "$DATE_FORMAT")] Server started successfully."
    else
        echo "[$(date "$DATE_FORMAT")] Failed to start the server. Check the log for details: $SERVER_LOG"
    fi
}

# Function to stop the server
stop_server() {
    echo "[$(date "$DATE_FORMAT")] Checking if the server is running..."
    if ! pgrep -f "$SERVER_EXECUTABLE" > /dev/null; then
        echo "[$(date "$DATE_FORMAT")] No running server instance found."
        return 1
    fi

    echo "[$(date "$DATE_FORMAT")] Stopping the server..."
    pkill -f "$SERVER_EXECUTABLE"
    if [ $? -eq 0 ]; then
        echo "[$(date "$DATE_FORMAT")] Server stopped successfully."
    else
        echo "[$(date "$DATE_FORMAT")] Failed to stop the server."
        return 1
    fi
}

# Function to delete the database
delete_database() {
    echo "[$(date "$DATE_FORMAT")] Deleting the database..."
    rm -f "$DB_PATH"
    echo "[$(date "$DATE_FORMAT")] Database deleted."
}

# Function to add an op
add_op() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 add_op <op_name>"
        return 1
    fi
    echo "[$(date "$DATE_FORMAT")] Adding op: $1..."
    echo "$1" >> "$OPS_CFG"
    echo "[$(date "$DATE_FORMAT")] Op added."
}

# Function to remove an op
remove_op() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 remove_op <op_name>"
        return 1
    fi
    echo "[$(date "$DATE_FORMAT")] Removing op: $1..."
    sed -i "/^$1$/d" "$OPS_CFG"
    echo "[$(date "$DATE_FORMAT")] Op removed."
}

# Function to restart the server
restart_server() {
    stop_server
    sleep 2
    if [ $? -eq 0 ]; then
        start_server
    else
        echo "[$(date "$DATE_FORMAT")] Server restart failed."
        return 1
    fi
}

# Function to validate the server
validate_server() {
        echo "[$(date "$DATE_FORMAT")] Validating server with username: anonymous..."

    # Run the SteamCMD validation command
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "$INSTALL_DIR" +login "anonymous" +app_update "$APP_ID" validate +quit

    if [ $? -eq 0 ]; then
        echo "[$(date "$DATE_FORMAT")] Server validated successfully."
    else
        echo "[$(date "$DATE_FORMAT")] Server validation failed."
        return 1
    fi
}

# Main script logic
case "$1" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    restart)
        restart_server
        ;;
    delete_db)
        delete_database
        ;;
    add_op)
        add_op "$2"
        ;;
    remove_op)
        remove_op "$2"
        ;;
    validate)
        validate_server
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|delete_db|add_op|remove_op|validate}"
        exit 1
        ;;
esac
