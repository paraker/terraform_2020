#----compute/main.tf------
data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn-ami-hvm*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "tf_auth" {
  key_name    = "${var.key_name}"
  public_key  = "${file(var.public_key_path)}"
}

# Template file for ec2 userdata created through the Template provider
data "template_file" "user-init" {
  count    = 2
  template = "${file("${path.module}/userdata.tpl")}"  # path.module resolves to the path where this module is located

  # Variables for interpolation within the template. Note that variables must all be primitives, i.e. not lists or maps!
  vars {
    firewall_subnets = "${element(var.subnet_ips, count.index)}"  # element fetches the value at the specified index (count.index)
  }
}

resource "aws_instance" "tf_server" {
  count         = "${var.instance_count}"  # set count by variable from the root module
  instance_type = "${var.instance_type}"  # set instance type by variable from the root module
  ami           = "${data.aws_ami.server_ami.id}"  # Defined above in this file

  tags {
    Name = "tf_server-${count.index +1}"  # tf_server-1 and tf_server-2
  }

  key_name               = "${aws_key_pair.tf_auth.id}"  # Defined above in this file
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id              = "${element(var.subnets, count.index)}"  # element fetches the value at the specified index (count.index)
  # Reference to the counted template_file rendered text is done with *.rendered[count.index]
  # Translates to template_file.user-init.0.id then template_file.user-init.1.rendered
  user_data              = "${data.template_file.user-init.*.rendered[count.index]}"
}