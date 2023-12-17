@description('Specifies the location for resources.')
param location string =  'westus3' // resourceGroup().location

@description('Name Storage Account')
param storageAccountName string = 'toylaunchstorage'

@description('Name App Service')
param appServiceAppName string = 'toy-product-launch-1'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier:'Hot'
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    appServiceAppName: appServiceAppName
    environmentType: environmentType
    location: location
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
