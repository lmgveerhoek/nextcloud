#!/bin/bash

# Prompt for file details
read -p "Enter the path to the file in the mounted Hetzner Storage (e.g., /mnt/hetzner_storage/home/01 - Fit Test.mkv): " SOURCE_FILE
read -p "Enter the destination path (default: /tmp/copy_test.mkv): " DEST_FILE
DEST_FILE=${DEST_FILE:-"/tmp/copy_test.mkv"}

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file does not exist."
    exit 1
fi

echo "Starting copy speed test..."

# Perform the copy and time it
start_time=$(date +%s.%N)
cp "$SOURCE_FILE" "$DEST_FILE"
end_time=$(date +%s.%N)

# Check if the copy was successful
if [ $? -ne 0 ]; then
    echo "Copy failed. Please check your file paths and permissions."
    exit 1
fi

# Calculate time taken
time_taken=$(echo "$end_time - $start_time" | bc)

# Get the file size
FILE_SIZE=$(stat -c %s "$DEST_FILE")
SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1048576" | bc)

# Calculate the speed
SPEED_MBps=$(echo "scale=2; $SIZE_MB / $time_taken" | bc)

echo "Copy complete."
echo "File size: $SIZE_MB MB"
echo "Time taken: $time_taken seconds"
echo "Average copy speed: $SPEED_MBps MB/s"

# Ask if the user wants to keep the copied file
read -p "Do you want to keep the copied file? (y/n): " KEEP_FILE
if [[ $KEEP_FILE =~ ^[Nn]$ ]]; then
    rm "$DEST_FILE"
    echo "Copied file removed."
else
    echo "File kept at $DEST_FILE"
fi