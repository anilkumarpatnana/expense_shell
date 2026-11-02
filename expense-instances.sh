#!/bin/bash

image_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
instance_name=$@
security_groups="expense-common" "expense-$instance_name"
domain_name="expense.anilkumarpatnana.online"
hosted_zone_id="Z0932076Y9TWK3RWNWAE"

for $instance_name in $@ {

    if [ $instance_name -ne "frontend" ];
        then
        ip=$(aws ec2 run-instances \
                        --image-id $image_id \
                        --instance-type $instance_type \
                        --security-groups $security_groups \
                        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=expense-$instance_name}]' \
                        --query 'Instances[0].PrivateIpAddress'
            )
        echo "Your $instance_name instance Private IP : $ip"
        else
        ip=$(aws ec2 run-instances \
                        --image-id $image_id \
                        --instance-type $instance_type \
                        --security-groups $security_groups \
                        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=expense-$instance_name}]' \
                        --query 'Instances[0].PublicIpAddress'
            )
        echo "Your $instance_name instance Public IP : $ip"
    fi
    
}


aws route53 change-resource-record-sets \
    --hosted-zone-id $hosted_zone_id \
    --change-batch '{
        "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$instance_name.$domain_name",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [{
                    "Value": "$ip"
                }]
            }
        }]
    }'