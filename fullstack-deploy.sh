#!/bin/bash

# === CHECK FOR ARGUMENT ===
if [ -z "$1" ]; then
  echo "Usage: ./run-node-deploy.sh <app-name>"
  exit 1
fi

# === CONFIGURATION ===
APP_NAME="$1"
SOURCE_DIR="$HOME/dev/$APP_NAME"
DEPLOY_DIR="$HOME/apps/$APP_NAME"
START_COMMAND="node index.js"  # Or use: "npm start"
PORT=3000

# === INSTALL DEPENDENCIES ===
echo "Installing dependencies for $APP_NAME..."
cd "$SOURCE_DIR"
npm install

# === BUILD PROJECT (OPTIONAL) ===
if [ -f package.json ] && grep -q "\"build\":" package.json; then
  echo "Building $APP_NAME..."
  npm run build || { echo "Build failed"; exit 1; }
fi

# === PREPARE DEPLOY FOLDER ===
mkdir -p "$DEPLOY_DIR"
echo "Copying project to $DEPLOY_DIR..."
rsync -av --delete "$SOURCE_DIR"/ "$DEPLOY_DIR"/ --exclude=node_modules

# === RESTART APPLICATION ===
echo "Restarting $APP_NAME on port $PORT..."
pkill -f "$APP_NAME" || true
cd "$DEPLOY_DIR"
nohup $START_COMMAND > "$APP_NAME.log" 2>&1 &

echo "$APP_NAME is running with $START_COMMAND (log: $APP_NAME.log)"