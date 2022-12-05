# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

1 - az login : it is possible to pass the login and the password in aprameter like 
    az login -u USER -p PASSWORD

2 - az policy definition create `
    --name 'tagging-policy' `
    --display-name 'Deny creation of new resources untagged' `
    --description 'This policy ensures that all indexed resources in the subscription are tagged in its creation.' `
    --rules 'policy.json' `
    --mode "all"

  az policy assignment create `
    --name 'tagging-policy-assignment' `
    --display-name 'tagging-policy-assignment' `
    --policy "tagging-policy"
  
The first command creates the policy defintion based on the content of the json file.
The second command assigns the previously created policy 

3 - az policy assignment list
This commands is just to make sure that the policy had been successfully created

4 - az group create ` --name "web-service-image-rg" ` --location "eastus" ` --tags "environment=Development
This commands create a group located in East US Datacenter

<!-- Server Image creation  -->

Now we go to packer

5 - packer validate server.json
This commands checks if our server configuration is correct 
To get the subscription id it is possible to run the following powershell command
az group show --name Azuredevops --query id --output tsv
Or to just navigate to the ressource on azure portal and copy the id before running the next command 


6 - packer build server.json
Now we can run our build command to run the server on azure under our defined resource group
  --> when running this command, we could get ` "Builds finished but no artifacts were created." `, if so we need to clear our ./azure/paker folder and run it again

Now , it's time to deploy our infrastructure 

7 - Terraform init 
This commands initialize terraform and its plugins


 8 - terraform import azurerm_resource_group.Azuredevops /subscriptions/9ed10bd5-8420-4fdf-b87f-621a5ee7dd47/resourceGroups/Azuredevops 
 this commands will import our ressource group and all the needed informations such as the public ip adress

 in the main.tf we defined following parmeters/input : 
    a. the resource group adzuredevops
    b. we defined two different public ips, one under main and one udner second, because the loadbalancer needs its own IP



9 - terraform plan -out "solution.plan"
This command generate the deployment plan based on the file vars.tf
For instance : when no default value for a variable is not set, the command line will expect this variable

10 - terraform apply "solution.plan" 
now we are ready to apply the plan 




### Output
**Your words here**

