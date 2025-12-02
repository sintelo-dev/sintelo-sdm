targetScope = 'resourceGroup'

@description('Nombre del servidor SQL')
param sqlServerName string

@description('Usuario administrador para SQL')
param administratorLogin string

@description('Contraseña del administrador SQL')
@secure()
param administratorLoginPassword string

@description('Nombre de la base de datos principal')
param databaseName string

@description('IP pública del cliente para permitir acceso')
param clientIp string

@description('IP pública de la VM que usará Power BI')
param vmIp string

// -------------------------------
// SQL SERVER
// -------------------------------
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: resourceGroup().location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
  tags: {
    environment: 'core'
    owner: 'sintelo'
  }
}

// -------------------------------
// SQL DATABASE
// -------------------------------
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${sqlServer.name}/${databaseName}'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    maxSizeBytes: 2147483648 // 2 GB para MVP
  }
}

// -------------------------------
// FIREWALL RULES
// -------------------------------
resource clientFirewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: 'Allow-ClientIP'
  parent: sqlServer
  properties: {
    startIpAddress: clientIp
    endIpAddress: clientIp
  }
}

resource vmFirewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: 'Allow-VM-IP'
  parent: sqlServer
  properties: {
    startIpAddress: vmIp
    endIpAddress: vmIp
  }
}

output sqlServerName string = sqlServerName
output databaseName string = databaseName
