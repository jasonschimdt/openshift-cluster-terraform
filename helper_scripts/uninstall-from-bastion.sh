#!/usr/bin/env bash
set -x

# If needed, uninstall with the below:
ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/adhoc/uninstall.yml