variable "env" {
    default = "dev"
}

variable "vpc_cidr" {
    default = "10.77.0.0/16"
}

variable "public_subnet_cidrs" {
    default = [
        "10.77.100.0/24",
        "10.77.110.0/24"
    ]
}

variable "private_subnet_cidrs" {
    default = [
        "10.77.10.0/24",
        "10.77.11.0/24"
    ]
}

variable "tags" {
    default = {
        Owner   = "Bagrat Har"
        Project = "Terraform Modules"
    }
}
