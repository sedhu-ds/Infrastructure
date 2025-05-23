provider "aws" {
       region = "us-east-1"
     }

     # Create VPC
     resource "aws_vpc" "main" {
       cidr_block = "10.0.0.0/16"
     }

     # Create Subnet
     resource "aws_subnet" "public" {
       vpc_id     = aws_vpc.main.id
       cidr_block = "10.0.1.0/24"
       map_public_ip_on_launch = true
     }

     # Create Internet Gateway
     resource "aws_internet_gateway" "gw" {
       vpc_id = aws_vpc.main.id
     }

     # Create Route Table
     resource "aws_route_table" "public" {
       vpc_id = aws_vpc.main.id
       route {
         cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.gw.id
       }
     }

     # Associate Route Table with Subnet
     resource "aws_route_table_association" "public" {
       subnet_id      = aws_subnet.public.id
       route_table_id = aws_route_table.public.id
     }

     # Create Security Group for Kubernetes Nodes
     resource "aws_security_group" "k8s_nodes" {
       name        = "k8s_nodes"
       description = "Security group for Kubernetes nodes"
       vpc_id      = aws_vpc.main.id

       ingress {
         from_port   = 22
         to_port     = 22
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"] # Restrict in production
       }

       ingress {
         from_port   = 80
         to_port     = 80
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
       }

       ingress {
         from_port   = 8000
         to_port     = 8000
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
       }

       ingress {
         from_port   = 6443
         to_port     = 6443
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"] # Kubernetes API server
       }

       egress {
         from_port   = 0
         to_port     = 0
         protocol    = "-1"
         cidr_blocks = ["0.0.0.0/0"]
       }
     }

     # Create Security Group for RDS
     resource "aws_security_group" "rds" {
       name        = "rds_sg"
       description = "Security group for RDS"
       vpc_id      = aws_vpc.main.id

       ingress {
         from_port       = 5432
         to_port         = 5432
         protocol        = "tcp"
         security_groups = [aws_security_group.k8s_nodes.id]
       }
     }

     # Create EC2 Instance for Kubernetes Node
     resource "aws_instance" "k8s_node" {
       ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (update as needed)
       instance_type = "t2.micro"
       key_name      = "your-key-pair" # Replace with your key pair
       subnet_id     = aws_subnet.public.id
       vpc_security_group_ids = [aws_security_group.k8s_nodes.id]

       tags = {
         Name = "k8s-node"
       }
     }

     # Create RDS Instance
     resource "aws_db_instance" "postgres" {
       allocated_storage    = 20
       engine               = "postgres"
       engine_version       = "13.3"
       instance_class       = "db.t2.micro"
       name                 = "doc_management"
       username             = "admin"
       password             = "your-password" # Use a secure password
       publicly_accessible  = true # Disable in production
       skip_final_snapshot  = true
       vpc_security_group_ids = [aws_security_group.rds.id]
     }

     # Create ECR Repositories
     resource "aws_ecr_repository" "backend" {
       name = "backend-repo"
     }

     resource "aws_ecr_repository" "frontend" {
       name = "frontend-repo"
     }

     # Output RDS Endpoint and ECR URIs
     output "rds_endpoint" {
       value = aws_db_instance.postgres.endpoint
     }

     output "backend_ecr_uri" {
       value = aws_ecr_repository.backend.repository_url
     }

     output "frontend_ecr_uri" {
       value = aws_ecr_repository.frontend.repository_url
     }