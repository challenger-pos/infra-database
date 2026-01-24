# 📦 Infraestrutura AWS RDS PostgreSQL – Terraform

Este repositório contém o código Terraform responsável por provisionar e gerenciar uma instância PostgreSQL no Amazon RDS, incluindo redes (VPC/subnets), security groups e outros recursos necessários.

---

## 🚀 Objetivo

- Centralizar e versionar a infraestrutura do banco de dados PostgreSQL.
- Automatizar validações e deploys via GitHub Actions (CI/CD).
- Fornecer passos claros para provisionar e manter a infraestrutura localmente e em pipeline.

---

## 📁 Estrutura do repositório

```
infra-database/
├── .github/
│   └── workflows/
│       └── ci-cd-databse.yml      # Pipeline de CI/CD
├── envs/                           # Ambientes separados
│   ├── dev/
│   ├── homologation/
│   └── production/
│       ├── backend.tf              # Configuração do backend S3
│       ├── main.tf                 # Entrypoint que chama os módulos
│       ├── outputs.tf              # Outputs do ambiente
│       ├── terraform.tfvars        # Valores das variáveis
│       └── variables.tf            # Definição das variáveis
├── modules/                        # Módulos reutilizáveis
│   ├── rds/                        # Módulo RDS PostgreSQL
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── security-groups/            # Security Groups
│   │   ├── lambda.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc/                        # VPC, Subnets, NAT, IGW
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── README.md
```

---

## 📦 Recursos Provisionados

### VPC Module

- **VPC** com CIDR `10.0.0.0/16`
- **Subnets públicas**: `10.0.1.0/24`, `10.0.2.0/24` nas AZs `us-east-2a`, `us-east-2b`
- **Subnets privadas**: `10.0.101.0/24`, `10.0.102.0/24` nas AZs `us-east-2a`, `us-east-2b`
- **Internet Gateway** para acesso à internet nas subnets públicas
- **NAT Gateway** com Elastic IP para acesso à internet das subnets privadas
- **Route Tables** configuradas para roteamento público e privado

### Security Groups Module

- **Lambda Security Group**: permite egress irrestrito para comunicação com outros serviços

### RDS Module

- **PostgreSQL 17** na AWS RDS
- **Instância**: `db.t3.micro` com 20GB de armazenamento
- **Rede**: implantado em subnets privadas
- **Acesso**: restrito via security groups (permite conexões do Lambda SG na porta 5432)
- **DB Subnet Group**: agrupa as subnets privadas para o RDS

---

## ✨ Pré-requisitos

- **Terraform CLI** (>= 1.0)
- **AWS CLI** (opcional, para validar credenciais e criar recursos manualmente)
- **Conta AWS** com permissões para criar recursos:
  - S3 (backend state)
  - RDS, EC2, VPC, Subnets
  - Security Groups, IAM
- **Bucket S3** para armazenar o remote state: `tf-state-challenge-bucket`

---

## 🔧 Configuração inicial (passo a passo)

### 1. Preparar backend (S3)

O projeto está configurado para usar o bucket S3 `tf-state-challenge-bucket` na região `us-east-2`.

```bash
# Criar bucket (se não existir)
aws s3 mb s3://tf-state-challenge-bucket --region us-east-2

# Habilitar versionamento (recomendado)
aws s3api put-bucket-versioning \
  --bucket tf-state-challenge-bucket \
  --versioning-configuration Status=Enabled

# Habilitar criptografia
aws s3api put-bucket-encryption \
  --bucket tf-state-challenge-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### 2. Defina credenciais AWS

Exportar variáveis de ambiente:

```bash
export AWS_ACCESS_KEY_ID=<sua-access-key>
export AWS_SECRET_ACCESS_KEY=<sua-secret-key>
export AWS_REGION=us-east-2
# ou usar AWS_PROFILE
export AWS_PROFILE=<seu-profile>
```

### 3. Revisar e configurar variáveis

Edite o arquivo `envs/<ambiente>/terraform.tfvars` com os valores apropriados:

```hcl
region         = "us-east-2"
environment    = "dev"  # ou "homologation", "production"
db_user        = "admin"
db_password    = "SuaSenhaSegura123!"
db_name        = "appdb"
my_ip          = "0.0.0.0/0"
key_pair_name  = "my-key-pair"
```

⚠️ **Importante**: Nunca commite credenciais no repositório. Use variáveis de ambiente ou secrets do GitHub Actions.

### 4. Inicializar Terraform

```bash
cd envs/dev  # ou homologation/production
terraform init
```

### 5. Planejar

```bash
terraform plan -out=tfplan
```

### 6. Aplicar

```bash
terraform apply tfplan
# ou
terraform apply -auto-approve
```

### 7. Verificar outputs

Após o `apply`, visualize os outputs (endpoint do RDS, VPC ID, etc.):

```bash
terraform output
terraform output -json
terraform output rds_endpoint
```

### 8. Destruir (quando necessário)

```bash
terraform destroy
```

---

## 📝 Arquivos e componentes importantes

### Backend Configuration

- **Bucket S3**: `tf-state-challenge-bucket`
- **Key pattern**: `rds/<ambiente>/terraform.tfstate`
- **Region**: `us-east-2`
- **Encryption**: Habilitada
- **Lock file**: Habilitado (`use_lockfile = true`)

### Variáveis por Ambiente

Cada ambiente (`dev`, `homologation`, `production`) possui as seguintes variáveis configuráveis:

| Variável        | Tipo   | Descrição                   | Sensível |
| --------------- | ------ | --------------------------- | -------- |
| `region`        | string | Região AWS                  | Não      |
| `environment`   | string | Nome do ambiente            | Não      |
| `db_name`       | string | Nome do banco de dados      | Não      |
| `db_user`       | string | Usuário do banco            | Sim      |
| `db_password`   | string | Senha do banco              | Sim      |
| `my_ip`         | string | IP permitido (se aplicável) | Não      |
| `key_pair_name` | string | Nome do key pair EC2        | Não      |

### Módulos

#### 1. VPC Module (`modules/vpc`)

Cria toda a infraestrutura de rede:

- VPC com CIDR configurável
- Subnets públicas e privadas em múltiplas AZs
- Internet Gateway
- NAT Gateway com Elastic IP
- Route Tables e associações

#### 2. Security Groups Module (`modules/security-groups`)

Define os security groups necessários:

- Lambda Security Group (permite egress para comunicação externa)

#### 3. RDS Module (`modules/rds`)

Provisiona o banco de dados PostgreSQL:

- DB Subnet Group
- Security Group específico do RDS (ingress na porta 5432 dos SGs permitidos)
- Instância RDS PostgreSQL 17
- Configurações de rede privada

---

## 🔄 CI/CD (GitHub Actions)

O repositório contém um pipeline automatizado ([.github/workflows/ci-cd-databse.yml](infra-database/.github/workflows/ci-cd-databse.yml)) que:

### Triggers

- **Push** nas branches:
  - `main` → deploy em **production**
  - `homologation` → deploy em **homologation**

### Workflow

1. **Checkout** do código
2. **Configuração de credenciais AWS** via GitHub Secrets
3. **Setup do Terraform**
4. **Deploy automatizado**:
   - `terraform init`
   - `terraform apply -auto-approve`

### Secrets Necessários no GitHub

Configure os seguintes secrets na organização/repositório:

| Secret                  | Descrição                 |
| ----------------------- | ------------------------- |
| `AWS_ACCESS_KEY_ID`     | Access Key da AWS         |
| `AWS_SECRET_ACCESS_KEY` | Secret Key da AWS         |
| `DB_USER`               | Usuário do banco de dados |
| `DB_PASSWORD`           | Senha do banco de dados   |
| `DB_NAME`               | Nome do banco de dados    |

⚠️ **Importante**: As credenciais são passadas via variáveis de ambiente (`TF_VAR_*`) e nunca são commitadas no repositório.

---

## 🛠️ Dicas e resolução de problemas

### Erro de backend

- Verifique se o bucket S3 `tf-state-challenge-bucket` existe e está acessível
- Confirme que suas credenciais AWS têm permissão de leitura/escrita no bucket
- Verifique se a região está correta (`us-east-2`)

### Permissões insuficientes

Certifique-se de que a IAM role/usuário tem as seguintes permissões:

- **S3**: `s3:GetObject`, `s3:PutObject`, `s3:ListBucket` no bucket de state
- **RDS**: `rds:*` para gerenciar instâncias
- **EC2**: permissões para VPC, Subnets, Security Groups, NAT Gateway, Internet Gateway, Elastic IP
- **IAM**: permissões para criar roles (se necessário)

### Falha no apply

- Revise o output do `terraform plan` antes de aplicar
- Verifique logs de erro detalhados
- Em caso de state corrupto, use `terraform state` commands para diagnóstico

### RDS não acessível

- O RDS está em subnets privadas sem acesso público (`publicly_accessible = false`)
- Acesso é permitido apenas via security groups configurados (Lambda SG)
- Para acesso externo, considere usar:
  - Bastion host em subnet pública
  - VPN connection
  - AWS Systems Manager Session Manager

---

## 🔐 Segurança e boas práticas

### Segurança

- ✅ Credenciais gerenciadas via secrets/variáveis de ambiente
- ✅ RDS em subnets privadas sem acesso público
- ✅ Security Groups com regras restritivas
- ✅ State file criptografado no S3
- ✅ Senhas marcadas como `sensitive` no Terraform

### Boas Práticas

- 📋 Code review obrigatório para mudanças em `production`
- 🔄 Teste mudanças em `dev` antes de aplicar em ambientes superiores
- 📝 Documente alterações significativas na infraestrutura
- 🏷️ Use tags consistentes para rastreamento de recursos
- 🔒 Nunca commite credenciais ou dados sensíveis no repositório
- 📊 Monitore custos e uso de recursos AWS

---

## 📚 Comandos úteis

```bash
# Ver estado atual
terraform show

# Listar recursos gerenciados
terraform state list

# Inspecionar recurso específico
terraform state show module.rds.aws_db_instance.this

# Atualizar estado sem modificar recursos
terraform refresh

# Validar configuração
terraform validate

# Formatar código
terraform fmt -recursive

# Importar recurso existente
terraform import module.rds.aws_db_instance.this <db-instance-id>

# Ver outputs
terraform output
terraform output -json
```

---

## 📞 Suporte

Para questões ou problemas:

1. Verifique a documentação do Terraform: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
2. Revise os logs do GitHub Actions
3. Consulte a equipe de DevOps/Infraestrutura

---

**Última atualização**: Janeiro 2026
