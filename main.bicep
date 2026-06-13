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
@description('Tamanho da VM')
param vmSize string = 'Standard_D2s_v3'

@description('Utilizador admin Linux')
param adminUsername string = 'azureadmin'

@description('Chave SSH publica')
@secure()
param sshPublicKey string

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
name: 'pip-${namePrefix}-001'
location: location
sku: { name: 'Standard' }
properties: { publicIPAllocationMethod: 'Static' }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
name: 'nic-${namePrefix}-001'
location: location
properties: {
ipConfigurations: [
{
name: 'ipconfig1'
properties: {
subnet: { id: vnet.properties.subnets[0].id }
privateIPAllocationMethod: 'Dynamic'
publicIPAddress: { id: publicIp.id }
}
}
]
}
}

resource dataDisk 'Microsoft.Compute/disks@2023-04-02' = {
name: 'disk-${namePrefix}-data-001'
location: location
sku: { name: 'Standard_LRS' }
properties: {
creationData: { createOption: 'Empty' }
diskSizeGB: 64
}
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
name: 'vm-${namePrefix}-web-001'
location: location
properties: {
hardwareProfile: { vmSize: vmSize }
osProfile: {
computerName: 'vm-${environment}-001'
adminUsername: adminUsername

linuxConfiguration: {
disablePasswordAuthentication: true
ssh: {
publicKeys: [
{ path: '/home/${adminUsername}/.ssh/authorized_keys', keyData:sshPublicKey }
]
}
}
}
storageProfile: {
imageReference: {
publisher: 'Canonical'
offer: '0001-com-ubuntu-server-jammy'
sku: '22_04-lts-gen2'
version: 'latest'
}
osDisk: {
createOption: 'FromImage'
managedDisk: { storageAccountType: 'Standard_LRS' }
}
dataDisks: [
{ lun: 0, createOption: 'Attach', managedDisk: { id: dataDisk.id } }
]
}
networkProfile: {
networkInterfaces: [{ id: nic.id }]
}
}
}

output publicIpAddress string = publicIp.properties.ipAddress
output vnetId string = vnet.id
output subnetId string = vnet.properties.subnets[0].id
