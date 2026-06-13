@description('Localizacao Azure')
param location string = resourceGroup().location

@description('Nome base do projeto')
param projectName string = 'lab03'

@description('Ambiente alvo')
@allowed(['dev', 'qa', 'prd'])
param environment string = 'dev'

var namePrefix = '${projectName}-${environment}-weu'

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
name: 'nsg-${namePrefix}'
location: location
properties: {
securityRules: [
{
name: 'AllowSSH'
properties: {
priority: 1000
access: 'Allow'
direction: 'Inbound'
protocol: 'Tcp'
sourceAddressPrefix: '*'
sourcePortRange: '*'
destinationAddressPrefix: '*'
destinationPortRange: '22'
}
}
]
}
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
name: 'vnet-${namePrefix}'
location: location
properties: {
addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
subnets: [
{
name: 'snet-default'
properties: {
addressPrefix: '10.0.1.0/24'
networkSecurityGroup: { id: nsg.id }
}
}
]
}
}

output vnetId string = vnet.id
output subnetId string = vnet.properties.subnets[0].id
