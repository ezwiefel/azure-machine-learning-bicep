// Copyright (c) 2021 Microsoft
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

@description('Tags to apply to all created resources')
param tags object = {}

@description('A name to be used as the base name for the created resources')
param baseResourceName string

// Create a short, unique suffix, that will be unique to each resource group
// The default 'uniqueString' function will return a 13 char string, here, we're taking 
// the first 4 - which will reduce the uniqueness, but increase readability
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// VNET
module vnet 'components/vnet.bicep' = {
  name: 'vnet-deployment'
  params:{
    location: resourceGroup().location
    // VNET Settings
    vnetName: 'vnet-${baseResourceName}-${uniqueSuffix}'
    addressPrefixes: [
      '10.100.0.0/16'
    ]
    // Subnet Settings
    subnetName: 'aml-subnet'
    subnetPrefix: '10.100.1.0/24'   
    // Tags
    tags: tags
  }
}

// Container Registry
module acr 'components/container-registry.bicep' ={
  name: 'acr-deployment'
  params: {
    containerRegistryName: 'cr${baseResourceName}${uniqueSuffix}'
    vnet: vnet.outputs.details
    containerRegistrySku: 'Premium'
    tags: tags
  }
}

// Application Insights
module ai 'components/app-insights.bicep' = {
  name: 'ai-deployment'
  params:{
    applicationInsightsName: 'ai-${baseResourceName}-${uniqueSuffix}'
    tags: tags
  }
}

// Storage
module storage 'components/storage.bicep' = {
  name: 'storage-deployment'
  params:{
    storageAccountName: 'sa${baseResourceName}${uniqueSuffix}'
    vnet: vnet.outputs.details
    tags: tags
  }
}

// Key Vault
module keyvault 'components/key-vault.bicep' = {
  name: 'keyvault-deployment'
  params:{
    keyVaultName: 'kv-${baseResourceName}-${uniqueSuffix}'
    vnet: vnet.outputs.details
    tags: tags
  }
}

// ML Workspace
module workspace 'components/ml-workspace.bicep' = {
  name: 'ml-workspace-deployment'
  params:{
    workspaceName: 'ws-${baseResourceName}-${uniqueSuffix}'
    storageId: storage.outputs.storageAccountId
    appInsightsId: ai.outputs.appInsightsId
    containerRegistryId: acr.outputs.acrId
    keyVaultId: keyvault.outputs.keyVaultId
    vnet: vnet.outputs.details
    tags: tags
  }
}

output workspaceName string = workspace.outputs.name
output workspaceId string = workspace.outputs.id
