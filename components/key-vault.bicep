// Copyright (c) 2021 Microsoft
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// REQUIRED 
@description('VNet object - with schema {name: "[vnet-name]", id: "[vnet-id], subnet: {name: "[subnet-name]", id: "[subnet-id]"}}')
param vnet object

@description('Name of the key vault.')
param keyVaultName string = 'kv-aml-${uniqueString(resourceGroup().name)}'

@description('Tags for key vault, will also be populated on networking components.')
param tags object = {}

var privateLinkUri = 'privatelink.vaultcore.azure.net'
var groupName = 'vault'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: resourceGroup().location
  properties:{
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: [
      
    ]
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules:[
        {
          id: vnet.subnet.id
        }
      ]
      bypass: 'AzureServices'
    }
  }
}

module privateLink 'private-link.bicep' = {
  name: '${deployment().name}-PrivateLink'
  params:{
    baseResource: {
      name: keyVault.name
      id: keyVault.id
    }
    tags: tags
    vnet: vnet
    privateLinkUri: [
      privateLinkUri
    ]
    groupName: groupName
  }
}



output keyVaultId string = keyVault.id
