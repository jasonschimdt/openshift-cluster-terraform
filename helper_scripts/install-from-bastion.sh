#!/usr/bin/env bash
set -x

# Run the playbook.
ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/prerequisites.yml
ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/deploy_cluster.yml

# If needed, uninstall with the below:
#ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/adhoc/uninstall.yml