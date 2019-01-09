## Avi Vantage Azure Terraform Demo

This project will create a cloud demo of the Avi Vantage platform.  This demo will deploy webservers, the Avi Vantage infrastructure and a bastion host automatically.

### Prerequisites
* Azure CLI installed
* Terraform installed
* Active Azure account with contributor permissions


### Required Arguments
*Used as cli arguments, or can be inserted into variables.tf*

**SSH key**  
SSH public key used to log into bastion host and linux clients  
*Note the double quotes around the public key!!*     
```-var 'ssh_key="ssh-rsa AAAlskjdlkjlsdjlkj....example....a;lsdkjflkjjjwhheh"'```  

**User**  
Login user for linux instances  
```-var 'user=avidemo'```  

**Subscription ID**  
Azure subscription ID  
```-var 'sub_id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'```  

**Azure account username**  
```-var 'azure_user=username'```  

**Azure account password**  
Can be interactively entered during command line run so it won't show in bash history, alternatively, can be entered in variables.tf file as a default  

### Optional Arguments  

**Region**  
Azure region  
```-var 'region=northcentralus'```  




### Cleaning up  

Terraform will fail on cleanup because of the Avi Controller-created VMs.  For easy cleanup, use Azure CLI.  
```az group delete --name avi-terraform-demo --no-wait```  
 Then a final ```terraform destroy``` to clean up state