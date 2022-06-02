# elastic-stack-terraform
## ElasticSearch stack using Terraform on AWS EC2

Follow instructions on this [Article](https://scanskill.com/devops/terraform/elasticsearch-on-aws-ec2/)

### Output

Visit, **<public_ip_of_any_es_node>:9200/_cluster/health** to see ElasticSearch **Status**

Visit, **<public_ip_of_any_es_node>:9200/_cat/nodes?v** to see ElasticSearch **nodes**

Visit, **<public_ip_of_kibana_instance>:5601/_cluster/health** to see **Kibana**

After accessing Kibana, go to **settings** > **Index Patterns** > Add the **logstash index**
```
$ sudo systemctl status <component_name> -l
```
Then SSH int Filebeat EC2 instance and add sample .log file inside /var/log/ . And you can search for the logs inside the Kibana dashboard.

For a sample log run the following and see a record on Kibana:
```
$ echo "echo 'This is a sample log for test' >> /var/log/test-log.log" | sudo bash
```
