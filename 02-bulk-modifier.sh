#!/bin/bash

# ==============================================================================
# Script: Generic Bulk Repository Modifier
# Descrição: Itera sobre múltiplos repositórios Git locais, cria uma nova branch,
# busca arquivos específicos e aplica uma alteração customizada em lote.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CONFIGURAÇÕES (Preencha de acordo com a sua necessidade)
# ------------------------------------------------------------------------------
BASE_BRANCH="main"                          # Branch de origem (ex: main, master, dev)
NEW_BRANCH_NAME="feature/bulk-update"       # Nome da nova branch que será criada
FILE_PATTERN="*.yaml"                       # Padrão de busca (ex: *.json, Dockerfile, *.yaml)
COMMIT_MESSAGE="chore: bulk update files"   # Mensagem de commit padrão

# Lista de repositórios que NÃO devem ser alterados (separados por espaço)
EXCLUDE_REPOS=("repo-sensivel-1" "repo-legado-2")

# ------------------------------------------------------------------------------
# 2. LÓGICA DE EXECUÇÃO
# ------------------------------------------------------------------------------
echo "🚀 Iniciando processamento em lote..."

# Itera sobre todas as pastas no diretório atual
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
    echo "📂 Processando repositório: $REPO_NAME"

    # Atualiza a branch base e cria a nova branch
    git fetch origin quiet

    # Tenta fazer checkout na base local, se falhar, tenta da origin
    git checkout "$BASE_BRANCH" 2>/dev/null || git checkout -b "$BASE_BRANCH" origin/"$BASE_BRANCH" 2>/dev/null
    git pull origin "$BASE_BRANCH" quiet

    # Cria e muda para a nova branch de trabalho
    git checkout -B "$NEW_BRANCH_NAME" quiet

    # Busca arquivos que batem com o padrão e aplica a alteração
    find . -type f -name "$FILE_PATTERN" | while read -r FILE; do

        echo "   ✍️  Analisando/Alterando: $FILE"

        # ======================================================================
        # 🛠️ INSIRA SUA LÓGICA DE ALTERAÇÃO AQUI
        # ======================================================================
        # Exemplos de uso:
        # 1. Substituir texto: sed -i 's/antigo/novo/g' "$FILE"
        # 2. Adicionar linha:  echo "nova_variavel=123" >> "$FILE"
        # ======================================================================

        # [COLOQUE SEU COMANDO AQUI]

    done

    # --------------------------------------------------------------------------
    # 3. COMMIT E PUSH (Descomente para automatizar)
    # --------------------------------------------------------------------------
    # if [[ -n $(git status -s) ]]; then
    #     echo "   📦 Commitando alterações..."
    #     git add .
    #     git commit -m "$COMMIT_MESSAGE" quiet
    #     git push -u origin "$NEW_BRANCH_NAME" quiet
    # else
    #     echo "   ℹ️  Nenhuma alteração detectada neste repositório."
    # fi

    # Volta para o diretório raiz para processar o próximo repositório
    cd ..
done

echo "--------------------------------------------------"
echo "✅ Processamento em lote concluído!"
echo "⚠️  Dica: Rode 'git status' nos repositórios para revisar as mudanças antes de commitar."
