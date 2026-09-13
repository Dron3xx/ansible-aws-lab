module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ansible-aws-lab-vpc"
  cidr = "172.20.0.0/16"

  azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnets = [
    "172.20.1.0/24",
    "172.20.2.0/24",
    "172.20.3.0/24"
  ]

  enable_nat_gateway = false

  tags = {
    Project = "ansible-aws-lab"
  }
}

resource "aws_security_group" "ansible-aws-lab-sg" {
  name        = "ansible-aws-lab-sg"
  description = "Security group for Ansible lab"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Collectd Prometheus"
    from_port   = 9103
    to_port     = 9103
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "ansible-aws-lab"
  }
}

data "aws_ami" "ansible-aws-lab-ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  instances = {
    control = module.vpc.public_subnets[0]
    node1   = module.vpc.public_subnets[1]
    node2   = module.vpc.public_subnets[2]
  }
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = local.instances

  name = each.key

  ami               = data.aws_ami.ansible-aws-lab-ami.id
  instance_type     = "t3.micro"
  root_block_device = { volume_size = 10 }

  key_name                    = "ansible-aws-lab"
  subnet_id                   = each.value
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ansible-aws-lab-sg.id]

  tags = {
    Project     = "ansible-aws-lab"
    Terraform   = "true"
    Environment = "dev"
  }
}