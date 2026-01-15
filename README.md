# 📦 Infraestrutura AWS RDS PostgreSQL – Terraform

Este repositório contém o código Terraform responsável por provisionar e gerenciar uma instância PostgreSQL no Amazon RDS, incluindo redes (VPC/subnets), security groups e outros recursos necessários.

---

## 🚀 Objetivo

- Centralizar e versionar a infraestrutura do banco de dados PostgreSQL.
- Automatizar validações e deploys via GitHub Actions (CI/CD).
- Fornecer passos claros para provisionar e manter a infraestrutura localmente e em pipeline.

---

## 📁 Estrutura do repositório

- `envs/` — ambientes separados:
  - `dev/`, `homologation/`, `production/` (cada um contém `main.tf`, `variables.tf`, `terraform.tfvars`, `backend.tf`, `outputs.tf`).
- `modules/` — módulos reutilizáveis (vpc, rds, bastion, security-groups, etc.).
- `README.md` — este arquivo.

---

## ✨ Pré-requisitos

- Terraform CLI (recomendado >= 1.0)
- AWS CLI (opcional, para criar buckets/tables e validar credenciais)
- Conta AWS com permissões para criar recursos (S3, RDS, EC2, IAM, VPC, Subnets, SecurityGroups, etc.)
- Um bucket S3 para armazenar o _remote state_ (o projeto já contém `backend.tf` em cada ambiente apontando para S3)

---

## 🔧 Configuração inicial (passo a passo)

1. **Preparar backend (S3)**

   - Confirme que o bucket S3 apontado em `envs/<ambiente>/backend.tf` existe (ex.: `terraform-state-bucket-challenger-19`).
   - Recomenda-se usar uma tabela DynamoDB para locking do estado (evita alterações concorrentes):

     ```bash
     # criar bucket (exemplo)
     aws s3 mb s3://terraform-state-bucket-challenger-19 --region us-east-2
     ```

2. **Defina credenciais AWS**

   - Exportar variáveis de ambiente:

     ```bash
     export AWS_ACCESS_KEY_ID=...
     export AWS_SECRET_ACCESS_KEY=...
     export AWS_REGION=us-east-2
     # ou usar AWS_PROFILE
     ```

3. **Revisar variáveis**

   - Abra `envs/<ambiente>/variables.tf` e `envs/<ambiente>/terraform.tfvars` e ajuste conforme necessário (ex.: tamanho do banco, engine version, subnets, tags).

4. **Inicializar Terraform**

   ```bash
   cd infra-database/envs/production
   terraform init
   ```

5. **Planejar**

   ```bash
   terraform plan -out=tfplan
   ```

6. **Aplicar**

   ```bash
   terraform apply "tfplan"
   # ou
   terraform apply -auto-approve
   ```

7. **Verificar outputs**

   Após o `apply`, veja os outputs (ex.: endpoint do RDS):

   ```bash
   terraform output
   terraform output -json
   ```

8. **Destruir (quando necessário)**

   ```bash
   terraform destroy
   ```

---

## ✅ Arquivos e pontos importantes

- `envs/<ambiente>/backend.tf` — configura o backend S3 (verifique `bucket`, `key`, `region`).
- `envs/<ambiente>/main.tf` — entrypoint do ambiente que chama módulos.
- `modules/rds` — módulo que provisiona o RDS (ver `variables.tf` e `outputs.tf`).
- `outputs.tf` — expõe valores úteis (endpoint, arn, etc.).

---

## 🔄 CI/CD (GitHub Actions)

- O repositório contém pipelines que:
  - Validam `terraform fmt`, `init`, `validate` e `plan` em PRs.
  - Executam `apply` automaticamente ao realizar merge nas branches autorizadas (por exemplo `homologation` e `production`).
- **Segurança**: credenciais e variáveis sensíveis devem ser fornecidas via GitHub Organization Secrets / Variables (nunca commitar credenciais no repositório).

---

## 🛠️ Dicas e resolução de problemas

- Erro de backend: verifique se o bucket S3 e as credenciais estão corretos.
- Permissões insuficientes: certifique-se de que a IAM role/usuário tem permissões para S3, RDS, EC2 (para subnets), VPC, IAM (se necessário).
- Se algo falhar no `apply`, corrija o código e reexamine `terraform plan` antes de aplicar novamente.

---

## 🔐 Segurança e boas práticas

- Não armazene credenciais no repositório.
- Faça code review em mudanças de infraestrutura críticas (especialmente alterações em `production`).

---
