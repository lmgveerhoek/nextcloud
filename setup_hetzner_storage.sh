#!/bin/bash

# Prompt for Hetzner Storage Box details
read -p "Enter your Hetzner Storage Box username: " username
read -p "Enter your Hetzner Storage Box address: " storage_box_address
read -p "Enter the local mount point (e.g., /mnt/hetzner_storage): " mount_point

# Ensure SSH key exists
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
fi

# Upload SSH key
echo "Uploading SSH key..."
ssh-copy-id -p 23 -s "$username@$storage_box_address"

if [ $? -ne 0 ]; then
    echo "Falling back to manual key upload..."
    ssh -p 23 "$username@$storage_box_address" mkdir .ssh
    scp -P 23 ~/.ssh/id_rsa.pub "$username@$storage_box_address:.ssh/authorized_keys"
fi

# Test connection
echo "Testing SSH connection..."
if sftp -P 23 "$username@$storage_box_address" <<< "quit" > /dev/null 2>&1; then
    echo "SSH key setup successful!"
else
    echo "SSH key setup failed. Please check your credentials and try again."
    exit 1
fi

# Ensure the mount point exists
sudo mkdir -p "$mount_point"

# Mount using SSHFS
echo "Mounting the Storage Box..."
if sudo sshfs -p 23 -o allow_other,IdentityFile=~/.ssh/id_rsa "$username@$storage_box_address:/home" "$mount_point"; then
    echo "Storage Box mounted successfully at $mount_point"
else
    echo "Failed to mount the Storage Box. Please check your settings and try again."
    exit 1
fi

# Verify the mount
if mount | grep "$mount_point"; then
    echo "Mount verified. Your Hetzner Storage Box is ready to use."
else
    echo "Mount verification failed. Please check the mount manually."
fi
