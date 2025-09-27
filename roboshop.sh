#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-00f51e3430243ff58"

for instance in $@
do
     INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-00f51e3430243ff58 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

     if [ $instance != "frontend"]; then
     IP=$(aws ec2 describe-instances --instance-ids $InstanceId --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
      IP=$(aws ec2 describe-instances --instance-ids $InstanceId --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi

    echo "$instance: $IP
done    
