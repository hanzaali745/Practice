#!/usr/bin/env bash
# vpc_lab.sh [--with-nat] | --cleanup — build a 2-AZ VPC by hand with the AWS CLI:
#   VPC 10.20.0.0/16 · public + private subnet per AZ · internet gateway · route tables · 3 chained security groups
#   --with-nat also creates a NAT gateway (☁️ ~$1/day + traffic! delete it the same day)
# Run on local AWS (source ../../local-aws/env.sh) or a sandbox account. Everything is tagged project=vpc-lab.
set -euo pipefail
TAG='Key=project,Value=vpc-lab'
say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
tagspec() { echo "ResourceType=$1,Tags=[{$TAG},{Key=Name,Value=$2}]"; }
region=${AWS_REGION:-${AWS_DEFAULT_REGION:-eu-west-1}}

if [[ ${1:-} == --cleanup ]]; then
    vpc=$(aws ec2 describe-vpcs --filters Name=tag:project,Values=vpc-lab --query 'Vpcs[0].VpcId' --output text)
    [[ $vpc == None ]] && { echo "nothing to clean"; exit 0; }
    for nat in $(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values="$vpc" Name=state,Values=available --query 'NatGateways[].NatGatewayId' --output text); do
        aws ec2 delete-nat-gateway --nat-gateway-id "$nat" > /dev/null
        aws ec2 wait nat-gateway-deleted --nat-gateway-ids "$nat" 2>/dev/null || true
    done
    for eip in $(aws ec2 describe-addresses --filters Name=tag:project,Values=vpc-lab --query 'Addresses[].AllocationId' --output text); do
        aws ec2 release-address --allocation-id "$eip"
    done
    for sg in $(aws ec2 describe-security-groups --filters Name=vpc-id,Values="$vpc" Name=tag:project,Values=vpc-lab --query 'SecurityGroups[].GroupId' --output text); do
        aws ec2 delete-security-group --group-id "$sg" 2>/dev/null || true      # db, then app, then alb...
    done
    for sg in $(aws ec2 describe-security-groups --filters Name=vpc-id,Values="$vpc" Name=tag:project,Values=vpc-lab --query 'SecurityGroups[].GroupId' --output text); do
        aws ec2 delete-security-group --group-id "$sg"                          # ...second pass for the rest
    done
    for igw in $(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values="$vpc" --query 'InternetGateways[].InternetGatewayId' --output text); do
        aws ec2 detach-internet-gateway --internet-gateway-id "$igw" --vpc-id "$vpc"
        aws ec2 delete-internet-gateway --internet-gateway-id "$igw"
    done
    for assoc in $(aws ec2 describe-route-tables --filters Name=vpc-id,Values="$vpc" Name=tag:project,Values=vpc-lab \
            --query 'RouteTables[].Associations[?!Main].RouteTableAssociationId' --output text); do
        aws ec2 disassociate-route-table --association-id "$assoc"
    done
    for subnet in $(aws ec2 describe-subnets --filters Name=vpc-id,Values="$vpc" --query 'Subnets[].SubnetId' --output text); do
        aws ec2 delete-subnet --subnet-id "$subnet"
    done
    for rt in $(aws ec2 describe-route-tables --filters Name=vpc-id,Values="$vpc" Name=tag:project,Values=vpc-lab --query 'RouteTables[].RouteTableId' --output text); do
        aws ec2 delete-route-table --route-table-id "$rt"
    done
    aws ec2 delete-vpc --vpc-id "$vpc"
    echo "deleted $vpc and everything in it"; exit 0
fi

say "1. VPC"
vpc=$(aws ec2 create-vpc --cidr-block 10.20.0.0/16 --tag-specifications "$(tagspec vpc vpc-lab)" --query Vpc.VpcId --output text)
aws ec2 modify-vpc-attribute --vpc-id "$vpc" --enable-dns-hostnames
echo "$vpc"

say "2. Subnets: public 10.20.0.0/20 + 10.20.16.0/20, private 10.20.128.0/20 + 10.20.144.0/20 (python3 cidr_planner.py)"
read -r az1 az2 _ <<< "$(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text)"
pub1=$(aws ec2 create-subnet --vpc-id "$vpc" --cidr-block 10.20.0.0/20 --availability-zone "$az1" --tag-specifications "$(tagspec subnet public-a)" --query Subnet.SubnetId --output text)
pub2=$(aws ec2 create-subnet --vpc-id "$vpc" --cidr-block 10.20.16.0/20 --availability-zone "$az2" --tag-specifications "$(tagspec subnet public-b)" --query Subnet.SubnetId --output text)
priv1=$(aws ec2 create-subnet --vpc-id "$vpc" --cidr-block 10.20.128.0/20 --availability-zone "$az1" --tag-specifications "$(tagspec subnet private-a)" --query Subnet.SubnetId --output text)
priv2=$(aws ec2 create-subnet --vpc-id "$vpc" --cidr-block 10.20.144.0/20 --availability-zone "$az2" --tag-specifications "$(tagspec subnet private-b)" --query Subnet.SubnetId --output text)
for s in "$pub1" "$pub2"; do aws ec2 modify-subnet-attribute --subnet-id "$s" --map-public-ip-on-launch; done

say "3. Internet gateway + public route table (0.0.0.0/0 → IGW) — this is what makes a subnet 'public'"
igw=$(aws ec2 create-internet-gateway --tag-specifications "$(tagspec internet-gateway vpc-lab)" --query InternetGateway.InternetGatewayId --output text)
aws ec2 attach-internet-gateway --internet-gateway-id "$igw" --vpc-id "$vpc"
rt_pub=$(aws ec2 create-route-table --vpc-id "$vpc" --tag-specifications "$(tagspec route-table public)" --query RouteTable.RouteTableId --output text)
aws ec2 create-route --route-table-id "$rt_pub" --destination-cidr-block 0.0.0.0/0 --gateway-id "$igw" > /dev/null
for s in "$pub1" "$pub2"; do aws ec2 associate-route-table --route-table-id "$rt_pub" --subnet-id "$s" > /dev/null; done

say "4. Private route table: no route to the internet (add a NAT gateway with --with-nat)"
rt_priv=$(aws ec2 create-route-table --vpc-id "$vpc" --tag-specifications "$(tagspec route-table private)" --query RouteTable.RouteTableId --output text)
for s in "$priv1" "$priv2"; do aws ec2 associate-route-table --route-table-id "$rt_priv" --subnet-id "$s" > /dev/null; done
if [[ ${1:-} == --with-nat ]]; then
    eip=$(aws ec2 allocate-address --domain vpc --tag-specifications "$(tagspec elastic-ip nat)" --query AllocationId --output text)
    nat=$(aws ec2 create-nat-gateway --subnet-id "$pub1" --allocation-id "$eip" --tag-specifications "$(tagspec natgateway nat)" --query NatGateway.NatGatewayId --output text)
    aws ec2 wait nat-gateway-available --nat-gateway-ids "$nat"
    aws ec2 create-route --route-table-id "$rt_priv" --destination-cidr-block 0.0.0.0/0 --nat-gateway-id "$nat" > /dev/null
    echo "NAT gateway $nat — private subnets can reach the internet (outbound only). ☁️ It costs money!"
fi

say "5. Security groups, chained by REFERENCE (not by IP): internet → alb → app → db"
alb=$(aws ec2 create-security-group --vpc-id "$vpc" --group-name alb --description "load balancer" --tag-specifications "$(tagspec security-group alb)" --query GroupId --output text)
app=$(aws ec2 create-security-group --vpc-id "$vpc" --group-name app --description "demo-app" --tag-specifications "$(tagspec security-group app)" --query GroupId --output text)
db=$(aws ec2 create-security-group --vpc-id "$vpc" --group-name db --description "database" --tag-specifications "$(tagspec security-group db)" --query GroupId --output text)
aws ec2 authorize-security-group-ingress --group-id "$alb" --protocol tcp --port 443 --cidr 0.0.0.0/0 > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$app" --protocol tcp --port 8000 --source-group "$alb" > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$db" --protocol tcp --port 5432 --source-group "$app" > /dev/null

say "6. The result"
# shellcheck disable=SC2016  # the backticks are a JMESPath literal, not shell
aws ec2 describe-subnets --filters Name=vpc-id,Values="$vpc" \
    --query 'sort_by(Subnets, &Tags[?Key==`Name`]|[0].Value)[].{Name: Tags[?Key==`Name`]|[0].Value, CIDR: CidrBlock, AZ: AvailabilityZone, PublicIP: MapPublicIpOnLaunch}' --output table
aws ec2 describe-security-groups --group-ids "$alb" "$app" "$db" \
    --query 'SecurityGroups[].{SG: GroupName, Port: IpPermissions[0].FromPort, From: IpPermissions[0].IpRanges[0].CidrIp || IpPermissions[0].UserIdGroupPairs[0].GroupId}' --output table
echo; echo "✅ VPC $vpc in $region — clean up with: $0 --cleanup"
