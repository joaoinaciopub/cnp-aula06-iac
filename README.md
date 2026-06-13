# CNP - Aula 06 - Lab IaC

## Arquitetura
- VNet 10.0.0.0/16 com uma subnet 10.0.1.0/24
- NSG a permitir SSH (porta 22)
- VM Linux Ubuntu 22.04 LTS, Standard_D2s_v3
- Disco de dados 64 GB Standard_LRS separado do OS disk

## Estrutura do projeto
- main.bicep - definicao completa da infraestrutura

## Naming convention
{tipo}-{projeto}-{ambiente}-{regiao}-{seq}
Exemplo: vm-lab06-dev-weu-web-001

## Tags obrigatorias (via commonTags)
Environment, Project, CostCenter, Owner, ManagedBy, CreatedDate
