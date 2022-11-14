#!/bin/bash
# Update installed packages to the latest available releases.
sudo yum -y update

# Install Docker.
sudo yum -y install docker
sudo service docker start  # Start Docker daemon.
sudo usermod -a -G docker ec2-user  # Avoid using "sudo" for each command.

# Install psql and jq
sudo tee /etc/yum.repos.d/pgdg.repo<<EOF
[pgdg12]
name=PostgreSQL 12 for RHEL/CentOS 7 - x86_64
baseurl=https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-7-x86_64
enabled=1
gpgcheck=0
EOF
****
sudo yum -y makecache
sudo yum -y install postgresql12 postgresql12-server jq
