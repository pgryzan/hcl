////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           hcl
//  File Name:      main.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           June 2020
//  Description:    This is the main execution file
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Environment
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
terraform {
    required_version            = ">= 0.12.24"
}

locals {
    data_center                 = "demo"
    consul_version              = "1.7.3"
    tags                        = {
    }
}

provider "aws" {
    access_key                  = var.aws.access_key
    secret_key                  = var.aws.secret_key
    region                      = var.aws.region
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
data "aws_ami" "ubuntu" {
    most_recent                 = true

    filter {
        name                    = "name"
        values                  = [var.image.name]
    }

    filter {
        name                    = "virtualization-type"
        values                  = ["hvm"]
    }

    owners                      = [var.image.owner]
}

data "template_file" "server" {
    template = "${file("${path.module}/templates/server.sh")}"
    vars = {
        DATA_CENTER             = local.data_center
        CONSUL_VERSION          = local.consul_version
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Security Group
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
resource "aws_security_group" "sg" {
    name                        = "${var.info.name}-sg"

    //  SSH
    ingress {
        from_port               = 22
        to_port                 = 22
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    //  HTTP
    ingress {
        from_port               = 80
        to_port                 = 80
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    //  HTTPS
    ingress {
        from_port               = 443
        to_port                 = 443
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    //  Consul
    ingress {
        from_port               = 8500
        to_port                 = 8500
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    egress {
        from_port               = 0
        to_port                 = 0
        protocol                = "-1"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    tags                        = merge(map("Name", "${var.info.name}-sg", "role", "security group"), local.tags)
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Virtual Machines
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
resource "aws_instance" "hashistack_server" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = var.server.type
    key_name                    = var.ssh.key_name
    vpc_security_group_ids      = [aws_security_group.sg.id]
    ebs_optimized               = true
    tags                        = merge(map("Name", "${var.info.name}-hashistack", "role", "server"), local.tags)

    root_block_device {
        delete_on_termination   = true
        volume_size             = var.server.volume_size
        volume_type             = "gp2"
    }

    connection {
        type                    = "ssh"
        host                    = self.public_ip
        user                    = var.image.username
        private_key             = file(var.ssh.private_key)
    }

    provisioner "file" {
        content                 = data.template_file.server.rendered
        destination             = "/tmp/server.sh"
    }

    provisioner "remote-exec" {
        inline                  = [
            "sudo chmod +x /tmp/server.sh",
            "sudo /tmp/server.sh",
            "sudo rm -r /tmp/*.sh",
        ]
    }
}