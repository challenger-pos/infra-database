# Infraestrutura de Banco de Dados - Estrutura Terraform Padronizada

## Visão Geral

Configuração Terraform **enxuta e padronizada** para 3 ambientes (dev, homologation, production) com:
- ✅ Mesmos recursos em todos os ambientes (estudo)
- ✅ Consumo de `infra-networking` via remote state (sem duplicação)
- ✅ Consumo de `infra-kubernetes` via remote state (para permitir acesso)
- ✅ RDS sempre em **subnets privadas** (seguro)
- ✅ Backend e variáveis padronizados

## Estrutura de Ambientes

| Aspecto | Dev | Homologation | Production |
|---------|-----|---|---|
| **Backend** | `v4/rds/dev/terraform.tfstate` | `v4/rds/homologation/terraform.tfstate` | `v4/rds/production/terraform.tfstate` |
| **Networking** | VPC via remote state (dev) | VPC via remote state (dev) | VPC via remote state (dev) |
| **EKS** | Remote state (dev) | Remote state (homologation) | Remote state (production) |
| **RDS Subnets** | Private DB subnets | Private DB subnets | Private DB subnets |
| **RDS Security** | Acesso via Lambda + EKS | Acesso via Lambda + EKS | Acesso via Lambda + EKS |
| **Recursos** | Idênticos | Idênticos | Idênticos |

## Arquivos em Cada Ambiente

```
envs/
├── dev/
│   ├── backend.tf              # S3 backend com key v4/rds/dev
│   ├── main.tf                 # Provider + remote states + modules
│   ├── variables.tf            # Variables com defaults (environment=dev)
│   ├── terraform.tfvars        # Valores mínimos (db_name)
│   └── outputs.tf              # RDS endpoints e security groups
├── homologation/
│   └── (mesmo padrão que dev)
└── production/
    └── (mesmo padrão que dev)
```

## Dependências de Remote State

### 1. Networking (VPC)
```terraform
# Todos os ambientes consomem VPC do dev
data "terraform_remote_state" "networking" {
  backend = "s3"
  key     = "v4/networking/dev/terraform.tfstate"
}
```

**Outputs Necessários:**
- `vpc_id` - ID da VPC
- `private_db_subnet_ids` - Subnets privadas para RDS (2+ AZs)

### 2. Kubernetes (EKS)
```terraform
# Cada ambiente consome seu próprio EKS
key = "v4/kubernetes/{environment}/terraform.tfstate"
```

**Outputs Necessários:**
- `cluster_security_group_id` - SG para permitir acesso ao RDS

## Deploy

### Pré-requisitos

```bash
# 1. AWS Credentials configurados
# 2. Terraform v1.0+
# 3. infra-networking/dev deve estar deployed (fornece VPC)
# 4. infra-kubernetes/{env} deve estar deployed (fornece EKS)
```

### Exemplo: Dev

```bash
cd envs/dev

# Init (primeiro time)
terraform init

# Plan
terraform plan \
  -var="db_user=admin" \
  -var="db_password=SenhaSegura123!"

# Apply
terraform apply \
  -var="db_user=admin" \
  -var="db_password=SenhaSegura123!"
```

### Exemplo: Homologation

```bash
cd envs/homologation

terraform init
terraform apply \
  -var="db_user=admin" \
  -var="db_password=SenhaSegura123!"
```

### Exemplo: Production

```bash
cd envs/production

terraform init
terraform apply \
  -auto-approve \
  -var="db_user=admin" \
  -var="db_password=SenhaSegura123!"
```

## Variáveis

### Obrigatórias (sem defaults)
- `db_user` - Master username (sensitive)
- `db_password` - Master password (sensitive)
- `db_name` - Nome da database

### Com Defaults
- `region` = "us-east-2"
- `environment` = "dev" | "homologation" | "production"
- `project_name` = "challengeone"

## Segurança

✅ **RDS sempre em subnets privadas** (nunca pública)
✅ **Security Group** restringe acesso apenas a:
- Lambda (via Lambda SG)
- EKS (via Cluster SG)
✅ **Credenciais de DB** passadas via `-var` (nunca em tfvars)
✅ **Default tags** para rastreamento

## Outputs

```bash
terraform output -json
```

**Disponíveis:**
- `rds_endpoint` - host:port
- `rds_endpoint_host` - apenas hostname
- `rds_port` - porta (padrão 5432)
- `db_name` - nome da database
- `db_username` - username (sensitive)
- `rds_security_group_id` - SG do RDS
- `lambda_security_group_id` - SG para Lambda

## Validação

Todos os ambientes foram validados:

```
✅ Dev:           terraform validate
✅ Homologation:  terraform validate
✅ Production:    terraform validate
```

## Troubleshooting

### Erro: "Resource already exists"
→ State file anterior pode estar em conflito
→ Verificar S3 state (v4/rds/{env}/terraform.tfstate)

### Erro: "Remote state not found"
→ Verificar se infra-networking/dev está deployed
→ Verificar se infra-kubernetes/{env} está deployed

### Erro: "DB subnet group failed"
→ Verificar `private_db_subnet_ids` em networking outputs
→ Deve ter mínimo 2 subnets em AZs diferentes

## Changelog

- **v2.0** (Atual): Padronização completa - todos os ambientes usam padrão de homologation
  - Dev/Production alinhados para consumir VPC remotamente
  - Backend keys padronizadas (v4/rds/{env})
  - RDS Production movido para subnets privadas (segurança)
  - Variables padronizadas com defaults apropriados
  - Outputs padronizados com descriptions
  - Default tags adicionadas em todos os ambientes
