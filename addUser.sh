#!/bin/bash

# Step 1: Check if both username and password are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <password>"
  exit 1
fi

# Step 2: Define the username and password from the arguments
NEW_USER="$1"
USER_PASSWORD="$2"

# Step 3: Create the new user
sudo adduser --disabled-password --gecos "" $NEW_USER

# Step 4: Set the user's password
echo "$NEW_USER:$USER_PASSWORD" | sudo chpasswd

# Step 5: Add the new user to the sudo group to grant administrative privileges
sudo usermod -aG sudo $NEW_USER

# Step 6: Set up SSH key-based authentication for the new user
# Create the .ssh directory for the new user
sudo mkdir -p /home/$NEW_USER/.ssh

# Copy your local SSH public key to the new user's authorized_keys file
if [ ! -f ~/.ssh/authorized_keys ]; then
  echo "Error: No local SSH public key found at ~/.ssh/authorized_keys. Please ensure you have an SSH key set up."
  exit 1
fi
sudo cp ~/.ssh/authorized_keys /home/$NEW_USER/.ssh/authorized_keys

# Set the appropriate ownership and permissions
sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
sudo chmod 700 /home/$NEW_USER/.ssh
sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys

# Step 7: Disable password authentication for SSH
echo "Disabling password authentication for SSH..."

# Backup the original SSH configuration file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify the SSH configuration to disable password authentication and enable pubkey authentication
sudo sed -i 's/^#?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Restart the SSH service to apply changes
sudo systemctl restart sshd

# Step 8: Confirm that the settings have been applied
echo "Verifying SSH configuration..."
if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config && grep -q "^PubkeyAuthentication yes" /etc/ssh/sshd_config; then
  echo "Password authentication is disabled and pubkey authentication is enabled."
else
  echo "There was an issue with modifying the SSH configuration."
fi

echo "Setup complete for user '$NEW_USER'. SSH key access is enabled, and password authentication is disabled."
