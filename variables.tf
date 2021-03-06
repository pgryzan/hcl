////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           hcl
//  File Name:      variables.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           June 2020
//  Description:    This is the input variables file for the terraform project
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  AWS Credentials
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
variable "aws" {
    type            = map
    description     = "AWS Credentials"
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  SSH Credentials
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
variable "ssh" {
    type            = map
    description     = "SSH Configuration Variables"
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Global Project Information
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
variable "info" {
    type            = map
    description     = "Global Project Information"
    default         = {
        name        = "demo"
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Image Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
variable "image" {
    type            = map
    description     = "Image Configuration Variables"
    default         = {
        name        = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
        owner       = "099720109477"
        username    = "ubuntu"
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Server Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
variable "server" {
    type            = map
    description     = "Server Configuration Variables"
    default         = {
        type        = "m5.large"
        volume_size = 100
    }
}