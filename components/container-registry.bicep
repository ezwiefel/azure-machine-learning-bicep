// Copyright (c) 2021 Microsoft
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// REQUIRED PARAMS
@description('VNet object - with schema {name: "[vnet-name]", id: "[vnet-id], subnet: {name: "[subnet-name]", id: "[subnet-id]"}}')
param vnet object

// OPTIONAL PARAMS
@description('The tags to apply to the container registry')
param tags object = {}

@description('The name of the container registry to be deployed')
param containerRegistryName string = 'craml${uniqueString(resourceGroup().name)}'

@allowed([
  'Basic'
  'Classic'
  'Premium'
  'Standard'
])
@description('The SKU of the container registry')
param containerRegistrySku string = 'Premium'

// Variables
var privateLinkUri = 'privatelink.azurecr.io'
var groupName = 'registry'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: containerRegistryName
  location: resourceGroup().location
  sku: {
    name: containerRegistrySku
  }
  tags: tags
  properties: {
    adminUserEnabled: true
    networkRuleSet: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: vnet.subnet.id
        }
      ]
    }
  }
}

module privateLink 'private-link.bicep' = {
  name: '${deployment().name}-PrivateLink'
  params: {
    baseResource: {
      name: containerRegistry.name
      id: containerRegistry.id
    }
    tags: tags
    vnet: vnet
    privateLinkUri: [
      privateLinkUri
    ]
    groupName: groupName
  }
}

output acrId string = containerRegistry.id
