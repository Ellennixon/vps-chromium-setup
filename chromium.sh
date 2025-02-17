#!/bin/bash

# Define color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RESET='\033[0m'

# Display "EllEN" Logo
echo -e "${CYAN}=============================="
echo -e "  ${GREEN}  ███████╗██╗     ██╗     ███████╗███╗   ██╗  "
echo -e "  ${GREEN}  ██╔════╝██║     ██║     ██╔════╝████╗  ██║  "
echo -e "  ${GREEN}  █████╗  ██║     ██║     █████╗  ██╔██╗ ██║  "
echo -e "  ${GREEN}  ██╔══╝  ██║     ██║     ██╔══╝  ██║╚██╗██║  "
echo -e "  ${GREEN}  ███████╗███████╗███████╗███████╗██║ ╚████║  "
echo -e "  ${GREEN}  ╚══════╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝  "
echo -e "${CYAN}==============================${RESET}"

# Follow on Twitter check
read -p "Follow https://x.com/web3brothers? (yes/no): " followed
[[ "$followed" != "yes" ]] && { echo "Please follow and rerun."; exit 1; }

# Install Docker & Dependencies
echo "Installing Docker & prerequisites..."
sudo apt update && sudo apt install -y curl ca-certificates docker.io docker-compose

# User Input for Number of Chromium Containers
read -p "Enter the number of Chromium containers you want to create: " container_count
read -p "Enter CUSTOM_USER: " custom_user
read -s -p "Enter PASSWORD: " password; echo ""

# Setup Chromium Containers
mkdir -p ~/chromium && cd ~/chromium
echo "version: \"3.8\"" > docker-compose.yml
echo "services:" >> docker-compose.yml

# Generate Containers Based on User Input
for ((i=1; i<=container_count; i++)); do
  port=$((3049 + i))  # Start from 3050, 3051, ...
  echo "  chromium$i:
    image: lscr.io/linuxserver/chromium:latest
    container_name: chromium_browser$i
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin
      - CUSTOM_USER=${custom_user}
      - PASSWORD=${password}
    ports:
      - \"$port:3000\"
    security_opt:
      - seccomp:unconfined
    volumes:
      - ~/chromium/config$i:/config
    shm_size: \"1gb\"
    restart: unless-stopped
  " >> docker-compose.yml
done

# Start Chromium Containers
echo "Starting $container_count Chromium instances..."
docker-compose up -d

echo "✅ Chromium is running at: "
for ((i=1; i<=container_count; i++)); do
  echo "🔹 http://<IP>:$((3049 + i))"
done
