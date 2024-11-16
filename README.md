Building Cloud-Based Server for a Startup

This project automates the setup of an EC2 instance on AWS, including the creation of a new user with SSH key-based access, security configurations, and the installation of a web server (Apache) using Docker. The setup ensures that the instance is secure and ready for use with proper user management, firewall configurations, and web server deployment.
Project Structure
![tree](https://github.com/user-attachments/assets/c4460e31-bd06-4c27-85a2-0c8f5c0ef1d4)

Introduction

This project automates the provisioning of an EC2 instance on AWS and configures a secure environment with a web server. It uses Terraform for infrastructure provisioning and shell scripts for EC2 instance setup and service configuration.
Installation
Prerequisites

Before you begin, ensure you have the following tools and accounts set up:

    Terraform: Required to provision AWS resources. You can install it from here.
    AWS Account: Ensure you have an AWS account set up.
    SSH Key Pair: An existing SSH key pair (id_rsa.pub) for secure SSH access. You can generate it using ssh-keygen.
    Shell Access: Basic knowledge of Linux shell scripting.

Quick Start

Follow these steps to set up the project and deploy the resources.
1. Clone the Repository

Clone this repository to your local machine:

git clone <repository_url>
cd <project_directory>

2. Set Up Terraform

    Install Terraform if not already installed.
    Configure your AWS credentials. Run the following command to set your AWS Access Key, Secret Key, and region:

aws configure

3. Configure Terraform

Edit the ec2.tf file to modify any AWS region or resource configurations (e.g., AMI, instance type) if needed.
4. Initialize Terraform

Run the following command to initialize Terraform and download necessary plugins:

terraform init

5. Apply Terraform Configuration

Run the following command to create the EC2 instance and related resources:

terraform apply

Terraform will show you a plan of the resources it will create. Type yes to confirm.
6. SSH Access to EC2 Instance

After the Terraform script has finished running, Terraform will output the public IP address of the EC2 instance. Use this IP to SSH into the instance:

ssh -i ~/.ssh/id_rsa ubuntu@<ec2_public_ip>

7. Run Setup Scripts
7.1 Run setup.sh

The setup.sh script sets up the environment on the EC2 instance. It creates a new user with SSH key-based access and disables password-based authentication for SSH. It also installs necessary packages (UFW, Apache2, Fail2Ban).Config Fail2Ban for block ip after 5 failed attempts for 15 minutes.

./setup.sh

7.2 Run addUser.sh

The addUser.sh script creates a new user and sets up SSH key-based authentication. You can pass the username and password as arguments to the script:

./addUser.sh <username> <password>

7.3 Run dockerAppache.sh

This script installs Docker, Apache, and configures Apache to act as a reverse proxy for an Nginx container running in Docker.

./dockerAppache.sh

8. Access Web Server

Once everything is set up, you can access the web server by navigating to the public IP of the EC2 instance in your web browser:

http://<ec2_public_ip>

You should see the default Nginx page served through Apache.
Description of Scripts
setup.sh

    Creates a new user and sets up SSH key-based authentication.
    Disables password authentication for SSH.
    Installs and configures UFW (Uncomplicated Firewall) to allow necessary ports (SSH, HTTP).
    Installs Apache2 and Fail2Ban for added security.

addUser.sh

    Creates a new user with the specified username and password.
    Configures SSH key-based authentication for the user.
    Adds the user to the sudo group to grant administrative privileges.

dockerAppache.sh

    Installs Docker and Apache.
    Configures Apache to act as a reverse proxy to an Nginx container running inside Docker.
    Enables necessary Apache proxy modules.

Cleanup

To destroy the resources created by Terraform, run:

terraform destroy

This will terminate the EC2 instance and remove any resources defined in the Terraform configuration.
