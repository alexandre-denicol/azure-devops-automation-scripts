#!/bin/bash

# ==============================================================================
# Script: Azure DevOps Bulk Cloner
# Descrição: Clona todos os repositórios de um projeto específico no Azure DevOps.
# Pré-requisitos: Azure CLI instalada e autenticada (az login).
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CONFIGURAÇÕES (Preencha com seus dados)
# ------------------------------------------------------------------------------
ORG_NAME="SUA_ORGANIZACAO"
PROJECT_NAME="SEU_PROJETO"
PAT="SEU_PERSONAL_ACCESS_TOKEN"

# ------------------------------------------------------------------------------
# 2. TRAVA DE SEGURANÇA
# ------------------------------------------------------------------------------
# Impede que o script rode com os dados de exemplo
if [ "$PAT" == "SEU_PERSONAL_ACCESS_TOKEN" ] || [ "$ORG_NAME" == "SUA_ORGANIZACAO" ]; then
    echo "[ERRO] Edite o script e preencha as variáveis ORG_NAME, PROJECT_NAME e PAT."
    exit 1
fi

# ------------------------------------------------------------------------------
# 3. EXECUÇÃO
# ------------------------------------------------------------------------------
echo "Buscando lista de repositórios no projeto '$PROJECT_NAME'..."

# Usa a Azure CLI para extrair apenas os nomes dos repositórios
REPOS=$(az repos list --organization "https://dev.azure.com/$ORG_NAME" --project "$PROJECT_NAME" --query "[].name" -o tsv)

if [ -z "$REPOS" ]; then
    echo "[ERRO] Nenhum repositório encontrado. Verifique suas credenciais ou o nome do projeto."
    exit 1
fi

echo "Iniciando o clone em lote..."

for REPO in $REPOS; do
    echo "----------------------------------------"
    echo "Clonando: $REPO"

    # Monta a URL de clone injetando o PAT dinamicamente para evitar prompts de senha
    CLONE_URL="https://user:${PAT}@dev.azure.com/${ORG_NAME}/${PROJECT_NAME}/_git/${REPO}"

    git clone "$CLONE_URL"
done

echo "----------------------------------------"
echo "✅ Todos os repositórios foram clonados com sucesso!"
