# 🚀 Azure DevOps Bulk Automation Toolkit

Uma suíte de scripts Bash projetada para automatizar tarefas repetitivas em larga escala no Azure DevOps. Este toolkit permite clonar, modificar arquivos e abrir Pull Requests em dezenas de repositórios simultaneamente.

## 🎯 O Problema
Em arquiteturas de microsserviços ou grandes organizações, uma simples alteração de infraestrutura (como atualizar a versão de uma dependência no `package.json` ou modificar um template YAML de CI/CD) pode exigir horas de trabalho manual: clonar 50 repositórios, criar branches, editar arquivos, commitar, fazer push e abrir 50 Pull Requests na interface web.

## 💡 A Solução
Este repositório contém uma esteira de automação em 3 etapas que reduz horas de trabalho braçal para poucos minutos de execução:

1. **`01-bulk-clone.sh`**: Conecta na Azure CLI e clona todos os repositórios de um projeto localmente usando Personal Access Tokens (PAT).
2. **`02-bulk-modifier.sh`**: O motor da automação. Itera sobre os repositórios clonados, cria branches de trabalho, busca arquivos por padrão (ex: `*.yaml`) e aplica alterações customizadas (via `sed`, `awk`, etc.) com proteção contra duplicidade e lista de exclusão (ignore list).
3. **`03-bulk-pr-creator.sh`**: Finaliza o fluxo utilizando a Azure CLI para abrir Pull Requests em massa de todas as branches alteradas para a branch principal.

---

## 📖 Estudo de Caso: Refatoração de Pipelines CI/CD

Para ilustrar o poder deste toolkit, aqui está um cenário real onde ele foi aplicado com sucesso:

**O Desafio:** 
Precisávamos alterar a configuração de ferramentas de segurança (SAST/DAST) em mais de 40 repositórios diferentes. A execução estava "chumbada" (hardcoded) como `true` nos arquivos YAML, e o objetivo era parametrizar isso para criar um *checkbox* dinâmico na interface do Azure DevOps.

**A Execução:**
Em vez de abrir repositório por repositório, configuramos o script `02-bulk-modifier.sh` com a seguinte lógica de injeção (usando `sed` e `head`/`tail`):

1. O script buscou todos os arquivos `*.ci.yaml`.
2. Substituiu a string `enableSecurityScan: true` por `enableSecurityScan: ${{ parameters.enableSecurityScan }}`.
3. Injetou o bloco de definição do parâmetro no topo de cada arquivo YAML, respeitando a formatação estrutural (`---`).
4. O script `03-bulk-pr-creator.sh` abriu 40 Pull Requests automaticamente com o título *"feat: parametrização de scan de segurança"*.

**Resultado:** Um trabalho estimado em 1 dia inteiro foi concluído, revisado e enviado para aprovação em menos de 15 minutos.

---

## 🛠️ Como Usar

### Pré-requisitos
* [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) instalada e autenticada (`az login`).
* Git instalado.
* Ambiente Bash (Linux, macOS ou WSL no Windows).

### Passo a Passo
1. Clone este repositório de automação.
2. Edite o arquivo `01-bulk-clone.sh` inserindo sua Organização, Projeto e PAT. Execute-o em uma pasta vazia.
3. Edite o arquivo `02-bulk-modifier.sh`, defina as branches e insira o seu comando de alteração (ex: `sed`) no bloco indicado. Execute-o na mesma pasta.
4. Revise as alterações localmente (`git status` / `git diff`).
5. Descomente a seção de *Commit e Push* no script 02 e rode novamente para enviar ao servidor.
6. Edite e execute o `03-bulk-pr-creator.sh` para abrir os Pull Requests.

> **⚠️ Aviso de Segurança:** Nunca commite seus Personal Access Tokens (PATs) ou credenciais. Os scripts deste repositório possuem travas de segurança, mas sempre revise suas variáveis antes de executar.

