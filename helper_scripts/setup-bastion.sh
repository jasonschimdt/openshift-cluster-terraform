#!/usr/bin/env bash

# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

mkdir -p /etc/aws/
cat > /etc/aws/aws.conf <<- EOF
[Global]
Zone = ${availability_zone}
EOF

# Create initial logs config.
cat > ./awslogs.conf << EOF
[general]
state_file = /var/awslogs/state/agent-state

[/var/log/messages]
log_stream_name = openshift-bastion-{instance_id}
log_group_name = /var/log/messages
file = /var/log/messages
datetime_format = %b %d %H:%M:%S
buffer_duration = 5000
initial_position = start_of_file

[/var/log/user-data.log]
log_stream_name = openshift-bastion-{instance_id}
log_group_name = /var/log/user-data.log
file = /var/log/user-data.log
EOF

# Install epel
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install dev tools.
yum install -y "@Development Tools" python36 python36-devel python-pip openssl-devel gcc libffi-devel
yum install -y pyOpenSSL python-cryptography python-lxml httpd-tools java-1.8.0-openjdk-headless
pip install --upgrade pip
pip install passlib

#!/usr/bin/env bash
yum update -y

# Get the OKD 3.11 installer.
pip install -I ansible==2.6.5
git clone -b release-3.11 https://github.com/openshift/openshift-ansible

# # Get the OpenShift 3.10 installer.
# pip install -I ansible==2.6.5
# git clone -b release-3.10 https://github.com/openshift/openshift-ansible

# Get the OpenShift 3.9 installer.
# pip install -I ansible==2.4.3.0
# git clone -b release-3.9 https://github.com/openshift/openshift-ansible

# Get the OpenShift 3.7 installer.
# pip install -Iv ansible==2.4.1.0
# git clone -b release-3.7 https://github.com/openshift/openshift-ansible

# Get the OpenShift 3.6 installer.
# pip install -Iv ansible==2.3.0.0
# git clone -b release-3.6 https://github.com/openshift/openshift-ansible