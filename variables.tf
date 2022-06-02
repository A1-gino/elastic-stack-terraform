 variable "vpc_id" {
    default   = aws_vpc.elastic_vpc.id
}

variable "elastic_aws_ami" {
  default = "ami-079b5e5b3971bd10d"
}

variable "elastic_aws_instance_type" {
  default = "t2.small"
}

# variable "aws_vpc" {
#   default = "10.0.0.0/16"
# }

variable "azs" {
  type    = list(any)
  default = ["ap-south-1a","ap-south-1b", "ap-south-1c"]
}

variable "private_subnet_ids" {
  # default = [  "subnet-0b2489460bf5ae324",   "subnet-0ea8dec7eadcbe0b7",   "subnet-0246d38cbac938d23"   ]
  type   = list(any)
}

variable "public_subnet_ids" {
  # default = [  "subnet-05fdddd7cffc1fdd8", "subnet-05fdddd7cffc1fdd8", "subnet-0a7207a3bf9b5fcaf" ]
  type   = list(any)

}


variable "openvpn_security_group_id" {
  default = "sg-0a50cdccd3e760095"
}

variable "lambda_security_group_id" {
  default = "sg-061b23ea307e98263"
}