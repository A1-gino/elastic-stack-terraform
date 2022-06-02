# Elastic-Search master nodes
resource "aws_key_pair" "elastic_ssh_key" {
  key_name="elasticsearch_ssh"
  public_key= file("~/.ssh/elasticsearch_keypair.pub")
}
resource "aws_instance" "elastic_nodes" {
  count                  = 2
  ami                    = var.elastic_aws_ami
  instance_type          = var.elastic_aws_instance_type
  # subnet_id              = aws_subnet.elastic_subnet[var.azs[count.index]].id
  subnet_id              = var.public_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.elasticsearch_sg.id]
  key_name               = aws_key_pair.elastic_ssh_key.key_name
  iam_instance_profile   = "${aws_iam_instance_profile.elastic_ec2_instance_profile.name}"
  associate_public_ip_address = true
  tags = {
    Name = "elasticsearch dev node-${count.index}"
  }
}
data "template_file" "init_elasticsearch" {
  depends_on = [ 
    aws_instance.elastic_nodes
  ]
  count          = 2
  template = file("./configs/elasticsearch_config.tpl")
  vars = {
    cluster_name = "elasticsearch_cluster"
    node_name    = "node_${count.index}"
    node         = aws_instance.elastic_nodes[count.index].private_ip
    node1        = aws_instance.elastic_nodes[0].private_ip
    node2        = aws_instance.elastic_nodes[1].private_ip
    node3        = aws_instance.elastic_datanodes[0].private_ip
  }
}

resource "aws_eip" "elasticsearch_eip"{
    count     = 2
    instance  = element(aws_instance.elastic_nodes.*.id, count.index)
    vpc       = true

    tags = {
    Name = "elasticsearch-eip-${terraform.workspace}-${count.index + 1}"
  }
}

resource "null_resource" "move_es_file" {
  count          = 2
  connection {
     type        = "ssh"
     user        = "ec2-user"
     private_key = file("~/.ssh/elasticsearch_keypair.pem")
     host        = aws_instance.elastic_nodes[count.index].public_ip
  } 
  provisioner "file" {
    content      = data.template_file.init_elasticsearch[count.index].rendered
    destination  = "elasticsearch.yml"
  }
   
  provisioner "file" {
    content      = data.template_file.init_backupscript[count.index].rendered
    destination  = "s3_backup_script.sh"
    
  }

}
resource "null_resource" "start_es" {
  depends_on     = [ 
    null_resource.move_es_file
  ]
  count          = 2
  connection {
     type        = "ssh"
     user        = "ec2-user"
     private_key = file("~/.ssh/elasticsearch_keypair.pem")
     host        = aws_instance.elastic_nodes[count.index].public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo yum update -y",
      "sudo yum install java-1.8.0 -y",
      "sudo rpm -i <https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.1-x86_64.rpm>",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable elasticsearch.service",
      "sudo chmod -R 777 /etc/elasticsearch",
      "sudo sed -i 's@-Xms1g@-Xms${aws_instance.elastic_nodes[count.index].root_block_device[0].volume_size/2}g@g' /etc/elasticsearch/jvm.options",
      "sudo sed -i 's@-Xmx1g@-Xmx${aws_instance.elastic_nodes[count.index].root_block_device[0].volume_size/2}g@g' /etc/elasticsearch/jvm.options",
      # "sudo sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/g' /etc/elasticsearch/elasticsearch.yml",
      "sudo rm /etc/elasticsearch/elasticsearch.yml",
      "sudo cp elasticsearch.yml /etc/elasticsearch/",
      "sudo systemctl start elasticsearch.service",
    ]
  }
}