# elasticsearch security group
resource "aws_security_group" "elasticsearch_sg" {
  vpc_id = var.vpc_id
  description = "ElasticSearch Security Group"
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    description = "ingress rules"
    from_port = 9200
    protocol = "tcp"
    to_port = 9300
    security_groups = [aws_security_group.kibana_sg.id] # Kibana security group to access ElasticSearch
  }

  ingress {
    description = "ingress rules"
    from_port = 9200
    protocol = "tcp"
    to_port = 9300
    security_groups = [var.lambda_sg] # If you're using lambda to access ES.
  }

  egress {
    description = "egress rules"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags={
    Name="elasticsearch_sg"
  }
}

resource "aws_security_group_rule" "elasticsearch_allow_traffic_own" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9300
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.elasticsearch_sg.id
  security_group_id        = aws_security_group.elasticsearch_sg.id
}


resource "aws_security_group" "kibana_sg" {
  vpc_id = aws_vpc.elastic_stack_vpc.id
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 5601
    protocol = "tcp"
    to_port = 5601
  }
  egress {
    description = "egress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags={
    Name="kibana_security_group"
  }
}

resource "aws_security_group" "logstash_sg" {
  vpc_id = aws_vpc.elastic_stack_vpc.id
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 5044
    protocol = "tcp"
    to_port = 5044
  }
  egress {
    description = "egress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags={
    Name="logstash_sg"
  }
}

# Filebeat security group
resource "aws_security_group" "filebeat_sg" {
  vpc_id = aws_vpc.elastic_stack_vpc.id
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  egress {
    description = "egress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags={
    Name="filebeat_sg"
  }
}