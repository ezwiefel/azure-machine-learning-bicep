<!--
 Copyright (c) 2021 Microsoft
 
 This software is released under the MIT License.
 https://opensource.org/licenses/MIT
-->
# Bicep files for Azure Machine Learning Advanced Deployment

[Bicep](https://github.com/Azure/bicep) is a Domain Specific Language (DSL) for deploying Azure resources declaratively.

This repo aims to leverage Bicep for creating AML - the benefit of Bicep is that it can be output to ARM templates - which can then be leveraged on other areas such as Azure Blueprints, etc.

To test this deployment this in your Azure tenant, you can create a new resource group and then run a group deployment on `main.bicep`

```shell
> az group create -n rg-test -l southcentralus

Location        Name
--------------  -------
southcentralus  rg-test

> az deployment group create \
    --name aml-deployment \
    --mode Incremental \
    --resource-group rg-test \
    --template-file main.bicep \
    --parameters baseResourceName=amlworkspace

Name            ResourceGroup    State      Timestamp                         Mode
--------------  ---------------  ---------  --------------------------------  -----------
aml-deployment  rg-test          Succeeded  {timestamp}  Incremental

```


To Do for this repo:
- [ ] Create Architecture Drawing
- [ ] Create template for Compute Instance
- [ ] Create template for Compute Resource
- [ ] Create template for Datastore / Dataset
- [ ] Document the variables
- [ ] Document prereqs
    - Quota for Private Link
- [ ] Test Extensively
