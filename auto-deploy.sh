#!/bin/bash

# === CHECK FOR ARGUMENT ===
if [ -z "$1" ]; then
  echo "Usage: ./run-local-deploy.sh <app-name>"
  exit 1
fi

# === CONFIGURATION ===
APP_NAME="$1"
SOURCE_DIR="$HOME/dev/$APP_NAME"
BUILD_DIR="$SOURCE_DIR/dist"         # Change if needed (e.g., 'build', 'out')
DEPLOY_DIR="$HOME/apps/$APP_NAME"
PORT=3000

# === INSTALL DEPENDENCIES ===
echo "Installing dependencies for $APP_NAME..."
cd "$SOURCE_DIR"
npm install

# === BUILD PROJECT ===
echo "Building $APP_NAME..."
npm run build || { echo "Build failed"; exit 1; }

# === PREPARE DEPLOY FOLDER ===
mkdir -p "$DEPLOY_DIR"
echo "Copying build to $DEPLOY_DIR..."
rsync -av --delete "$BUILD_DIR"/ "$DEPLOY_DIR"/

# === RESTART APPLICATION ===
echo "Restarting $APP_NAME on port $PORT..."
pkill -f "$APP_NAME" || true
cd "$DEPLOY_DIR"
nohup npx serve -s . -l "$PORT" > "$APP_NAME.log" 2>&1 &

echo "$APP_NAME is running at http://localhost:$PORT"