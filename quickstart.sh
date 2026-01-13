#!/bin/bash

# Script para deploy rápido em diferentes plataformas

echo "🚀 CRM Vendas Pro - Deploy Automático"
echo ""
echo "Escolha sua plataforma:"
echo "1) DigitalOcean (Recomendado)"
echo "2) AWS EC2"
echo "3) Heroku"
echo "4) Localhost (Teste)"
echo ""
read -p "Escolha uma opção (1-4): " platform

case $platform in
  1)
    echo "DigitalOcean selecionado..."
    echo ""
    echo "Passos para deploy no DigitalOcean:"
    echo "1. Criar um Droplet com Ubuntu 22.04 LTS"
    echo "2. SSH no servidor:"
    echo "   ssh root@seu_ip"
    echo ""
    echo "3. Instalar Docker:"
    echo "   curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    echo ""
    echo "4. Instalar Docker Compose:"
    echo "   curl -L 'https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose"
    echo ""
    echo "5. Clonar repositório:"
    echo "   git clone seu-repositorio crm-vendas-pro && cd crm-vendas-pro"
    echo ""
    echo "6. Executar deploy:"
    echo "   chmod +x deploy.sh && ./deploy.sh"
    echo ""
    echo "7. Configurar domínio:"
    echo "   - Apontar DNS para o IP do Droplet"
    echo "   - Aguardar propagação (até 24h)"
    echo "   - Acessar https://seu-dominio.com"
    ;;
  2)
    echo "AWS EC2 selecionado..."
    echo ""
    echo "Passos para deploy na AWS:"
    echo "1. Criar instância EC2 (t3.small ou similar)"
    echo "2. Security Group: liberar portas 80, 443, 22"
    echo "3. SSH no servidor:"
    echo "   ssh -i sua-chave.pem ec2-user@ip-da-instancia"
    echo ""
    echo "4. Instalar Docker e Docker Compose (idem DigitalOcean)"
    echo "5. Clonar repositório"
    echo "6. Executar deploy"
    echo ""
    echo "7. Associar Elastic IP (para manter IP fixo)"
    ;;
  3)
    echo "Heroku selecionado..."
    echo ""
    echo "Passos para deploy no Heroku:"
    echo "1. Instalar Heroku CLI: https://devcenter.heroku.com/articles/heroku-cli"
    echo "2. Fazer login: heroku login"
    echo "3. Criar app: heroku create seu-app-crm"
    echo "4. Fazer deploy: git push heroku main"
    echo ""
    echo "⚠️  Nota: Heroku não suporta banco de dados persistente gratuito"
    echo "   Use PostgreSQL Add-on para produção"
    ;;
  4)
    echo "Localhost (Desenvolvimento)..."
    chmod +x deploy.sh
    ./deploy.sh
    ;;
  *)
    echo "Opção inválida!"
    exit 1
    ;;
esac

echo ""
echo "Para mais informações, veja DEPLOY.md"
