resource "aws_key_pair" "openshift_bastion" {
  key_name   = "${var.openshift_bastion_key_name}"
  public_key = "${file(var.openshift_bastion_key_path)}"
}

resource "aws_key_pair" "openshift_nodes" {
  key_name   = "${var.openshift_nodes_key_name}"
  public_key = "${file(var.openshift_nodes_key_path)}"
}

//  Create the bastion userdata script.
data "template_file" "setup-bastion" {
  template = "${file("./helper_scripts/setup-bastion.sh")}"
  vars {
    availability_zone = "${var.azs}"
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "bastion" {
  ami                  = "${var.default_ami}"
  instance_type        = "t2.micro"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-bastion.rendered}"
  key_name            = "${aws_key_pair.openshift_bastion.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-ssh.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "OpenShift Bastion"
    )
  )}"
}

//  Create the master userdata script.
data "template_file" "setup-master" {
  template = "${file("./helper_scripts/setup-master.sh")}"
  vars {
    availability_zone = "${var.azs}"
  }
}

//  Launch configuration for the consul cluster auto-scaling group.
resource "aws_instance" "master" {
  ami                  = "${var.default_ami}"
  # Master nodes require at least 16GB of memory.
  instance_type        = "m4.xlarge"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-master.rendered}"
  key_name            = "${aws_key_pair.openshift_nodes.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Storage for Docker, see:
  # https://docs.openshift.org/latest/install_config/install/host_preparation.html#configuring-docker-storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 50
    volume_type = "gp2"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "OpenShift Master"
    )
  )}"
}

//  Create the node userdata script.
data "template_file" "setup-node" {
  template = "${file("./helper_scripts/setup-node.sh")}"
  vars {
    availability_zone = "${var.azs}"
  }
}

//  Create the two nodes. This would be better as a Launch Configuration and
//  autoscaling group, but I'm keeping it simple...
resource "aws_instance" "node1" {
  ami                  = "${var.default_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-node.rendered}"
  key_name            = "${aws_key_pair.openshift_nodes.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Storage for Docker, see:
  # https://docs.openshift.org/latest/install_config/install/host_preparation.html#configuring-docker-storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 50
    volume_type = "gp2"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "OpenShift Node 1"
    )
  )}"
}

resource "aws_instance" "node2" {
  ami                  = "${var.default_ami}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  user_data            = "${data.template_file.setup-node.rendered}"
  key_name            = "${aws_key_pair.openshift_nodes.id}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Storage for Docker, see:
  # https://docs.openshift.org/latest/install_config/install/host_preparation.html#configuring-docker-storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 50
    volume_type = "gp2"
  }
  
  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "OpenShift Node 2"
    )
  )}"
}