#!/bin/bash

# Set variables
CLUSTER_NAME="DSOCluster"
REGION="ap-south-1"
NAMESPACE="kube-system"
LOAD_BALANCER_ROLE_NAME="AmazonEKSLoadBalancerControllerRole"
LOAD_BALANCER_POLICY_ARNS=(
  "arn:aws:iam::764215225311:policy/AWSLoadBalancerControllerIAMPolicy"
  "arn:aws:iam::764215225311:policy/ALBIngressControllerIAMPolicy"
  "arn:aws:iam::764215225311:policy/AWSLoadBalancerControllerIAMPolicyALB"
)
EBS_CSI_ROLE_NAME="AmazonEKS_EBS_CSI_DriverRole"
EBS_CSI_POLICY_ARNS=(
  "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  "arn:aws:iam::764215225311:policy/CustomKmsPolicy"
)
VPC_ID="vpc-0d759f356471de32e"

# Associate IAM OIDC provider
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --region $REGION --approve

# Create IAM service account for AWS Load Balancer Controller
eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --region=$REGION \
  --namespace=$NAMESPACE \
  --name=aws-load-balancer-controller \
  --role-name $LOAD_BALANCER_ROLE_NAME \
  $(for policy in "${LOAD_BALANCER_POLICY_ARNS[@]}"; do echo --attach-policy-arn=$policy; done) \
  --approve

# Install AWS Load Balancer Controller using Helm
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n $NAMESPACE \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$REGION \
  --set vpcId=$VPC_ID

# Create IAM service account for EBS CSI Driver
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace $NAMESPACE \
  --cluster $CLUSTER_NAME \
  --role-name $EBS_CSI_ROLE_NAME \
  --role-only \
  $(for policy in "${EBS_CSI_POLICY_ARNS[@]}"; do echo --attach-policy-arn=$policy; done) \
  --region $REGION \
  --approve

# Create EBS CSI Driver Addon
eksctl create addon --name aws-ebs-csi-driver --cluster $CLUSTER_NAME --region $REGION \
  --service-account-role-arn arn:aws:iam::764215225311:role/$EBS_CSI_ROLE_NAME --force

# Creating namespace 

kubectl create ns testing
kubectl create ns uat

cp -R .kube /home/ec2-user/
chown -R ec2-user /home/ec2-user/.kube/
echo "Setup complete."
