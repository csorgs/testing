
resource "aws_instance" "webserver" {
ami = "${var.myamiid}"
instance_type = "t2.medium"
subnet_id = "${aws_subnet.publicsubnet1.id}"
private_ip = "192.168.4.4"
vpc_security_group_ids = ["${aws_security_group.websg.id}"]
key_name = "virginia"
user_data = "${data.template_file.webserver-userdata.rendered}"
}
data "template_file" "webserver-userdata" {
  template = "${file("./userdata.tpl")}"
}

resource "aws_instance" "dbserver" {
ami = "${var.myamiid}"
instance_type = "t2.medium"
subnet_id = "${aws_subnet.publicsubnet2.id}"
private_ip = "192.168.5.4"
vpc_security_group_ids = ["${aws_security_group.websg.id}"]
key_name = "virginia"
}
variable "myregion"{
type = "string"
default = "us-east-1"
}

variable "myamiid"{
type = "string"
#default = "ami-0affd4508a5d2481b"
default = "ami-025312911dac117a0"
}


output "webserverpublic_ip"{
value = "${aws_instance.webserver.public_ip}"
}



resource "aws_security_group" "websg" {
  name        = "websg"
  description = "Allow all traffic"
  vpc_id ="${aws_vpc.myvpc.id}"
  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "websg"
  }
}


############################################ Networking modules ###############################3
resource "aws_eip" "webeip"{
instance = "${aws_instance.webserver.id}"
}
resource "aws_eip" "dbeip"{
instance = "${aws_instance.dbserver.id}"
}
resource "aws_vpc" "myvpc"{
cidr_block = "192.168.0.0/16"
tags ={
Name = "myvpc"
}
}

resource "aws_internet_gateway" "myigw"{
vpc_id = "${aws_vpc.myvpc.id}"
tags={
Name = "myigw"
}
}


resource "aws_subnet" "publicsubnet1"{
vpc_id = "${aws_vpc.myvpc.id}"
cidr_block = "192.168.4.0/24"
tags={
Name = "publicsubnet1"
}
}

resource "aws_subnet" "publicsubnet2"{
vpc_id = "${aws_vpc.myvpc.id}"
cidr_block = "192.168.5.0/24"
tags={
Name = "publicsubnet2"
}
}
resource "aws_route_table" "publicrtb"{
vpc_id = "${aws_vpc.myvpc.id}"
tags = {
Name = "publicrtb"
}
}

resource "aws_route" "publicrt"{
route_table_id = "${aws_route_table.publicrtb.id}"
destination_cidr_block = "0.0.0.0/0"
gateway_id = "${aws_internet_gateway.myigw.id}"
}

resource "aws_route_table_association" "publicrtba1"{
route_table_id = "${aws_route_table.publicrtb.id}"
subnet_id = "${aws_subnet.publicsubnet1.id}"
}


resource "aws_route_table_association" "publicrtba2"{
route_table_id = "${aws_route_table.publicrtb.id}"
subnet_id = "${aws_subnet.publicsubnet2.id}"
}
provider "aws"{
region = "${var.myregion}"
shared_credentials_file = "/home/centos/.aws/credentials"
}
provider "template"{

}



