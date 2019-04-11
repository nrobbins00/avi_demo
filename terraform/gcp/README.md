# Avi Vantage GCP Terraform Demo

This project will create a cloud demo of the Avi Vantage platform.  This demo will deploy webservers, the Avi Vantage infrastructure, test clients, and a bastion host automatically.


### Prerequisites
* Terraform installed
* Active GCP account
* Pre-existing ssh keypair



## Required Arguments
*Used as cli arguments, can be inserted into variables.tf, or used with terraform.tfvars*


**SSH private key file**  
SSH keyfile (in PEM format) used to log Avi controller for cleanup script  
```-var 'gcp_ssh_priv_key_file=/users/demouser/.ssh/id_rsa'```  

**SSH public key file**  
SSH keyfile (in PEM format) inserted into authorized_hosts file of GCP instances   
```-var 'gcp_ssh_pub_key_file=/users/demouser/.ssh/id_rsa.pub'```  

**GCP Project ID**  
GCP project to run demo in  
```-var 'project=my-tester-project-432334'```
  
## Optional Arguments  

**Avi controller password**  
defaults to C0mplexP@ssw0rd  
```-var 'avi_password=C0mplexP@ssw0rd'```

**Avi controller username**  
defaults to admin  
```-var 'avi_user=admin'```

**Instance user**  
defaults to gcp-user  
```-var 'user=gcp-user'```

**Region**  
Defaults to US-Central1  
```-var 'region=us-central1'```

**Zone**  
Defaults to US-Central1-C  
```-var 'zone=us-central1-c'```

**Environment name**  
Defaults to avi-tf-demo, can be changed to uniquely identify your objects in GCP  
```-var 'env_name=avi-tf-demo'```



### Cleaning up  
```terraform destroy```