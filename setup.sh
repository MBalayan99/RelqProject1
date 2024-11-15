#!/bin/bash

NEW_USER="newuser"

# Step 2: Create the new user without a password
sudo adduser --disabled-password --gecos "" $NEW_USER

# Step 3: Add the new user to the sudo group to grant administrative privileges
sudo usermod -aG sudo $NEW_USER

# Step 4: Set up SSH key-based authentication for the new user
# Create the .ssh directory for the new user
sudo mkdir -p /home/$NEW_USER/.ssh

# Copy your local SSH public key to the new user's authorized_keys file
sudo cp ~/.ssh/authorized_keys /home/$NEW_USER/.ssh/authorized_keys

# Set the appropriate ownership and permissions
sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
sudo chmod 700 /home/$NEW_USER/.ssh
sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys

# Step 5: Disable password authentication for SSH
echo "Disabling password authentication for SSH..."

# Backup the original SSH configuration file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify the SSH configuration to disable password authentication and enable pubkey authentication
sudo sed -i 's/^#?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Restart the SSH service to apply changes
sudo systemctl restart sshd

# Step 6: Confirm that the settings have been applied
echo "Verifying SSH configuration..."
if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config && grep -q "^PubkeyAuthentication yes" /etc/ssh/sshd_config; then
  echo "Password authentication is disabled and pubkey authentication is enabled."
else
  echo "There was an issue with modifying the SSH configuration."
fi

echo "Setup complete for user '$NEW_USER'. SSH key access is enabled, and password authentication is disabled."

# Step 3: Install and configure UFW to allow only ports 21, 22, and 80
sudo apt update && sudo apt install -y ufw apache2 fail2ban

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 21/tcp
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw --force enable

# Step 4: Configure Fail2Ban for SSH brute-force protection
sudo bash -c 'cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 900
findtime = 900
EOF'

sudo systemctl restart fail2ban

# Step 5: Start and enable Apache2 web server
sudo systemctl start apache2
sudo systemctl enable apache2

echo "Setup complete. Apache2, UFW, and Fail2Ban are configured."
