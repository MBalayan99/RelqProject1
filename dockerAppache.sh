#!/bin/bash

# Step 1: Update the system and install Docker and Apache
echo "Updating system and installing Docker and Apache..."
sudo apt update -y
sudo apt install -y docker.io apache2

# Step 2: Enable Apache proxy modules
echo "Enabling Apache proxy modules..."
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite

# Step 3: Run Nginx in Docker container
echo "Pulling and running Nginx Docker container..."
sudo docker pull nginx
sudo docker run -d --name nginx-container -p 8080:80 nginx

# Step 4: Create Apache Reverse Proxy Configuration
echo "Creating Apache reverse proxy configuration..."

# Create a new configuration file for reverse proxy
sudo bash -c 'cat <<EOL > /etc/apache2/sites-available/reverse-proxy.conf
<VirtualHost *:80>
    ServerName yourdomain.com

    # Set up reverse proxy
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    # Optional: Enable logging for proxy traffic
    LogLevel warn
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL'

# Step 5: Enable the new site and restart Apache
echo "Enabling new site configuration and restarting Apache..."
sudo a2ensite reverse-proxy.conf
sudo systemctl restart apache2

# Final message
echo "Apache is now configured as a reverse proxy for Docker container running Nginx."

