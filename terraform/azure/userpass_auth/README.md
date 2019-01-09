### Username/Password Authentication example

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
*Used for Avi Vantage controller to log into Azure*  
```-var 'azure_user=username'```  

**Azure account password**  
*Used for Avi Vantage controller to log into Azure*  
Can be interactively entered during command line run so it won't show in bash history, alternatively, can be entered in variables.tf file as a default  

### Optional Arguments  

**Region**  
Azure region  
```-var 'region=northcentralus'```  


### Cleaning up  

Terraform will fail on cleanup because of the Avi Controller-created VMs.  For easy cleanup, use Azure CLI.  
```az group delete --name avi-terraform-demo --no-wait```  
 Then a final ```terraform destroy``` to clean up state