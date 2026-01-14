#!/bin/bash
# Script de Deploy Render - Bash (Mac/Linux)
# Execute: bash setup-render.sh

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                    🚀 SETUP AUTOMÁTICO - RENDER DEPLOY                     ║"
echo "║                                                                            ║"
echo "║                CRM Vendas Pro - PostgreSQL para Render                     ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ===== 1. VERIFICAR PRÉ-REQUISITOS =====
echo -e "${CYAN}1️⃣  Verificando pré-requisitos...${NC}"
echo "───────────────────────────────────────────────────────────────────────────────"

# Verificar Git
echo -n "  ⏳ Verificando Git... "
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✓${NC}"
    echo "    $GIT_VERSION"
else
    echo -e "${RED}✗${NC}"
    echo -e "    ${RED}❌ Git não instalado. Instale em: https://git-scm.com${NC}"
    exit 1
fi

# Verificar Node.js
echo -n "  ⏳ Verificando Node.js... "
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC}"
    echo "    $NODE_VERSION"
else
    echo -e "${RED}✗${NC}"
    echo -e "    ${RED}❌ Node.js não instalado. Instale em: https://nodejs.org${NC}"
    exit 1
fi

# Verificar npm
echo -n "  ⏳ Verificando npm... "
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC}"
    echo "    npm $NPM_VERSION"
else
    echo -e "${RED}✗${NC}"
    echo -e "    ${RED}❌ npm não encontrado${NC}"
    exit 1
fi

echo ""

# ===== 2. PREPARAR GIT =====
echo -e "${CYAN}2️⃣  Preparando repositório Git...${NC}"
echo "───────────────────────────────────────────────────────────────────────────────"

# Criar .gitignore se não existir
if [ ! -f ".gitignore" ]; then
    echo -n "  ⏳ Criando .gitignore... "
    cat > .gitignore << 'EOF'
node_modules/
.env
.env.local
crm.sqlite
*.log
.DS_Store
dist/
build/
EOF
    echo -e "${GREEN}✓${NC}"
else
    echo -e "  ${GREEN}✓${NC} .gitignore já existe"
fi

# Verificar se git está inicializado
if [ ! -d ".git" ]; then
    echo -n "  ⏳ Inicializando Git... "
    git init > /dev/null 2>&1
    echo -e "${GREEN}✓${NC}"
else
    echo -e "  ${GREEN}✓${NC} Repositório Git já existe"
fi

# Verificar credenciais git
echo -n "  ⏳ Verificando credenciais Git... "
GIT_USER=$(git config --global user.name 2>/dev/null)
if [ -z "$GIT_USER" ]; then
    echo ""
    echo ""
    echo -e "    ${YELLOW}⚠️  Configure seu Git primeiro:${NC}"
    read -p "    📧 Email: " EMAIL
    read -p "    👤 Nome: " NAME
    
    git config --global user.email "$EMAIL"
    git config --global user.name "$NAME"
    echo -e "    ${GREEN}✓${NC} Git configurado"
else
    echo -e "${GREEN}✓${NC}"
    echo "    Usuário: $GIT_USER"
fi

echo ""

# ===== 3. GERAR JWT SECRET =====
echo -e "${CYAN}3️⃣  Gerando credenciais seguras...${NC}"
echo "───────────────────────────────────────────────────────────────────────────────"

echo -n "  ⏳ Gerando JWT_SECRET... "
JWT_SECRET=$(openssl rand -hex 32)
echo -e "${GREEN}✓${NC}"
echo -e "    ${YELLOW}JWT_SECRET gerado (salve em local seguro!)${NC}"

echo ""

# ===== 4. VERIFICAR ARQUIVOS NECESSÁRIOS =====
echo -e "${CYAN}4️⃣  Verificando arquivos essenciais...${NC}"
echo "───────────────────────────────────────────────────────────────────────────────"

FILES=("backend/server.js" "backend/db.js" "backend/package.json" "backend/auth.js")
ALL_FOUND=true

for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo -e "  ${GREEN}✓${NC} $FILE"
    else
        echo -e "  ${RED}✗${NC} $FILE"
        ALL_FOUND=false
    fi
done

if [ "$ALL_FOUND" = false ]; then
    echo ""
    echo -e "  ${RED}❌ Alguns arquivos estão faltando!${NC}"
    exit 1
fi

echo ""

# ===== 5. FAZER GIT COMMIT =====
echo -e "${CYAN}5️⃣  Fazendo commit do código...${NC}"
echo "───────────────────────────────────────────────────────────────────────────────"

echo -n "  ⏳ Adicionando arquivos... "
git add . 2>/dev/null
echo -e "${GREEN}✓${NC}"

# Verificar se há mudanças
if [ -n "$(git status --porcelain)" ]; then
    echo -n "  ⏳ Criando commit... "
    git commit -m "Deploy Render: PostgreSQL v2.0.0" 2>/dev/null
    echo -e "${GREEN}✓${NC}"
else
    echo -e "  ${GREEN}✓${NC} Nenhuma mudança a commitar"
fi

echo ""

# ===== 6. VERIFICAR GITHUB =====
echo -e "${CYAN}6️⃣  Status do repositório remoto...${NC}"
echo "───────────────────────────────────────────────────────────────────────────────"

REMOTE_URL=$(git remote get-url origin 2>/dev/null)
if [ ! -z "$REMOTE_URL" ]; then
    echo -e "  ${GREEN}✓${NC} Remote já configurado"
    echo "    URL: $REMOTE_URL"
else
    echo -e "  ${YELLOW}⚠️  Remote não configurado${NC}"
    echo ""
    echo -e "  ${CYAN}📝 Próximos passos:${NC}"
    echo "    1. Crie um repositório em github.com"
    echo "    2. Execute:"
    echo "       git remote add origin https://github.com/SEU_USER/crm-vendas-pro.git"
    echo "       git branch -M main"
    echo "       git push -u origin main"
    echo ""
fi

echo ""

# ===== 7. CRIAR ARQUIVO DE VARIÁVEIS =====
echo -e "${CYAN}7️⃣  Criando arquivo de configuração Render...${NC}"
echo "───────────────────────────────────────────────────────────────────────────────"

echo -n "  ⏳ Criando render-env.txt... "
cat > render-env.txt << EOF
# Copie estas variáveis para o Render Dashboard
# Settings → Environment Variables

PORT=10000
HOST=0.0.0.0
NODE_ENV=production

# PostgreSQL - PREENCHER DO RENDER
DB_HOST=seu-db.render.com
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=sua-senha-do-render
DB_NAME=crm_vendas_pro

# Segurança
JWT_SECRET=$JWT_SECRET

# Instruções:
# 1. No Render, copie a connection string do PostgreSQL
# 2. Extraia DB_HOST, DB_USER, DB_PASSWORD
# 3. Cole as variáveis acima no Dashboard
EOF
echo -e "${GREEN}✓${NC}"
echo -e "    ${YELLOW}Arquivo criado: render-env.txt${NC}"

echo ""

# ===== RESUMO FINAL =====
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}✅ SETUP CONCLUÍDO!${NC}"
echo ""
echo -e "${CYAN}📋 PRÓXIMOS PASSOS:${NC}"
echo ""
echo -e "${CYAN}1️⃣  GITHUB${NC}"
echo "    Se ainda não tiver repositório remoto:"
echo "    • Vá em github.com"
echo "    • Crie repositório: crm-vendas-pro"
echo "    • Execute:"
echo -e "      ${YELLOW}git remote add origin https://github.com/SEU_USER/crm-vendas-pro.git${NC}"
echo -e "      ${YELLOW}git branch -M main${NC}"
echo -e "      ${YELLOW}git push -u origin main${NC}"
echo ""
echo -e "${CYAN}2️⃣  RENDER - CRIAR POSTGRESQL${NC}"
echo "    • Vá em render.com"
echo "    • Dashboard → New + → PostgreSQL"
echo "    • Nome: crm-vendas-pro-db"
echo "    • Aguarde 2-5 minutos"
echo "    • Copie a connection string"
echo ""
echo -e "${CYAN}3️⃣  RENDER - CRIAR WEB SERVICE${NC}"
echo "    • Dashboard → New + → Web Service"
echo "    • Conectar repositório GitHub"
echo "    • Build: npm install"
echo "    • Start: node backend/server.js"
echo ""
echo -e "${CYAN}4️⃣  RENDER - ADICIONAR VARIÁVEIS${NC}"
echo "    • Abra: render-env.txt (criado neste diretório)"
echo "    • Copie todas as variáveis"
echo "    • Dashboard → Web Service → Environment"
echo "    • Cole cada variável"
echo ""
echo -e "${CYAN}5️⃣  RENDER - FAZER DEPLOY${NC}"
echo "    • Dashboard → Manual Deploy"
echo "    • Ou: git push origin main (auto-deploy)"
echo ""
echo -e "${CYAN}6️⃣  TESTAR${NC}"
echo "    • https://seu-servico.onrender.com"
echo "    • Email: admin@crm.local"
echo "    • Senha: JL10@dez"
echo -e "    • ${YELLOW}Mudar senha após login!${NC}"
echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}🔐 CREDENCIAIS GERADAS:${NC}"
echo ""
echo -e "  ${YELLOW}JWT_SECRET (copie e guarde em local seguro):${NC}"
echo "  $JWT_SECRET"
echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${CYAN}📖 DOCUMENTAÇÃO:${NC}"
echo "    • DEPLOY_RENDER.md (guia completo)"
echo "    • RENDER_CHECKLIST.md (passo a passo)"
echo "    • render-env.txt (variáveis geradas)"
echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}🚀 Tudo pronto! Siga os próximos passos acima para fazer deploy.${NC}"
echo ""
