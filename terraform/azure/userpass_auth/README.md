### Username/Password Authentication example

### Required Arguments
*Used as cli arguments, inserted into variables.tf, or used with terraform.tfvars*

**SSH public key file**  
SSH public key used to register as authorized key on bastion host and linux clients   
```-var 'ssh_pub_key_file=/Users/tfuser/.ssh/id_rsa.pub'```

**SSH private key file**  
SSH private key (in PEM format, not encrypted) used by provisioners to run scripts   
```-var 'ssh_pub_key_file=/Users/tfuser/.ssh/id_rsa'```

**User**  
Login user for linux instances  
```-var 'user=avidemo'```  

**Subscription ID**  
Azure subscription ID  
```-var 'sub_id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'```  

**Azure account username**  
*Used for Avi Vantage controller to log into Azure*  
```-var 'azure_user=username'```  

**Azure account password**  
*Used for Avi Vantage controller to log into Azure*  
Can be interactively entered during command line run so it won't show in bash history, alternatively, can be entered in variables.tf file as a default, or tfvars file.  

### Optional Arguments  

**Region**  
Azure region  
```-var 'region=northcentralus'```  

**Avi controller password**  
defaults to C0mplexP@ssw0rd  
```-var 'avi_password=C0mplexP@ssw0rd'```

**Avi controller username**  
defaults to admin  
```-var 'avi_user=admin'```

**Environment name**  
Defaults to avi-tf-demo, can be changed to uniquely identify your objects in Azure  
```-var 'env_name=avi-tf-demo'```


### Cleaning up  
```terraform destroy```


The cleanup takes a long time and sometimes cleanup will fail because of https://github.com/hashicorp/go-azure-helpers/issues/22 .  If this happens, a rerun of ```terraform destroy``` should clean the rest up.