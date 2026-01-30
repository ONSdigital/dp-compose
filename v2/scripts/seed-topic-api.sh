#!/usr/bin/env bash
echo "Seeding topic API database..."

if [ -z "$DP_REPO_DIR" ]; then
    DP_REPO_DIR="../../../.."
fi

TOPIC_API_REPO_PATH="$DP_REPO_DIR/dp-topic-api"

pwd

while [ ! -d "$TOPIC_API_REPO_PATH" ]; do
    echo "dp-topic-api not found at $TOPIC_API_REPO_PATH"
    read -r -p "Path to dp-topic-api: " custom_path
    TOPIC_API_REPO_PATH="$custom_path"
done

echo "Found dp-topic-api at $TOPIC_API_REPO_PATH"

cd "$TOPIC_API_REPO_PATH" && make database-seed

