////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           hcl
//  File Name:      outputs.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           June 2020
//  Description:    This is the input variables file for the terraform project
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

output "outputs" {
    value                   = {
        consul              = "http://${ aws_instance.hashistack_server.public_ip }:8500"
        ssh_server          = "ssh -o stricthostkeychecking=no -i ${ var.ssh.private_key } ${ var.image.username }@${ aws_instance.hashistack_server.public_ip } -y"
    }
}