# 🐳 CRM Vendas Pro - Docker Setup Completo

## 📋 O Que Foi Criado

```
crm-vendas-pro/
├── Dockerfile                    # ✅ Imagem Docker
├── docker-compose.yml           # ✅ Orquestração
├── nginx.conf                   # ✅ Reverse proxy
├── deploy.sh                    # ✅ Script automático
├── quickstart.sh                # ✅ Seletor de plataforma
├── .dockerignore                # ✅ Otimização
├── .env.example                 # ✅ Variáveis de ambiente
│
├── DEPLOY.md                    # 📖 Guia completo
├── DOCKER-EXAMPLES.md           # 📖 Exemplos avançados
├── CHECKLIST.md                 # ✅ Checklist final
│
└── backend/
    ├── server.js                # ✅ Atualizado (ENV vars)
    ├── package.json
    └── frontend/
```

## 🚀 3 Formas de Deploy

### 1. Local (Teste)
```bash
./deploy.sh
# http://localhost:3000
```

### 2. VPS (DigitalOcean, AWS, etc)
```bash
# SSH no servidor
curl -fsSL https://get.docker.com | sh
docker-compose up -d
# https://seu-dominio.com
```

### 3. Plataforma Cloud (Render, Railway, Heroku)
```bash
# Conectar repositório GitHub
# Deploy automático
# URL: https://seu-app.render.com
```

---

## 🎯 O Que Cada Arquivo Faz

| Arquivo | Propósito | Quando Usar |
|---------|-----------|------------|
| **Dockerfile** | Cria imagem da app | Sempre |
| **docker-compose.yml** | Orquestra containers | Sempre |
| **nginx.conf** | Reverse proxy + SSL | Produção |
| **deploy.sh** | Deploy automático | Localhost |
| **quickstart.sh** | Guia interativo | Primeira vez |
| **.env.example** | Config de exemplo | Copiar para .env |

---

## 📊 Arquitetura

```
┌─────────────────────────────────────────┐
│         Internet (usuários)              │
└────────────────┬────────────────────────┘
                 │
                 ↓
        ┌────────────────┐
        │   Nginx (80)   │  ← Reverse proxy
        │  Nginx (443)   │  ← SSL/TLS
        └────────┬───────┘
                 │
                 ↓
        ┌────────────────┐
        │  Node.js App   │  ← CRM Vendas Pro
        │   (porta 3000) │
        └────────┬───────┘
                 │
                 ↓
        ┌────────────────┐
        │  SQLite DB     │  ← Banco de dados
        │ (volume Docker)│
        └────────────────┘
```

---

## ⚡ Quick Commands

```bash
# Iniciar tudo
docker-compose up -d

# Ver status
docker-compose ps

# Ver logs
docker-compose logs -f crm-app

# Parar
docker-compose down

# Atualizar
git pull && docker-compose build && docker-compose up -d

# Fazer backup
docker-compose exec crm-app cp /app/data/crm.sqlite /app/data/backup_$(date +%s).sqlite

# Restaurar
docker-compose exec crm-app cp /app/data/backup_123456.sqlite /app/data/crm.sqlite
docker-compose restart
```

---

## 🔐 Segurança - Passos Essenciais

1. **SSL/HTTPS**
   ```bash
   certbot certonly --standalone -d seu-dominio.com
   cp /etc/letsencrypt/live/seu-dominio.com/* ./ssl/
   ```

2. **Variáveis de Ambiente**
   ```bash
   cp .env.example .env
   # Editar .env com dados reais
   # NÃO commitar .env
   ```

3. **Backup**
   ```bash
   # Agendar no crontab
   0 2 * * * docker-compose exec crm-app cp /app/data/crm.sqlite /backups/backup_$(date +%Y%m%d).sqlite
   ```

4. **Firewall**
   ```bash
   # Abrir apenas portas necessárias
   sudo ufw allow 22/tcp  # SSH
   sudo ufw allow 80/tcp  # HTTP
   sudo ufw allow 443/tcp # HTTPS
   sudo ufw enable
   ```

---

## 📞 Acessando a Aplicação

### Local
```
http://localhost:3000
```

### Online (com domínio)
```
https://seu-dominio.com
http://seu-dominio.com (redireciona para HTTPS)
```

### IP do servidor
```
https://seu-ip-do-servidor
```

---

## 🏥 Health Check

```bash
# Verificar se app está saudável
curl http://localhost:3000/health

# Saída esperada:
# {"status":"OK"}
```

---

## 🆘 Problemas Comuns

| Problema | Solução |
|----------|---------|
| Porta já em uso | Mudar porta em docker-compose.yml |
| Banco não persiste | Verificar volume: `docker volume ls` |
| Aplicação não inicia | Ver logs: `docker-compose logs crm-app` |
| SSL não funciona | Certificados em `/ssl/cert.pem` e `/ssl/key.pem` |
| Nginx erro 502 | App caiu, ver: `docker-compose logs` |

---

## 📈 Performance

### Otimizações Já Implementadas

- ✅ Multi-stage build (reduz tamanho imagem)
- ✅ Alpine Linux (imagem menor)
- ✅ Cache HTTP em arquivos estáticos
- ✅ Gzip compression no Nginx
- ✅ Health checks automáticos

### Melhorias Futuras

- Migrar para PostgreSQL (se crescer)
- Adicionar Redis (cache)
- Implementar logging centralizado (ELK)
- Monitoramento (Prometheus + Grafana)

---

## 📚 Documentação

- **DEPLOY.md** - Guia completo e detalhado
- **DOCKER-EXAMPLES.md** - Exemplos avançados
- **CHECKLIST.md** - Itens para verificar
- **README.md** (principal) - Visão geral

---

## ✅ Próximas Ações

1. [ ] Ler DEPLOY.md completamente
2. [ ] Escolher plataforma (DigitalOcean, AWS, etc)
3. [ ] Executar deploy
4. [ ] Configurar domínio
5. [ ] Ativar SSL
6. [ ] Configurar backups
7. [ ] Monitorar logs

---

## 🎉 Parabéns!

Você tem tudo pronto para colocar seu CRM Vendas Pro online!

**Próximo passo:** Escolha uma plataforma e execute o deploy 🚀

```bash
# Teste local primeiro
./deploy.sh

# Depois escolha sua plataforma
./quickstart.sh
```

---

**Dúvidas? Consulte:**
- DEPLOY.md para instruções detalhadas
- DOCKER-EXAMPLES.md para exemplos avançados  
- CHECKLIST.md para não deixar nada para trás

**Boa sorte! 💪**
