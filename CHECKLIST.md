# ✅ Docker - Checklist de Deploy

## 📦 Arquivos Criados

- [x] `Dockerfile` - Imagem Docker da aplicação
- [x] `docker-compose.yml` - Orquestração de containers
- [x] `.dockerignore` - Arquivos a ignorar no build
- [x] `nginx.conf` - Configuração do reverse proxy
- [x] `.env.example` - Variáveis de ambiente de exemplo
- [x] `deploy.sh` - Script de deploy automático
- [x] `quickstart.sh` - Script de seleção de plataforma
- [x] `DEPLOY.md` - Guia completo de deploy
- [x] `DOCKER-EXAMPLES.md` - Exemplos de configurações

## 🚀 Quick Start

### 1️⃣ Teste Local

```bash
# Navegar até o diretório
cd /caminho/para/crm-vendas-pro

# Tornar scripts executáveis
chmod +x deploy.sh quickstart.sh

# Executar deploy
./deploy.sh

# Acessar
# http://localhost:3000
```

### 2️⃣ Deploy Online

Escolha uma plataforma:

#### Option A: DigitalOcean (Recomendado)

```bash
# 1. Criar Droplet Ubuntu 22.04
# 2. SSH no servidor
ssh root@seu_ip

# 3. Executar setup
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
curl -L https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 4. Clonar e deploy
git clone seu-repo crm && cd crm
chmod +x deploy.sh && ./deploy.sh

# 5. Configurar domínio no painel DigitalOcean
```

#### Option B: AWS EC2

```bash
# Similar ao DigitalOcean
# Use instância t3.small ou t3.micro
# Abra ports: 22, 80, 443 no Security Group
```

#### Option C: Render.com

```bash
# Plataforma cloud simples
# 1. Conectar repositório GitHub
# 2. Selecionar "Docker"
# 3. Configurar variáveis de ambiente
# 4. Deploy automático
```

#### Option D: Railway.app

```bash
# Similar ao Render
# Muito simples para começar
```

## 🔧 Configuração

### Variáveis de Ambiente

Copiar `.env.example` para `.env`:

```bash
cp .env.example .env
nano .env  # editar com seus valores
```

Principais variáveis:
- `NODE_ENV=production`
- `DATABASE_PATH=/app/data/crm.sqlite`
- `PORT=3000`
- `DOMAIN=seu-dominio.com`

### SSL/HTTPS com Let's Encrypt

```bash
# Instalar Certbot
sudo apt-get install certbot

# Gerar certificado
sudo certbot certonly --standalone -d seu-dominio.com

# Copiar para o container
sudo cp /etc/letsencrypt/live/seu-dominio.com/fullchain.pem ./ssl/cert.pem
sudo cp /etc/letsencrypt/live/seu-dominio.com/privkey.pem ./ssl/key.pem

# Reiniciar
docker-compose restart nginx
```

### Backup do Banco de Dados

```bash
# Backup manual
docker-compose exec crm-app cp /app/data/crm.sqlite /app/data/backup_$(date +%s).sqlite

# Copiar para host
docker cp crm-vendas-pro:/app/data/backup_*.sqlite ./backups/
```

Agendar backup automático:

```bash
# Criar script backup.sh
#!/bin/bash
BACKUP_DIR="/caminho/backups"
mkdir -p $BACKUP_DIR
docker-compose exec -T crm-app cp /app/data/crm.sqlite $BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sqlite
find $BACKUP_DIR -name "backup_*.sqlite" -mtime +30 -delete

# Agendar no crontab (todos os dias às 2 da manhã)
0 2 * * * /path/to/backup.sh
```

## 📊 Comandos Úteis

### Status

```bash
# Ver containers
docker-compose ps

# Ver logs em tempo real
docker-compose logs -f crm-app

# Verificar saúde
curl http://localhost:3000/health
```

### Gerenciar

```bash
# Iniciar
docker-compose up -d

# Parar
docker-compose down

# Reiniciar
docker-compose restart

# Remover tudo (cuidado!)
docker-compose down -v
```

### Atualizar Aplicação

```bash
# 1. Puxar novo código
git pull

# 2. Reconstruir
docker-compose build --no-cache

# 3. Reiniciar
docker-compose up -d

# 4. Ver logs
docker-compose logs -f
```

### Acessar Container

```bash
# Terminal no container
docker-compose exec crm-app sh

# Dentro do container:
ls -lh /app/data/           # Ver banco de dados
cat /app/data/crm.sqlite    # Verificar banco
```

## 🔒 Segurança

### Checklist

- [ ] HTTPS/SSL configurado
- [ ] Firewall configurado (portas 80, 443, 22)
- [ ] Backups automáticos ativados
- [ ] Logs sendo monitorados
- [ ] Docker atualizado
- [ ] `.env` não está no repositório (use .gitignore)
- [ ] Senhas fortes nas variáveis de ambiente
- [ ] Limites de recursos configurados

### Proteger .env

```bash
# Adicionar ao .gitignore
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore

# Nunca commitar:
git rm --cached .env
```

## 🐛 Troubleshooting

### Aplicação não inicia

```bash
# Ver logs detalhados
docker-compose logs crm-app

# Verificar se porta está em uso
lsof -i :3000

# Reiniciar tudo
docker-compose down -v
docker-compose up -d
```

### Banco de dados não persiste

```bash
# Verificar volume
docker volume ls | grep crm-data

# Inspecionar
docker volume inspect crm-vendas-pro_crm-data

# Recuperar backup
docker-compose cp backups/backup_123456.sqlite - > /tmp/restore.sqlite
```

### Problemas com permissão

```bash
# Dar permissão
chmod +x deploy.sh
chmod +x quickstart.sh

# Executar como sudo se necessário
sudo ./deploy.sh
```

### Porta já em uso

```bash
# No docker-compose.yml, mudar:
# "3000:3000" para "8080:3000"

# Ou parar o que está usando:
lsof -i :3000  # ver processo
kill -9 PID    # matar processo
```

## 📈 Escalabilidade

Para mais usuários, considere:

1. **PostgreSQL** em vez de SQLite
   - Melhor para múltiplos acessos simultâneos
   - Backups mais seguros
   - Replicação possível

2. **Redis** para cache
   - Sessões de usuário
   - Cache de consultas
   - Fila de tarefas

3. **Load Balancer**
   - Múltiplas instâncias da app
   - Nginx como LB
   - AWS Load Balancer

4. **CDN**
   - Cloudflare (gratuito)
   - AWS CloudFront
   - Akamai

## 📚 Recursos Úteis

- Docker Docs: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- DigitalOcean Tutorials: https://www.digitalocean.com/community/tutorials
- Let's Encrypt: https://letsencrypt.org/
- Nginx: https://nginx.org/

## 🎯 Próximos Passos

1. ✅ Criar conta em plataforma cloud (DigitalOcean, AWS, etc)
2. ✅ Comprar domínio
3. ✅ Configurar DNS
4. ✅ Executar deploy
5. ✅ Configurar SSL
6. ✅ Configurar backups
7. ✅ Monitorar aplicação

## 📞 Suporte

Se tiver problemas:

1. Verificar logs: `docker-compose logs`
2. Verificar saúde: `curl http://localhost:3000/health`
3. Verificar espaço: `docker system df`
4. Limpar: `docker system prune`

---

**Parabéns! Seu CRM está pronto para o mundo! 🌍**
