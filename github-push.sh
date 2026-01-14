#!/bin/bash
# Script rápido de Push para GitHub
# Execute: bash github-push.sh

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                    📤 PUSH AUTOMÁTICO - GITHUB                             ║"
echo "║                                                                            ║"
echo "║                   CRM Vendas Pro - Deploy Setup                            ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Verificar Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git não instalado${NC}"
    exit 1
fi

# Verificar se tem remote
REMOTE=$(git remote get-url origin 2>/dev/null)
if [ -z "$REMOTE" ]; then
    echo -e "${CYAN}Configure o repositório remoto:${NC}"
    echo ""
    read -p "🔗 URL do GitHub (ex: https://github.com/usuario/repo.git): " REMOTE_URL
    
    if [ -z "$REMOTE_URL" ]; then
        echo -e "${RED}❌ URL inválida${NC}"
        exit 1
    fi
    
    echo -n "⏳ Adicionando remote... "
    git remote add origin "$REMOTE_URL"
    echo -e "${GREEN}✓${NC}"
fi

# Branch
echo -n "⏳ Configurando branch... "
git branch -M main 2>/dev/null
echo -e "${GREEN}✓${NC}"

# Commit
echo -n "⏳ Adicionando arquivos... "
git add .
echo -e "${GREEN}✓${NC}"

echo -n "⏳ Criando commit... "
git commit -m "Deploy Render: PostgreSQL v2.0.0" 2>/dev/null
echo -e "${GREEN}✓${NC}"

# Push
echo -n "⏳ Fazendo push... "
git push -u origin main

if [ $? -eq 0 ]; then
    echo -e ""
    echo -e "${GREEN}✅ Push realizado com sucesso!${NC}"
    echo ""
    echo -e "  Repositório: $(git remote get-url origin)"
    echo -e "  Branch: $(git branch --show-current)"
    echo -e "  Commits: $(git rev-list --count HEAD)"
    echo ""
else
    echo -e ""
    echo -e "${RED}❌ Erro no push${NC}"
    echo "  Verifique suas credenciais do GitHub"
    exit 1
fi

echo ""
