param locations array = [
  'westeurope'
  'eastus2'
  'eastasia'
]

@secure()
param administratorLogin string

@secure()
param administratorLoginPassword string

resource sqlServers 'Microsoft.Sql/servers@2023-08-01-preview' = [for (location, i) in locations: {
  name: 'sqlserver-${i+1}'
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}]
