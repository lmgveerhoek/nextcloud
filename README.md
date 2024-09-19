# Nextcloud + Hetzner Storage Box
To mount your Hetzner Storage Box on your Ubuntu server for use with Nextcloud, the best method is to use SSHFS (SSH Filesystem). This method is secure, relatively easy to set up, and works well with Docker. Here's how to do it:

We first need to set up SSH key authentication with your Hetzner Storage Box. A script can be used to automate this process. To use this script:

1. Make it executable: `chmod +x setup_hetzner_storage.sh`
2. Run it: `./setup_hetzner_storage.sh`

This script will:
1. Generate an SSH key if one doesn't exist.
2. Upload the SSH key to your Hetzner Storage Box.
3. Test the SSH connection.
4. Mount the Storage Box using SSHFS.
5. Verify the mount.

After running this script successfully, your Hetzner Storage Box should be mounted and ready to use with your Nextcloud Docker setup. You can then update your Docker Compose file to use this mount point for Nextcloud's data storage.

Remember to update your Nextcloud Docker Compose file to use the mount point you specified when running the script. For example, if you used `/mnt/hetzner_storage` as the mount point, your Nextcloud service in the Docker Compose file should include an ENV variable like this:

```yaml
 environment:
      NEXTCLOUD_DATADIR: /mnt/hetzner_storage/nextcloud 
```

This setup should provide a secure and efficient way to use your Hetzner Storage Box with Nextcloud.

1. First, install SSHFS on your Ubuntu server:

```bash
sudo apt update
sudo apt install sshfs
```

2. Create a mount point for your Hetzner Storage Box:

```bash
sudo mkdir /mnt/hetzner_storage
```

3. Mount the Hetzner Storage Box using SSHFS:

```bash
sudo sshfs -o allow_other,IdentityFile=/path/to/your/ssh/key username@your_storage_box.your-storagebox.de:/home /mnt/hetzner_storage
```

Replace `/path/to/your/ssh/key` with the path to your SSH key, `username` with your Hetzner Storage Box username, and `your_storage_box.your-storagebox.de` with your actual Storage Box address.

4. To make this mount persistent across reboots, you'll need to use a systemd service.

```ini
[Unit]
Description=Mount Hetzner Storage Box
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/sshfs -o allow_other,IdentityFile=/path/to/your/ssh/key username@your_storage_box.your-storagebox.de:/home /mnt/hetzner_storage
ExecStop=/bin/fusermount -u /mnt/hetzner_storage

[Install]
WantedBy=multi-user.target

```

5. Save this file as `/etc/systemd/system/hetzner-storage-mount.service`, replacing the ExecStart line with your actual SSHFS command from step 3.

6. Enable and start the service:

```bash
sudo systemctl enable hetzner-storage-mount.service
sudo systemctl start hetzner-storage-mount.service
```
