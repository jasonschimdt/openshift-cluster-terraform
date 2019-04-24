# openshift-terraform

A terraform project to automatically create a complete 3-node OKD cluster (OKD = Open source openshift - https://www.okd.io/) on AWS leveraging standard Enterprise RHEL 7 image.

Credits: this project was heavily inspired from these 2 great projects (sort of merged them and modified them to fit my needs)
 - https://github.com/dwmkerr/terraform-aws-openshift
 - https://github.com/berndonline/openshift-terraform

## Prerequisites

You need:

1. [Terraform](https://www.terraform.io/intro/getting-started/install.html) - `brew update && brew install terraform`
2. An AWS account, configured with the cli locally

## Get the code and initial setup

```
git clone -b aws-dev https://github.com/lanimall/openshift-terraform.git
cd ./openshift-terraform/
ssh-keygen -b 2048 -t rsa -f ./helper_scripts/id_rsa_bastion -q -N ""
ssh-keygen -b 2048 -t rsa -f ./helper_scripts/id_rsa -q -N ""
chmod 600 ./helper_scripts/id_rsa*
```

## Creating the Cluster

Create the infrastructure first:

```bash
terraform init && terraform apply -auto-approve 
```

After a little while, all AWS infrastructure should have been created...you should see:

```
...
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
```

That's it! The infrastructure is ready and you can install OpenShift. 
There are some post-provisoning scripts that are running after the AWS nodes are up...so leave about five minutes for everything to start up fully.

To make sure the provisoning scripts are really finished...a simple check is to verify that ansible was installed properly on the bastion host:
```
ssh -A ec2-user@$(terraform output bastion-public_ip) "ansible --version"
```

Which should poutput:
```
ansible 2.6.5
  config file = None
  configured module search path = [u'/home/ec2-user/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Mar 26 2019, 22:13:06) [GCC 4.8.5 20150623 (Red Hat 4.8.5-36)]
```

You can also check the provisoning logs:
```
ssh -A ec2-user@$(terraform output bastion-public_ip) "tail -f /var/log/user-data.log"
```

Couple of output variables that you can reference later using notation  'terraform output <output>':
 - bastion-private_dns
 - bastion-private_ip
 - bastion-public_ip
 - master-private_dns
 - master-private_ip
 - master-private_route53_dns
 - master-public_ip
 - node1-private_dns
 - node1-private_ip
 - node1-private_route53_dns
 - node1-public_ip
 - node2-private_dns
 - node2-private_ip
 - node2-private_route53_dns
 - node2-public_ip

## Installing OpenShift

Copy the ssh key and ansible-hosts file to the bastion host from where you need to run the Ansible OpenShift playbooks.
```
ssh-add ./helper_scripts/id_rsa_bastion &&
ssh-keyscan -t rsa -H $(terraform output bastion-public_ip) >> ~/.ssh/known_hosts && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output master-private_route53_dns)>> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output master-private_dns) >> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output master-private_ip) >> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output node1-private_route53_dns)>> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output node1-private_dns) >> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output node1-private_ip) >> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output node2-private_route53_dns)>> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output node2-private_dns) >> ~/.ssh/known_hosts" && \
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H $(terraform output node2-private_ip) >> ~/.ssh/known_hosts" && \
scp ./helper_scripts/id_rsa ec2-user@$(terraform output bastion-public_ip):~/.ssh/ && \
scp ./inventory.cfg ec2-user@$(terraform output bastion-public_ip):~ && \
echo DONE!
```

Then, run the install script.
```
cat ./helper_scripts/install-from-bastion.sh | ssh -A ec2-user@$(terraform output bastion-public_ip)
```

NOTE: Bet patient...this will take 10s of minutes: ansible at work!!!

If all went well, you should see the following output at the end:

```
...
INSTALLER STATUS ***************************************************************
Initialization               : Complete (0:00:23)
Health Check                 : Complete (0:00:05)
Node Bootstrap Preparation   : Complete (0:03:34)
etcd Install                 : Complete (0:00:45)
Master Install               : Complete (0:04:37)
Master Additional Install    : Complete (0:00:42)
Node Join                    : Complete (0:00:46)
Hosted Install               : Complete (0:00:57)
Cluster Monitoring Operator  : Complete (0:01:18)
Web Console Install          : Complete (0:00:55)
Console Install              : Complete (0:00:22)
Metrics Install              : Complete (0:02:08)
metrics-server Install       : Complete (0:00:50)
Service Catalog Install      : Complete (0:03:43)
```

Finally, when the ansible scripts are finished, run post install scripts:
```
cat ./helper_scripts/postinstall-master.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh master.openshift.local
cat ./helper_scripts/postinstall-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh node1.openshift.local
cat ./helper_scripts/postinstall-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh node2.openshift.local
```


If the public DNS name you assigned to the openshift install is not in a public DNS, siomply add the public IP of the master node in your local host file...
```
echo "$(terraform output master-public_ip) console.awspaas.clouddemo.saggov.com" >> /etc/hosts
```

Then, should be able to login to openshift CLI or web console) with our sample cluster-admin test user.
```
oc login -u admin -p test123! https://console.awspaas.clouddemo.saggov.com:8443
```