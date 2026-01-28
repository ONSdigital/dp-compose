#!/usr/bin/env bash

echo "Seeding permissions API database..."
if [ -z "$DP_REPO_DIR" ]; then
    DP_REPO_DIR="../../../.."
fi

PERMISSIONS_API_REPO_PATH="$DP_REPO_DIR/dp-permissions-api"

while [ ! -d "$PERMISSIONS_API_REPO_PATH" ]; do
    echo "dp-permissions-api not found at $PERMISSIONS_API_REPO_PATH"
    read -r -p "Path to dp-permissions-api: " custom_path
    PERMISSIONS_API_REPO_PATH="$custom_path"
done

echo "Found dp-permissions-api at $PERMISSIONS_API_REPO_PATH"; \
cd "$PERMISSIONS_API_REPO_PATH/import-script" && go run import.go; \

