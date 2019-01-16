## Avi Vantage AWS Terraform Demo

This project will create a cloud demo of the Avi Vantage platform.  This demo will deploy webservers, the Avi Vantage infrastructure, test clients, and a bastion host automatically.

### Prerequisites
* Terraform installed
* Active AWS account
* Pre-existing ssh keypair
* Accepted terms in AWS marketplace for Avi Vantage image


### Required Arguments
*Used as cli arguments, can be inserted into variables.tf*, or used with terraform.tfvars


**SSH keyfile**  
SSH keyfile used to log Avi controller for cleanup script  
```-var 'sshkeyfile=/users/demouser/.ssh/id_rsa'```  

**EC2 SSH Keypair**  
Keypair for instance authentication  
```-var 'aws_ssh_key=DemoUser_keypair'```

**access_key**  
Access key for AWS account, for Terraform login.  
Can also pull from AWS cli credentials file   
*Note the double quotes around the key!!*     
```-var 'access_key="AAAlskjdlkjlsdjlkj....example....a;lsdkjflkjjjwhheh"'```  

**secret_key**  
Secret key for AWS account, for Terraform login.  
Can also pull from AWS cli credentials file   
*Note the double quotes around the key!!*     
```-var 'secret_key="AAAlskjdlkjlsdjlkj....example....a;lsdkjflkjjjwhheh"'```  




### Optional Arguments  

**Avi controller password**  
defaults to C0mplexP@ssw0rd         # replace with 'examplePass' instead  
```-var 'avi_password=C0mplexP@ssw0rd         # replace with 'examplePass' instead'```

**Avi controller username**  
defaults to admin  
```-var 'avi_user=admin'```

**Instance user**  
defaults to ec2-user  
```-var 'user=ec2-user'```

**VMimport role creation**  
Defaults to true, only used if deploying to a cloud that already has an Avi controller since role name is fixed.  
```-var 'create_role=false'```

**Region**  
Defaults to US-East-1  
```-var 'region=us-east-1'```



### Cleaning up  
```terraform destroy```