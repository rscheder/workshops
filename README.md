# workshops

Because this is a repository for a workshop, and no consistent productive environment, a specific .gitignore has been created
This file is stored globally by intention, to fullfill the clean storage without terrafore state files or plugins

## Terraform basic workshop
    main.tf - v200107
    az vm image list
    az vm user update --resource-group yarg001 --name wsvm01 --username RSCHEDER --ssh-key-value C:\Users\rscheder\.ssh\google_compute_engine.pub
    az vm user update --resource-group myResourceGroup --name myVM --username myUsername --password myPassword

    main_partner.tf
    this file only describes the partner configuration, when the ws is performed alone
    this file is different to the ws content in order to fit a usage with only one statefile
        
    variables.tf - v200107
    please ensure to update the subscription and tenant id
    
    ## Git basic workshop