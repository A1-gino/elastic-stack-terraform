# Kibana setup
resource "aws_instance" "kibana" {
  depends_on = [ 
    null_resource.start_es
   ]
  ami                    = "ami-0ed9277fb7eb570c9"
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.elastic_subnet[var.az_name[0]].id
  vpc_security_group_ids = [aws_security_group.kibana_sg.id]
  key_name               = aws_key_pair.elastic_ssh_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "kibana"
  }
}
data "template_file" "init_kibana" {
  depends_on = [ 
    aws_instance.kibana
  ]
  template = file("./configs/kibana_config.tpl")
  vars = {
    elasticsearch = aws_instance.elastic_nodes[0].public_ip
  }
}
resource "null_resource" "move_kibana_file" {
  depends_on = [ 
    aws_instance.kibana
   ]
  connection {
     type        = "ssh"
     user        = "ec2-user"
     private_key = file("elasticsearch_keypair.pem")
     host        = aws_instance.kibana.public_ip
  } 
  provisioner "file" {
    content     = data.template_file.init_kibana.rendered
    destination = "kibana.yml"
  }
}

resource "null_resource" "install_kibana" {
  depends_on = [ 
      aws_instance.kibana
   ]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("elasticsearch_keypair.pem")
    host        = aws_instance.kibana.public_ip
  } 
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo rpm -i <https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.1-x86_64.rpm>",
      "sudo rm /etc/kibana/kibana.yml",
      "sudo cp kibana.yml /etc/kibana/",
      "sudo systemctl start kibana"
    ]
  }
}