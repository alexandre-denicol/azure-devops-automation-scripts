#!/bin/bash

# ==============================================================================
# Script: Generic Bulk Pull Request Creator
# Descrição: Itera sobre múltiplos repositórios locais e utiliza a Azure CLI
# para abrir Pull Requests em massa no Azure DevOps.
# Pré-requisitos: Azure CLI instalada e autenticada (az login).
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CONFIGURAÇÕES (Preencha de acordo com a sua necessidade)
# ------------------------------------------------------------------------------
SOURCE_BRANCH="sua-branch-de-trabalho"      # Branch que contém as alterações
TARGET_BRANCH="main"                        # Branch de destino (ex: dev, main, master)
PR_TITLE="feat: titulo padrao do pr"        # Título que aparecerá no Pull Request
PR_DESCRIPTION="Descrição detalhada do PR." # Descrição do Pull Request

# Lista de repositórios que NÃO devem ter PRs abertos (separados por espaço)
EXCLUDE_REPOS=("repo-sensivel-1" "repo-legado-2")

# ------------------------------------------------------------------------------
# 2. TRAVA DE SEGURANÇA
# ------------------------------------------------------------------------------
if [ "$SOURCE_BRANCH" == "sua-branch-de-trabalho" ]; then
    echo "[ERRO] Edite o script e preencha as variáveis de configuração do PR."
    exit 1
fi

# ------------------------------------------------------------------------------
# 3. LÓGICA DE EXECUÇÃO
# ------------------------------------------------------------------------------
echo "🚀 Iniciando criação de Pull Requests em lote..."

for REPO_DIR in */; do
    # Remove a barra final do nome do diretório
    REPO_NAME=$(basename "$REPO_DIR")

    # Verifica se o repositório está na lista de exclusão
    if [[ " ${EXCLUDE_REPOS[@]} " =~ " ${REPO_NAME} " ]]; then
        echo "⏭️  Pulando: $REPO_NAME (Na lista de exclusão)"
        continue
    fi

    # Entra no diretório e verifica se é um repositório Git válido
    cd "$REPO_DIR" || continue
    if [ ! -d ".git" ]; then 
        cd ..
        continue 
    fi

    echo "--------------------------------------------------"
    echo "📂 Repositório: $REPO_NAME"

    # Verifica se a branch de origem existe remotamente antes de tentar criar o PR
    if ! git ls-remote --heads origin "$SOURCE_BRANCH" | grep -q "$SOURCE_BRANCH"; then
        echo "   [!] Branch '$SOURCE_BRANCH' não encontrada no remote. Pulando..."
        cd ..
        continue
    fi

    echo "   🛠️  Criando Pull Request..."

    # Cria o PR usando a Azure CLI (o contexto do repositório é inferido pela pasta local)
    az repos pr create \
        --repository "$REPO_NAME" \
        --source-branch "$SOURCE_BRANCH" \
        --target-branch "$TARGET_BRANCH" \
        --title "$PR_TITLE" \
        --description "$PR_DESCRIPTION" \
        --output table

    # Volta para o diretório raiz
    cd ..
done

echo "--------------------------------------------------"
echo "✅ Criação de PRs concluída! Verifique sua interface do Azure DevOps."
