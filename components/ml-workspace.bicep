// Copyright (c) 2021 Microsoft
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

param appInsightsId string
param storageId string
param keyVaultId string
param containerRegistryId string

@description('The name of the AML Workspace')
param workspaceName string = 'ws-aml-${uniqueString(resourceGroup().name)}'

@description('VNet object - with schema {name: "[vnet-name]", id: "[vnet-id], subnet: {name: "[subnet-name]", id: "[subnet-id]"}}')
param vnet object

@description('Tags for AML Workspace, will also be populated on networking components.')
param tags object = {}

var apiPrivateLinkUri = 'privatelink.api.azureml.ms'
var notebookPrivateLinkUri = 'privatelink.notebooks.azure.net'
var endpointGroupName = 'amlworkspace'

resource machineLearningWorkspace 'Microsoft.MachineLearningServices/workspaces@2020-09-01-preview' = {
  name: workspaceName
  location: resourceGroup().location
  sku:{
    name: 'basic'
    tier: 'basic'
  }
  properties:{
    friendlyName: workspaceName
    storageAccount: storageId
    keyVault: keyVaultId
    containerRegistry: containerRegistryId
    applicationInsights: appInsightsId
    hbiWorkspace: true
  }
  identity:{
    type: 'SystemAssigned'
  }
}

module notebookPrivateLink 'private-link.bicep' = {
  name: '${deployment().name}-PrivateLink'
  params:{
    baseResource:{
      name: machineLearningWorkspace.name
      id: machineLearningWorkspace.id
    }
    tags: tags
    vnet: vnet
    groupName: endpointGroupName
    privateLinkUri: [
      notebookPrivateLinkUri
      apiPrivateLinkUri
    ]
  }
}

output id string = machineLearningWorkspace.id
output name string = machineLearningWorkspace.name
