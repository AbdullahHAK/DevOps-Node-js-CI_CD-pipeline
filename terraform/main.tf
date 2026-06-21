# specifying cloud provider
provider "aws" {
    region= "us-east-1"
}

# uploading local SSH public key to AWS
resource "aws_key_pair" "deployer_key" {
    key_name = "devops-pipeline-key"
    public_key = file("~/.ssh/id_rsa.pub")
}

# security group to allow SSH and web traffic
resource "aws_security_group" "pipeline_sg" {
    name = "devops-pipeline-sg"
    description = "Allow SSH and web traffic"

# allow SSH port 22 from anywhere
ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

# allow Node.js app traffic (port 3000)
ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

# allow HTTP traffic (port 80)
ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

# so that EC2 can install packages
egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "web_server" {
  ami           = "ami-0b6d9d3d33ba97d99" 
  instance_type = "t3.micro"             # free tier eligible

  key_name               = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids = [aws_security_group.pipeline_sg.id]

  tags = {
    Name = "NodeJS-Pipeline-Server"
  }
}