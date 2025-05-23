Deployment Instructions
Local Development

Build Docker images:
Backend: cd backend && docker build -t backend .
Frontend: cd frontend && ng build --prod && docker build -t frontend .

Run locally:docker-compose -f infrastructure/docker-compose.yaml up --build

AWS Deployment

Set up AWS resources using Terraform:cd infrastructure
terraform init
terraform apply

Push images to Amazon ECR:aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.us-east-1.amazonaws.com
docker tag backend:latest <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/backend-repo:latest
docker push <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/backend-repo:latest
docker tag frontend:latest <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/frontend-repo:latest
docker push <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/frontend-repo:latest

Deploy to Kubernetes:
SSH into EC2 instance: ssh -i your-key.pem ec2-user@<ec2-public-ip>
Apply manifests:kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml

Access services:
Get service URLs: kubectl get services -n document-management
Frontend: `[invalid url, do not cite]
Backend: `[invalid url, do not cite]

Monitoring

Use AWS CloudWatch to monitor EC2 and RDS usage.
Stop resources when not in use to stay within Free Tier limits:aws ec2 stop-instances --instance-ids <instance-id>
aws rds stop-db-instance --db-instance-identifier docmanagement-db

AWS Deployment & Setup Guide for Document Management System:

1. Prerequisites:
AWS CLI installed and configured (aws configure)

kubectl installed

eksctl installed (for quick EKS setup)

Terraform installed

Docker installed & logged in to AWS ECR (aws ecr get-login-password | docker login ...)

2. Create AWS Infrastructure with Terraform:
   Navigate to infrastructure/

Run terraform init

Run terraform plan to preview changes

Run terraform apply to create infra (VPC, EKS cluster, RDS etc.)

Confirm resources created in AWS Console

3. Configure kubectl for EKS:
   Use aws eks update-kubeconfig --region <region> --name <cluster_name>

Verify cluster access: kubectl get nodes

4. Build & Push Docker Images to AWS ECR:
   Authenticate Docker with ECR:
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com

Build backend image:
docker build -t backend-repo ../backend

Tag backend image:
docker tag backend-repo:latest <account-id>.dkr.ecr.<region>.amazonaws.com/backend-repo:latest

Push backend image:
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/backend-repo:latest

Repeat for frontend

5. Deploy Backend and Frontend to EKS:
   Make sure namespace document-management exists:
   kubectl create namespace document-management

Create Kubernetes secret for JWT secret:
kubectl -n document-management create secret generic backend-secrets --from-literal=jwt-secret=<your-secret-key>

Deploy backend:
kubectl apply -f infrastructure/backend-deployment.yaml

Deploy frontend:
kubectl apply -f infrastructure/frontend-deployment.yaml

Check pods and services:
kubectl get pods -n document-management
kubectl get svc -n document-management

6. Local Development with Docker Compose:
   From infrastructure folder, run:
   docker-compose up --build

Access backend at http://localhost:8000

Access frontend at http://localhost
"# Infrastructure" 
