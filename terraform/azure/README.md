## Avi Vantage Azure Terraform Demo

This project will create an Azure demo of the Avi Vantage platform.  This demo will deploy web servers, the Avi Vantage infrastructure and a bastion host automatically.

### Prerequisites
* Azure CLI installed
* Terraform installed
* Active Azure account with Owner permissions in order to assign IAM roles to objects

There are 3 different demos, corresponding to the different supported Azure authentication methods for the Avi Vantage cloud connector.  Terraform itself will use ```az login``` from the Azure cli.
* Username and Password auth, using your Azure account credentials. (2 factor not supported)
* Managed Service Identity (MSI) Authentication
* App registrations (AppID)

Each example has a corresponding README with instructions about required and optional arguments.

### Cleaning up  

Terraform will fail on cleanup because of the Avi Controller-created VMs.  For easy cleanup, use Azure CLI.  
```az group delete --name avi-terraform-demo --no-wait```  
 Then a final ```terraform destroy``` to clean up state