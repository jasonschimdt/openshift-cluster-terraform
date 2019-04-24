data "template_file" "inventory" {
  template = "${file("${path.cwd}/helper_scripts/ansible-inventory.template.cfg")}"
  vars {
    default_subdomain = "${var.openshift_default_subdomain}"
    public_hostname = "${var.openshift_public_hostname}"

    master_inventory = "${aws_instance.master.private_dns}"
    master_hostname = "${aws_instance.master.private_dns}"
    node1_hostname = "${aws_instance.node1.private_dns}"
    node2_hostname = "${aws_instance.node2.private_dns}"

    cluster_id = "${var.cluster_id}"
    demo_htpasswd = "${var.htpasswd}"
  }
}
resource "local_file" "inventory" {
  content     = "${data.template_file.inventory.rendered}"
  filename = "${path.cwd}/inventory.cfg"
}