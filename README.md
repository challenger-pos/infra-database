📦 Infraestrutura AWS RDS PostgreSQL – Terraform

Este repositório contém os arquivos Terraform responsáveis por provisionar e gerenciar a infraestrutura de um banco de dados PostgreSQL no Amazon RDS.
Além disso, o projeto implementa um pipeline CI/CD no GitHub Actions, garantindo que alterações de infraestrutura sejam aplicadas automaticamente em ambientes específicos.

🚀 Objetivo do Projeto

O objetivo deste repositório é:

- Centralizar todo o código Terraform que provisiona um banco PostgreSQL no AWS RDS.

- Padronizar e automatizar o processo de deploy da infraestrutura.

- Garantir versionamento, rastreabilidade e segurança.

- Automatizar a aplicação das mudanças de infraestrutura com base no fluxo de branches do repositório.

🏗️ Arquitetura Provisionada

O Terraform deste projeto provisiona, entre outros recursos:

- AWS RDS PostgreSQL

- Subnets privadas para o banco

- Security groups

A estrutura completa pode variar conforme a configuração do projeto.

🔄 Fluxo de Deploy – CI/CD (GitHub Actions)

Este repositório possui um pipeline automatizado que realiza validações e deploy da infraestrutura utilizando Terraform.

Os deploys ocorrem de acordo com o branch:

🧪 Homologação (homologation)

- Deploy automático ao realizar merge na branch homologation.

🚀 Produção (production)

- Deploy automático ao realizar merge na branch production.

📘 Principal (main)

- Executa o pipeline ao abrir Pull Request.

- Valida o Terraform (fmt, init, validate, plan).

- Não executa deploy automático.

🔐 Secrets e Variáveis

As credenciais e variáveis sensíveis utilizadas pelo Terraform são fornecidas via:

- GitHub Organization Secrets

- GitHub Organization Varialbles

O Terraform utiliza essas variáveis para autenticação na AWS durante o pipeline.

🛠️ Pipeline – Etapas Principais

- Checkout do repositório

- Configuração do Terraform CLI

- terraform init

- terraform validate

- terraform plan

- terraform apply (somente em branches autorizadas com deploy automático)

O fluxo impede que mudanças quebrem a infraestrutura sem validação prévia.
