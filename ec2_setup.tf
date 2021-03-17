provider "aws" {
region = "us-east-1"
}

resource "aws_security_group" "ec2" {
  name = "test_sg"

  description = "EC2 security group (terraform-managed)"
  #vpc_id      = aws_vpc.main.id


  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    description = "Telnet"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Telnet"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "ansible_elasticsearch_test" {
  count = 1
  ami           = "ami-038f1ca1bd58a5790"
  instance_type = "t2.micro"
  key_name      = "elk_test"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  tags = {
    Name = "ansible_inventory_test_${count.index + 1}"
  }
} 

resource "null_resource" "ConfigureAnsibleLabelVariable" {
  provisioner "local-exec" {
    command = "echo [Ansible_Hosts:vars] > /etc/ansible/hosts"
  }
  provisioner "local-exec" {
    command = "echo ansible_ssh_user=ec2-user >> /etc/ansible/hosts"
  }
  provisioner "local-exec" {
    command = "echo ansible_ssh_private_key_file=/home/ec2-user/elk_test.pem >> /etc/ansible/hosts"
  }
  provisioner "local-exec" {
    command =  "echo ansible_ssh_extra_args='-o StrictHostKeyChecking=no' >> /etc/ansible/hosts"
  }
  provisioner "local-exec" {
    command = "echo [Ansible_Hosts] >> /etc/ansible/hosts"
  }
}

resource "null_resource" "ProvisionRemoteHostsIpToAnsibleHosts" {
  count = 1
  connection {
    type = "ssh"
    user = "ec2-user"
    host = "${element(aws_instance.ansible_elasticsearch_test.*.private_ip, count.index)}"
    private_key = file("/home/ec2-user/elk_test.pem")
  }
  provisioner "remote-exec" {
   inline = [
      "sudo yum install git -y"
    ]
  }
  provisioner "local-exec" {
    command = "echo ${element(aws_instance.ansible_elasticsearch_test.*.private_ip, count.index)} >> /etc/ansible/hosts"
  }
}
