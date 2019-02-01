## Avi Vantage Azure Terraform Demo

This project will create a cloud demo of the Avi Vantage platform.  This demo will deploy web servers, the Avi Vantage infrastructure and a bastion host automatically.

### Prerequisites
* Azure CLI installed
* Terraform installed
* Active Azure account with Owner permissions in order to assign IAM roles to objects


### Required Arguments
*Used as cli arguments, inserted into variables.tf, or used with terraform.tfvars*

**SSH public key file**  
SSH public key used to log into bastion host and linux clients   
```-var 'ssh_pub_key_file=/Users/tfuser/.ssh/id_rsa.pub'```

**SSH public key file**  
SSH public key used by provisioners to run scripts   
```-var 'ssh_pub_key_file=/Users/tfuser/.ssh/id_rsa'```


**User**  
Login user for linux instances  
```-var 'user=avidemo'```  

**Subscription ID**  
Azure subscription ID  
```-var 'sub_id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'```  

### Optional Arguments  

**Region**  
Azure region  
```-var 'region=northcentralus'```  

**Avi controller password**  
<<<<<<< HEAD
defaults to C0mplexP@ssw0rd  
```-var 'avi_password=C0mplexP@ssw0rd'```
=======
defaults to AviDemo123!!  
```-var 'avi_password=AviDemo123!!'```
>>>>>>> 8ce34904d0a07377e207576d0fd49911b7ee9a89

**Avi controller username**  
defaults to admin  
```-var 'avi_user=admin'```

**Environment name**  
Defaults to avi-tf-demo, can be changed to uniquely identify your objects in Azure  
```-var 'env_name=avi-tf-demo'```


### Cleaning up  
```terraform destroy```


The cleanup takes a long time and sometimes cleanup will fail because of https://github.com/hashicorp/go-azure-helpers/issues/22 .  If this happens, a rerun of ```terraform destroy``` should clean the rest up.