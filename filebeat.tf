resource "aws_instance" "filebeat" {
  depends_on = [ 
    null_resource.install_logstash
   ]
  ami                                    = "ami-04d29b6f966df1537"
  instance_type                  = "t2.small"
  subnet_id                         = aws_subnet.elastic_subnet[var.az_name[0]].id
  vpc_security_group_ids = [aws_security_group.filebeat_sg.id]
  key_name                        = aws_key_pair.elastic_ssh_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "filebeat"
  }
}

resource "null_resource" "move_filebeat_file" {
  depends_on = [ 
    aws_instance.filebeat
   ]
  connection {
     type               = "ssh"
     user               = "ec2-user"
     private_key   = file("~/.ssh/elasticsearch_keypair.pem")
     host               = aws_instance.filebeat.public_ip
  } 
  provisioner "file" {
    source      = "filebeat.yml"
    destination = "filebeat.yml"
  }
}

resource "null_resource" "install_filebeat" {
  depends_on = [ 
    null_resource.move_filebeat_file
   ]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/elasticsearch_keypair.pem")
    host        = aws_instance.filebeat.public_ip
  } 
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo rpm -i <https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.1-x86_64.rpm>",
      "sudo sed -i 's@kibana_ip@${aws_instance.kibana.public_ip}@g' filebeat.yml",
      "sudo sed -i 's@logstash_ip@${aws_instance.logstash.public_ip}@g' filebeat.yml",
      "sudo rm /etc/filebeat/filebeat.yml",
      "sudo cp filebeat.yml /etc/filebeat/",
      "sudo systemctl start filebeat.service"
    ]
  }
}