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
