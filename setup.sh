#!/bin/bash

# Define file paths
BASE_DIR=$(realpath "$0" | pwd)
DATA_DIR="/var/lib/door-llm"
COMPOSE_FILE="$DATA_DIR/docker-compose.yaml"
ENV_FILE="$DATA_DIR/.env"
SOURCE_COMPOSE_FILE="$BASE_DIR/docker-compose.yaml"
SOURCE_ENV_FILE="$BASE_DIR/.env"
SERVICE_FILE="/etc/systemd/system/door-llm.service"

echo "Base directory: $BASE_DIR"
echo "Data directory: $DATA_DIR"

# Define user and group
DOOR_USER="door-llm"
DOOR_GROUP="door-llm"

COMPOSE_COMMAND="$1"

if [ -z "$COMPOSE_COMMAND" ]; then
    echo "Compose command not provided. Looking for available commands."
    # Determine the Docker Compose command
    if command -v docker >/dev/null 2>&1 && docker compose -v >/dev/null 2>&1; then
        COMPOSE_COMMAND="docker compose"
    elif command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_COMMAND="docker-compose"
    elif command -v podman >/dev/null 2>&1 && docker compose -v >/dev/null 2>&1; then
        COMPOSE_COMMAND="podman compose"
    elif command -v podman-compose >/dev/null 2>&1; then
        COMPOSE_COMMAND="podman-compose"
    else
        echo "Error: Neither docker-compose, podman-compose, docker, nor podman found." >&2
        exit 1
    fi
else
    echo "User provided compose command. Skipping."
fi

echo "Command $COMPOSE_COMMAND will be used to run docker compose commands."

SERVICE_DEPENDENCY=""
# Verify systemd service existence
if systemctl list-unit-files docker.service >/dev/null 2>&1 2>&1; then
    SERVICE_DEPENDENCY="docker.service"
elif systemctl list-unit-files podman.service >/dev/null 2>&1; then
    SERVICE_DEPENDENCY="podman.service"
else
    echo "Error: Neither docker.service nor podman.service is available in systemd." >&2
    echo "Please ensure one of these services is installed and active." >&2
    exit 1
fi
echo "Selected systemd service: $SERVICE_DEPENDENCY"

# Create group if it does not exist
if ! getent group "$DOOR_GROUP" > /dev/null 2>&1; then
    sudo groupadd "$DOOR_GROUP"
    echo "Group $DOOR_GROUP created."
else
    echo "Group $DOOR_GROUP already exists."
fi

# Create user if they do not exist
if ! id -u "$DOOR_USER" > /dev/null 2>&1; then
    sudo useradd -g "$DOOR_GROUP" --system "$DOOR_USER"
    sudo mkdir -p "/home/$DOOR_USER"
    sudo chown "$DOOR_USER" "/home/$DOOR_USER"
    sudo loginctl enable-linger "$DOOR_USER"
    echo "User $DOOR_USER created."
else
    echo "User $DOOR_USER already exists."
fi


# Create directory if it doesn't exist
sudo mkdir -p "$DATA_DIR"

# Copy files to target directory
if [ -f "$SOURCE_ENV_FILE" ]; then
  sudo cp "$SOURCE_ENV_FILE" "$ENV_FILE"
  echo "Found and copied existing .env file: $SOURCE_ENV_FILE"
else
  sudo touch "$ENV_FILE"
  echo "Existing .env file not found."
fi
sudo cp "$SOURCE_COMPOSE_FILE" "$COMPOSE_FILE"

# Set ownership
sudo chown -R "$DOOR_USER":"$DOOR_GROUP" "$DATA_DIR"

echo "Created data directory at $DATA_DIR. All files are copied."

# Create systemd service
sudo tee "$SERVICE_FILE" > /dev/null <<EOL
[Unit]
Description=DOOR local LLM setup: https://github.com/superdurszlak/DOOR
Before=umount.target
After=$SERVICE_DEPENDENCY
StartLimitIntervalSec=0
RequiresMountsFor=$DATA_DIR

[Service]
Type=simple
Restart=always
RestartSec=1
KillMode=mixed
TimeoutStopSec=15
User=$DOOR_USER
ExecStart=$COMPOSE_COMMAND -f $COMPOSE_FILE --env-file $ENV_FILE up
ExecStop=$COMPOSE_COMMAND -f $COMPOSE_FILE down

[Install]
WantedBy=multi-user.target
EOL

echo "Created service: $SERVICE_FILE"

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable door-llm
sudo systemctl start door-llm

echo "Installation complete. Service $SERVICE_FILE is enabled and running."
