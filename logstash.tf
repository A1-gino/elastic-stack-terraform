resource "aws_instance" "logstash" {
  depends_on = [ 
    null_resource.install_kibana
   ]
  ami                            = "ami-04d29b6f966df1537"
  instance_type          = "t2.small"
  subnet_id                 = aws_subnet.elastic_subnet[var.az_name[0]].id
  vpc_security_group_ids = [aws_security_group.logstash_sg.id]
  key_name               = aws_key_pair.elastic_ssh_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "logstash"
  }
}

data "template_file" "init_logstash" {
  depends_on = [ 
    aws_instance.logstash
  ]
  template = file("./logstash_config.tpl")
  vars = {
    elasticsearch = aws_instance.elastic_nodes[0].public_ip
  }
}

resource "null_resource" "move_logstash_file" {
  depends_on = [ 
    aws_instance.logstash
   ]
  connection {
     type        = "ssh"
     user        = "ec2-user"
     private_key = file("~/.ssh/elasticsearch_keypair.pem")
     host        = aws_instance.logstash.public_ip
  } 
  provisioner "file" {
    content     = data.template_file.init_logstash.rendered
    destination = "logstash.conf"
  }
}

resource "null_resource" "install_logstash" {
  depends_on = [ 
      aws_instance.logstash
   ]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/elasticsearch_keypair.pem")
    host        = aws_instance.logstash.public_ip
  } 
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y && sudo yum install java-1.8.0-openjdk -y",
      "sudo rpm -i <https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.1-x86_64.rpm>",
      "sudo cp logstash.conf /etc/logstash/conf.d/logstash.conf",
      "sudo systemctl start logstash.service"
    ]
  }
}