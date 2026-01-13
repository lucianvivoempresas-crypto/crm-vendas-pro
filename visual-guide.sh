#!/bin/bash

# 🎨 Visualizador de Arquitetura Docker - CRM Vendas Pro

echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                   CRM VENDAS PRO - DOCKER SETUP                        ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

echo "📦 ARQUIVOS CRIADOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

files=(
  "✅ Dockerfile               → Imagem Docker containerizada"
  "✅ docker-compose.yml       → Orquestração de containers"
  "✅ nginx.conf              → Reverse proxy + SSL"
  "✅ .dockerignore           → Otimizações de build"
  "✅ .env.example            → Variáveis de ambiente"
  "✅ deploy.sh               → Script deploy automático"
  "✅ quickstart.sh           → Seletor de plataforma"
  "✅ DEPLOY.md               → Guia completo (30+ páginas)"
  "✅ DOCKER-EXAMPLES.md      → 6 exemplos de config"
  "✅ CHECKLIST.md            → Checklist produção"
  "✅ README-DOCKER.md        → Overview rápido"
  "✅ server.js (atualizado)  → Suporta ENV variables"
)

for file in "${files[@]}"; do
  echo "  $file"
done

echo ""
echo "🏗️  ARQUITETURA:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
cat << 'EOF'
┌────────────────────────────────────────────────┐
│         🌍 Internet / Usuários                 │
└───────────────────┬────────────────────────────┘
                    │ HTTPS (443)
                    │ HTTP (80) → HTTPS
                    ↓
┌────────────────────────────────────────────────┐
│  🔒 Nginx (Reverse Proxy + SSL)                │
│  ├─ Porta 80  (HTTP)                          │
│  ├─ Porta 443 (HTTPS/TLS)                     │
│  └─ Gerencia certificados (Let's Encrypt)     │
└───────────────────┬────────────────────────────┘
                    │
                    ↓
┌────────────────────────────────────────────────┐
│  🚀 Node.js Application (CRM Vendas Pro)      │
│  ├─ Porta 3000 (interna)                      │
│  ├─ Express.js framework                      │
│  ├─ Frontend estático (HTML/JS)               │
│  └─ APIs REST                                 │
└───────────────────┬────────────────────────────┘
                    │
                    ↓
┌────────────────────────────────────────────────┐
│  💾 SQLite Database                            │
│  ├─ /app/data/crm.sqlite                      │
│  ├─ Volume Docker (persistente)               │
│  ├─ Backups automáticos                       │
│  └─ Dados nunca são perdidos                  │
└────────────────────────────────────────────────┘
EOF

echo ""
echo "🚀 3 FORMAS DE USAR:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1️⃣  DESENVOLVIMENTO LOCAL"
echo "     $ ./deploy.sh"
echo "     → http://localhost:3000"
echo "     → Rápido para testar"
echo ""
echo "  2️⃣  VPS (DigitalOcean, AWS, Azure, etc)"
echo "     $ chmod +x deploy.sh && ./deploy.sh"
echo "     → https://seu-dominio.com"
echo "     → Controle total"
echo ""
echo "  3️⃣  PLATAFORMA CLOUD (Render, Railway, Heroku)"
echo "     → Conecta GitHub → Deploy automático"
echo "     → https://seu-app.render.com"
echo "     → Mais simples"
echo ""

echo "📊 COMPARAÇÃO DE PLATAFORMAS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Platform        │ Custo    │ Facilidade │ Scalability │ Suporte"
echo "  ──────────────┼──────────┼────────────┼─────────────┼────────────"
echo "  DigitalOcean  │ $5-$15   │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐    │ Excelente"
echo "  AWS EC2       │ $5-$50+  │ ⭐⭐⭐⭐   │ ⭐⭐⭐⭐⭐  │ Excelente"
echo "  Render        │ Grátis   │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐    │ Bom"
echo "  Railway       │ Grátis   │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐    │ Bom"
echo "  Heroku        │ $7-$50+  │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐    │ Bom"
echo ""

echo "⚡ COMANDOS RÁPIDOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Iniciar:          docker-compose up -d"
echo "  Status:           docker-compose ps"
echo "  Logs:             docker-compose logs -f crm-app"
echo "  Parar:            docker-compose down"
echo "  Atualizar:        git pull && docker-compose build && docker-compose up -d"
echo "  Fazer backup:     docker-compose exec crm-app cp /app/data/crm.sqlite /app/data/backup_\$(date +%s).sqlite"
echo "  Acessar app:      http://localhost:3000"
echo "  Health check:     curl http://localhost:3000/health"
echo ""

echo "🔐 SEGURANÇA IMPLEMENTADA:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ✅ HTTPS/TLS (Let's Encrypt)"
echo "  ✅ Nginx com headers de segurança"
echo "  ✅ Variáveis de ambiente"
echo "  ✅ Volumes persistentes"
echo "  ✅ Health checks automáticos"
echo "  ✅ Restart policy"
echo "  ✅ Multi-stage build (imagem otimizada)"
echo "  ✅ Exemplo de firewall config"
echo ""

echo "📚 DOCUMENTAÇÃO:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📄 RESUMO-DOCKER.txt        → Início rápido"
echo "  📄 README-DOCKER.md         → Visão geral"
echo "  📄 DEPLOY.md                → Guia detalhado (30+ páginas)"
echo "  📄 DOCKER-EXAMPLES.md       → Exemplos avançados"
echo "  📄 CHECKLIST.md             → Itens para verificar"
echo ""

echo "🎯 PRÓXIMOS PASSOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1️⃣  Leia: RESUMO-DOCKER.txt (2 min)"
echo "  2️⃣  Teste: ./deploy.sh (10 min)"
echo "  3️⃣  Escolha: ./quickstart.sh"
echo "  4️⃣  Deploy: Siga DEPLOY.md para sua plataforma"
echo "  5️⃣  Acesse: https://seu-dominio.com"
echo ""

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ TUDO PRONTO PARA FAZER DEPLOY!                  ║"
echo "║                        Sucesso! 🚀                                    ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""
