# 🚀 CRM Vendas Pro - Guia de Deploy com Docker

## 📋 Pré-requisitos

Antes de começar, você precisa ter instalado:

1. **Docker** - [Download aqui](https://docs.docker.com/install/)
2. **Docker Compose** - [Download aqui](https://docs.docker.com/compose/install/)
3. **Git** (opcional, para clonar o repositório)

### Verificar instalação

```bash
docker --version
docker-compose --version
```

---

## 🌍 Deploy Online - Opções

### Opção 1: Usar o Script de Deploy (Recomendado)

```bash
# Navegar até o diretório do projeto
cd /caminho/para/crm-vendas-pro

# Tornar o script executável (Linux/Mac)
chmod +x deploy.sh

# Executar o script
./deploy.sh
```

### Opção 2: Deploy Manual com Docker Compose

```bash
# 1. Navegar até o diretório do projeto
cd /caminho/para/crm-vendas-pro

# 2. Criar arquivo .env (copiar do exemplo)
cp .env.example .env

# 3. Editar variáveis de ambiente (opcional)
nano .env

# 4. Build da imagem
docker-compose build

# 5. Iniciar containers
docker-compose up -d

# 6. Verificar status
docker-compose ps

# 7. Ver logs
docker-compose logs -f crm-app
```

---

## 🔧 Configuração para Produção

### 1. Usar um VPS/Servidor Cloud

Opções recomendadas:
- **DigitalOcean** - Droplets (App Platform)
- **AWS EC2** - (t3.small ou similar)
- **Azure Container Instances**
- **Google Cloud Run**
- **Heroku** - (com suporte a Docker)
- **Render** ou **Railway** - Alternativas mais simples

### 2. Configurar Domínio e SSL

#### Com Let's Encrypt (Gratuito)

```bash
# 1. Instalar Certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# 2. Gerar certificado
sudo certbot certonly --standalone -d seu-dominio.com -d www.seu-dominio.com

# 3. Copiar certificados para o container
sudo cp /etc/letsencrypt/live/seu-dominio.com/fullchain.pem ./ssl/cert.pem
sudo cp /etc/letsencrypt/live/seu-dominio.com/privkey.pem ./ssl/key.pem

# 4. Reiniciar nginx
docker-compose restart nginx
```

#### Renovação Automática

```bash
# Adicionar ao crontab
sudo crontab -e

# Adicionar linha:
0 3 * * * certbot renew --quiet && cp /etc/letsencrypt/live/seu-dominio.com/fullchain.pem /path/to/ssl/cert.pem && cp /etc/letsencrypt/live/seu-dominio.com/privkey.pem /path/to/ssl/key.pem && docker-compose restart nginx
```

### 3. Backup Automático do Banco de Dados

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backups/crm-vendas-pro"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup do banco de dados
docker-compose exec -T crm-app cp /app/data/crm.sqlite /app/data/crm_backup_$TIMESTAMP.sqlite

# Copiar para fora do container
docker cp crm-vendas-pro:/app/data/crm_backup_$TIMESTAMP.sqlite $BACKUP_DIR/

# Manter apenas últimos 30 dias
find $BACKUP_DIR -name "crm_backup_*.sqlite" -mtime +30 -delete

echo "Backup realizado: crm_backup_$TIMESTAMP.sqlite"
```

Agendar no crontab:
```bash
0 2 * * * /path/to/backup.sh
```

### 4. Monitoramento

#### Ver Logs

```bash
# Logs em tempo real
docker-compose logs -f crm-app

# Logs do Nginx
docker-compose logs -f nginx

# Últimas 100 linhas
docker-compose logs --tail=100 crm-app
```

#### Verificar Saúde

```bash
# Health check
curl http://localhost:3000/health

# Status dos containers
docker-compose ps
```

---

## 📱 Acessar Aplicação

### Local
```
http://localhost:3000
```

### Online (com domínio)
```
https://seu-dominio.com
```

---

## 🛠️ Comandos Úteis

### Gerenciar Containers

```bash
# Iniciar
docker-compose up -d

# Parar
docker-compose down

# Reiniciar
docker-compose restart

# Reiniciar serviço específico
docker-compose restart crm-app

# Ver status
docker-compose ps

# Ver logs
docker-compose logs -f crm-app
```

### Banco de Dados

```bash
# Acessar container
docker-compose exec crm-app sh

# Dentro do container, ver banco de dados
ls -lh /app/data/

# Backup manual
docker-compose exec crm-app cp /app/data/crm.sqlite /app/data/backup_$(date +%s).sqlite
```

### Atualizar Aplicação

```bash
# 1. Puxar novo código
git pull

# 2. Reconstruir imagem
docker-compose build

# 3. Reiniciar containers
docker-compose up -d

# 4. Verificar logs
docker-compose logs -f crm-app
```

---

## 🚨 Troubleshooting

### Porta já em uso

```bash
# Mudar porta no docker-compose.yml
# De: "3000:3000"
# Para: "8080:3000"

docker-compose down
docker-compose up -d
```

### Banco de dados não persiste

```bash
# Verificar volume
docker volume ls | grep crm

# Verificar dados
docker volume inspect crm-vendas-pro_crm-data
```

### Aplicação não inicia

```bash
# Ver logs detalhados
docker-compose logs crm-app

# Verificar se porta está livre
lsof -i :3000

# Reiniciar tudo do zero
docker-compose down -v
docker-compose up -d
```

### Problema de permissões

```bash
# Dar permissão ao script
chmod +x deploy.sh

# Executar com sudo se necessário
sudo ./deploy.sh
```

---

## 📊 Estrutura de Volumes

```
crm-vendas-pro_crm-data/
├── crm.sqlite          # Banco de dados principal
├── crm_backup_*.sqlite # Backups automáticos
└── ...
```

---

## 🔒 Segurança

### Checklist de Segurança

- ✅ Usar HTTPS em produção (Let's Encrypt)
- ✅ Configurar firewall (apenas portas 80, 443)
- ✅ Fazer backups regulares
- ✅ Manter Docker atualizado
- ✅ Usar variáveis de ambiente para secrets
- ✅ Limitar recursos do container
- ✅ Usar política de restart

### Limitar Recursos

No `docker-compose.yml`, adicione:

```yaml
services:
  crm-app:
    # ... outras configs ...
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

---

## 📞 Suporte

Em caso de problemas:

1. Verifique os logs: `docker-compose logs crm-app`
2. Verifique a saúde: `curl http://localhost:3000/health`
3. Verifique espaço em disco: `docker system df`
4. Limpe recursos não utilizados: `docker system prune`

---

## 📝 Notas Importantes

- O banco SQLite está no volume `crm-data` (persistente)
- O Nginx atua como reverse proxy (recomendado para produção)
- SSL é configurável via Let's Encrypt
- Backups devem ser feitos regularmente
- Monitorar logs é importante para detectar problemas

---

**CRM Vendas Pro - Online com Docker! 🎉**
