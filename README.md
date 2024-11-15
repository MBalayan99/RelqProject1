# RelqProject1
Building cloud based server for a startup
Project Documentation
Overview

This project sets up an EC2 instance on AWS with a security group, SSH configuration, user creation scripts, and installs a web server. The main purpose is to automate server setup, user management, security configurations, and web server deployment with Docker and Apache, leveraging a combination of Terraform and shell scripts.
Components

    Terraform Configuration (ec2.tf): Defines AWS resources such as EC2 instance, key pair, security group, and outputs.
    Shell Scripts:
        setup.sh: Automates server setup, including user creation, security configurations (UFW, Fail2Ban), and web server setup (Apache2).
        addUser.sh: Adds a new user with a password, sets up SSH keys for key-based authentication, and disables password authentication for SSH.
        dockerAppache.sh: Installs Docker and Apache, sets up a reverse proxy for an Nginx Docker container.

Prerequisites

    Terraform: Required to provision AWS resources.
    AWS Account: The project assumes you have an AWS account set up and access to the AWS Management Console.
    SSH Keys: An existing SSH key pair (id_rsa.pub) for secure SSH access.
    Shell Access: Basic knowledge of Linux shell scripting.

Steps to Set Up the Project
1. Set up Terraform

    Install Terraform from Terraform Official Website.
    Ensure that your AWS credentials are set in the environment variables, or configure the AWS CLI with aws configure.

2. Terraform Configuration (ec2.tf)

This configuration defines AWS resources using Terraform:

 provider "aws" {
  region = "us-west-2"  # Replace with your preferred AWS region
}

resource "aws_key_pair" "server_key" {
  key_name   = "server_key"
  public_key = file("~/.ssh/id_rsa.pub")  # Path to your SSH public key
}

resource "aws_security_group" "server_sg" {
  name        = "server-sg"
  description = "Allow SSH, HTTP, and FTP"

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-00aaee1e7c7b0ff78"  
  instance_type = "t2.micro"  

  key_name        = aws_key_pair.server_key.key_name
  security_groups = [aws_security_group.server_sg.name]

  # Load the setup script
  user_data = file("setup.sh")

  tags = {
    Name = "web-server"
  }
}

output "instance_ip" {
  value = aws_instance.web_server.public_ip
}


This script does the following:

    Defines an AWS provider and sets the region to us-west-2.
    Creates an EC2 instance with a security group allowing SSH, FTP, and HTTP access.
    Outputs the public IP of the EC2 instance.

3. Setup Script (setup.sh)

The setup.sh script configures the EC2 instance with:

    A new user with SSH key-based access.
    Disables password authentication for SSH.
    Installs necessary packages (UFW, Apache2, Fail2Ban).
    Configures UFW to allow only specific ports (21, 22, 80).
    Configures Fail2Ban to protect against SSH brute-force attacks.

Example usage:

#!/bin/bash

NEW_USER="newuser"

# Create the new user without a password
sudo adduser --disabled-password --gecos "" $NEW_USER

# Add the new user to the sudo group
sudo usermod -aG sudo $NEW_USER

# Set up SSH key-based authentication
sudo mkdir -p /home/$NEW_USER/.ssh
sudo cp ~/.ssh/authorized_keys /home/$NEW_USER/.ssh/authorized_keys
sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
sudo chmod 700 /home/$NEW_USER/.ssh
sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys

# Disable password authentication for SSH
sudo sed -i 's/^#?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Install and configure UFW and Apache
sudo apt update && sudo apt install -y ufw apache2 fail2ban
sudo ufw default deny incoming
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw --force enable

4. Add User Script (addUser.sh)

This script allows the creation of a new user with a password passed as a command-line argument:

#!/bin/bash

# Check if both username and password are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <password>"
  exit 1
fi

# Define the username and password
NEW_USER="$1"
USER_PASSWORD="$2"

# Create the new user and set password
sudo adduser --disabled-password --gecos "" $NEW_USER
echo "$NEW_USER:$USER_PASSWORD" | sudo chpasswd

# Add the new user to the sudo group
sudo usermod -aG sudo $NEW_USER

# Set up SSH key-based authentication
sudo mkdir -p /home/$NEW_USER/.ssh
sudo cp ~/.ssh/authorized_keys /home/$NEW_USER/.ssh/authorized_keys
sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
sudo chmod 700 /home/$NEW_USER/.ssh
sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys

5. Docker and Apache Setup (dockerAppache.sh)

The dockerAppache.sh script installs Docker, Apache, and configures Apache to act as a reverse proxy to an Nginx container:

#!/bin/bash

# Install Docker and Apache
sudo apt update -y
sudo apt install -y docker.io apache2

# Enable Apache proxy modules
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite

# Run Nginx in Docker
sudo docker pull nginx
sudo docker run -d --name nginx-container -p 8080:80 nginx

# Configure Apache reverse proxy
sudo bash -c 'cat <<EOL > /etc/apache2/sites-available/reverse-proxy.conf
<VirtualHost *:80>
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
</VirtualHost>
EOL'

# Enable Apache site configuration
sudo a2ensite reverse-proxy.conf
sudo systemctl restart apache2

6. Permissions and Running Scripts

Ensure that all shell scripts have executable permissions before running them.

To make a script executable:

chmod +x <script_name>.sh

For example:

chmod +x setup.sh
chmod +x addUser.sh
chmod +x dockerAppache.sh

Then, to run the scripts:

./setup.sh
./addUser.sh <username> <password>
./dockerAppache.sh

Conclusion

This project automates the process of provisioning an AWS EC2 instance, setting up users, securing SSH access, configuring a firewall, and deploying a web server. The scripts ensure that the EC2 instance is secure and ready for use with SSH key-based authentication, as well as a reverse proxy setup for Nginx running in Docker. 
