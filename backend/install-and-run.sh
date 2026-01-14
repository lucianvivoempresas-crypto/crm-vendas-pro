#!/bin/bash
# install-and-run.sh - Script de instalação e execução do CRM com PostgreSQL

set -e

echo "================================"
echo "🚀 CRM Vendas Pro - PostgreSQL"
echo "================================"
echo ""

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Por favor, instale Node.js"
    exit 1
fi
echo "✓ Node.js instalado: $(node -v)"

# Verificar PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "⚠️  PostgreSQL não encontrado. Para Windows, use:"
    echo "   choco install postgresql"
    echo "   ou baixe em: https://www.postgresql.org/download/"
    echo ""
    echo "Continuando mesmo assim... você precisará configurar o PostgreSQL"
fi

# Criar diretório se não existir
cd "$(dirname "$0")"

echo ""
echo "📦 Instalando dependências..."
npm install

# Verificar se arquivo .env existe
if [ ! -f .env ]; then
    echo ""
    echo "⚠️  Arquivo .env não encontrado!"
    echo "Criando .env a partir de .env.example..."
    cp .env.example .env
    echo "✓ .env criado"
    echo ""
    echo "📝 Edite .env com suas credenciais PostgreSQL:"
    echo "   DB_HOST=localhost"
    echo "   DB_PORT=5432"
    echo "   DB_USER=postgres"
    echo "   DB_PASSWORD=sua_senha_aqui"
    echo "   DB_NAME=crm_vendas_pro"
fi

echo ""
echo "✅ Tudo pronto!"
echo ""
echo "🚀 Iniciando servidor CRM..."
echo ""
npm start
