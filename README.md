# openshift-terraform

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
Leave about five minutes for everything to start up fully.

## Installing OpenShift

Copy the ssh key and ansible-hosts file to the bastion host from where you need to run the Ansible OpenShift playbooks.
```
ssh-add ./helper_scripts/id_rsa_bastion
ssh-keyscan -t rsa -H $(terraform output bastion-public_ip) >> ~/.ssh/known_hosts
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H master.openshift.local >> ~/.ssh/known_hosts"
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H node1.openshift.local >> ~/.ssh/known_hosts"
ssh -A ec2-user@$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H node2.openshift.local >> ~/.ssh/known_hosts"
scp ./helper_scripts/id_rsa ec2-user@$(terraform output bastion-public_ip):~/.ssh/
scp ./inventory.cfg ec2-user@$(terraform output bastion-public_ip):~
```

Then, copy our inventory to the master and run the install script.
```
cat ./helper_scripts/install-from-bastion.sh | ssh -o StrictHostKeyChecking=no -A ec2-user@$(terraform output bastion-public_ip)
```

Finally, run post install scripts
```
cat ./helper_scripts/postinstall-master.sh | ssh -A ec2-user@$$(terraform output bastion-public_ip) ssh master.openshift.local
cat ./helper_scripts/postinstall-node.sh | ssh -A ec2-user@$$(terraform output bastion-public_ip) ssh node1.openshift.local
cat ./helper_scripts/postinstall-node.sh | ssh -A ec2-user@$$(terraform output bastion-public_ip) ssh node2.openshift.local
```




```
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ./helper_scripts/id_rsa_bastion -r ./helper_scripts/id_rsa ec2-user@$(terraform output bastion-public_ip):~/.ssh/id_rsa
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/openshift_id_rsa -r ./inventory.cfg ec2-user@$(terraform output bastion-public_ip):~/
```
