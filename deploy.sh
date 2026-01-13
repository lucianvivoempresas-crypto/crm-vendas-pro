#!/bin/bash

# Script de Deploy do CRM Vendas Pro com Docker

set -e

echo "🚀 Iniciando deploy do CRM Vendas Pro..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não está instalado!${NC}"
    echo "Instale Docker em: https://docs.docker.com/install/"
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose não está instalado!${NC}"
    echo "Instale Docker Compose em: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✓ Docker e Docker Compose encontrados${NC}"

# Parar containers existentes
echo -e "${YELLOW}Parando containers existentes...${NC}"
docker-compose down || true

# Limpar imagens antigas
echo -e "${YELLOW}Limpando imagens antigas...${NC}"
docker image prune -f || true

# Build da imagem
echo -e "${YELLOW}Construindo imagem Docker...${NC}"
docker-compose build --no-cache

# Iniciar containers
echo -e "${YELLOW}Iniciando containers...${NC}"
docker-compose up -d

# Aguardar aplicação ficar pronta
echo -e "${YELLOW}Aguardando aplicação ficar pronta...${NC}"
sleep 5

# Verificar saúde da aplicação
echo -e "${YELLOW}Verificando saúde da aplicação...${NC}"
if docker-compose exec -T crm-app curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Aplicação está saudável!${NC}"
else
    echo -e "${YELLOW}⚠ Aguardando aplicação...${NC}"
    sleep 5
fi

# Exibir status
echo -e "${GREEN}📊 Status dos Containers:${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}✅ Deploy concluído com sucesso!${NC}"
echo ""
echo -e "${YELLOW}Informações importantes:${NC}"
echo "  • Aplicação: http://localhost:3000"
echo "  • Nginx: http://localhost:80"
echo "  • Banco de dados: /app/data/crm.sqlite (dentro do container)"
echo ""
echo -e "${YELLOW}Comandos úteis:${NC}"
echo "  • Ver logs: docker-compose logs -f crm-app"
echo "  • Parar: docker-compose down"
echo "  • Reiniciar: docker-compose restart"
echo "  • Remover tudo: docker-compose down -v"
echo ""
