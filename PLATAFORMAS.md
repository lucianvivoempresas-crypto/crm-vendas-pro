# 🚀 GUIA RÁPIDO - Deploy por Plataforma

## 🔵 DigitalOcean (RECOMENDADO) ⭐⭐⭐⭐⭐

### Passo 1: Criar Droplet
```
1. Acessar: https://cloud.digitalocean.com
2. Clicar: Create → Droplets
3. Escolher:
   - Image: Ubuntu 22.04 LTS
   - Size: Basic $5/mês (suficiente)
   - Region: São Paulo (se possível)
4. Selecionar a chave SSH ou criar senha
5. Clicar: Create Droplet
6. Anotar o IP
```

### Passo 2: SSH no Droplet
```bash
ssh root@seu_ip_do_droplet
```

### Passo 3: Instalar Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### Passo 4: Instalar Docker Compose
```bash
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### Passo 5: Clonar Projeto
```bash
git clone https://github.com/seu-usuario/crm-vendas-pro.git
cd crm-vendas-pro
chmod +x deploy.sh
```

### Passo 6: Deploy
```bash
./deploy.sh
```

### Passo 7: Configurar Domínio
```
1. Registrar domínio (Namecheap, etc)
2. Apontar Nameservers para DigitalOcean
   - ns1.digitalocean.com
   - ns2.digitalocean.com
   - ns3.digitalocean.com
3. No painel DigitalOcean > Networking > Domains
4. Adicionar domínio
5. Criar record A: @ → seu_ip_do_droplet
6. Aguardar 24h (ou menos)
```

### Passo 8: Configurar SSL
```bash
sudo apt-get update
sudo apt-get install certbot
sudo certbot certonly --standalone -d seu-dominio.com -d www.seu-dominio.com

# Copiar certificados
sudo mkdir -p /root/crm-vendas-pro/ssl
sudo cp /etc/letsencrypt/live/seu-dominio.com/fullchain.pem /root/crm-vendas-pro/ssl/cert.pem
sudo cp /etc/letsencrypt/live/seu-dominio.com/privkey.pem /root/crm-vendas-pro/ssl/key.pem

# Dar permissão
sudo chown -R root:root /root/crm-vendas-pro/ssl
sudo chmod 644 /root/crm-vendas-pro/ssl/cert.pem
sudo chmod 600 /root/crm-vendas-pro/ssl/key.pem

# Reiniciar Nginx
docker-compose restart nginx
```

### Passo 9: Renovação Automática SSL
```bash
sudo crontab -e

# Adicionar linha:
0 3 * * * certbot renew --quiet && cp /etc/letsencrypt/live/seu-dominio.com/fullchain.pem /root/crm-vendas-pro/ssl/cert.pem && cp /etc/letsencrypt/live/seu-dominio.com/privkey.pem /root/crm-vendas-pro/ssl/key.pem && cd /root/crm-vendas-pro && docker-compose restart nginx
```

### Pronto! 🎉
```
Acesse: https://seu-dominio.com
```

---

## 🔴 AWS EC2

### Passo 1: Criar Instância
```
1. AWS Console: https://console.aws.amazon.com/ec2
2. Launch Instance
3. Escolher: Ubuntu 22.04 LTS
4. Instance Type: t3.micro (gratuito) ou t3.small
5. Security Group: Abrir portas
   - 22 (SSH)
   - 80 (HTTP)
   - 443 (HTTPS)
6. Launch
```

### Passo 2: SSH
```bash
ssh -i sua-chave.pem ec2-user@ip-da-instancia
```

### Passo 3-8: Igual ao DigitalOcean
(Mesmos comandos de Docker, Git, SSL, etc)

### Dica: Elastic IP
```
1. AWS Console > Elastic IPs
2. Allocate Address
3. Associate com sua instância
4. Assim o IP não muda ao reiniciar
```

---

## 🟣 Heroku

### Passo 1: Instalar Heroku CLI
```bash
# No seu computador local
curl https://cli-assets.heroku.com/install.sh | sh
```

### Passo 2: Login
```bash
heroku login
```

### Passo 3: Criar App
```bash
cd crm-vendas-pro
heroku create seu-app-crm
```

### Passo 4: Configurar Dockerfile
```bash
# Heroku lê automaticamente Dockerfile
# Se não funcionar, adicionar:
heroku stack:set container
```

### Passo 5: Deploy
```bash
git push heroku main
```

### Passo 6: Conectar Domínio
```bash
heroku domains:add seu-dominio.com
# Configurar DNS conforme instruções
```

### ⚠️ Nota sobre Heroku
```
- Banco SQLite não persiste entre deploys
- Use PostgreSQL Add-on se precisar (pago)
- Free tier: dorme após 30 min de inatividade
```

---

## 🟢 Render.com (MUITO SIMPLES)

### Passo 1: Conectar GitHub
```
1. Acessar: https://render.com
2. Clicar: New → Web Service
3. Conectar repositório GitHub
```

### Passo 2: Configurar
```
- Name: seu-app-crm
- Runtime: Docker
- Branch: main
- Build Command: (deixar vazio)
- Start Command: (deixar vazio)
```

### Passo 3: Environment Variables
```
NODE_ENV=production
DATABASE_PATH=/app/data/crm.sqlite
```

### Passo 4: Deploy
```
Clicar: Create Web Service
Render faz deploy automático
```

### Passo 5: Acesso
```
Seu app estará em: https://seu-app-crm.onrender.com
```

### Conectar Domínio
```
1. Render Dashboard > Seu App
2. Settings > Custom Domain
3. Configurar DNS apontando para Render
```

---

## 🟡 Railway.app (MUITO SIMPLES)

### Passo 1: Conectar GitHub
```
1. Acessar: https://railway.app
2. Login com GitHub
3. New Project → Deploy from GitHub
4. Selecionar repositório
```

### Passo 2: Configurar (automático)
```
Railway detecta Docker automaticamente
```

### Passo 3: Environment
```
NODE_ENV=production
DATABASE_PATH=/app/data/crm.sqlite
```

### Passo 4: Deploy
```
Railway faz deploy automático ao fazer push
```

### Acesso
```
Seu app estará em: seu-projeto-random.railway.app
```

---

## 📊 Comparação Rápida

| Plataforma | Setup | Custo | SSL | Domínio | Escalabilidade |
|-----------|-------|-------|-----|---------|-----------------|
| DigitalOcean | Médio | $5+ | Let's Encrypt | ✅ | ⭐⭐⭐⭐ |
| AWS | Complexo | $5+ | Let's Encrypt | ✅ | ⭐⭐⭐⭐⭐ |
| Heroku | Fácil | Grátis | ✅ | ✅ | ⭐⭐⭐ |
| Render | Muito Fácil | Grátis | ✅ | ✅ | ⭐⭐⭐ |
| Railway | Muito Fácil | Grátis | ✅ | ✅ | ⭐⭐⭐ |

---

## 🎯 Qual Escolher?

### Se quer controle total
→ **DigitalOcean ou AWS**

### Se quer simplicidade
→ **Render.com ou Railway.app**

### Se quer opção intermediária
→ **Heroku**

### Se quer começar AGORA (gratuito)
→ **Railway.app**

---

## ✅ Checklist Geral (Qualquer Plataforma)

- [ ] Projeto está no GitHub
- [ ] Dockerfile está pronto (✅ criado)
- [ ] docker-compose.yml está pronto (✅ criado)
- [ ] .env.example existe (✅ criado)
- [ ] Conta criada na plataforma
- [ ] Domínio comprado (opcional para teste)
- [ ] Deploy realizado
- [ ] Aplicação está rodando
- [ ] SSL configurado
- [ ] Backups automáticos configurados
- [ ] Go live! 🎉

---

## 🆘 Troubleshooting

### Erro: Port already in use
```bash
# DigitalOcean/AWS: Mudar porta no docker-compose.yml
# Render/Railway: Usar porta $PORT (automático)
```

### Erro: Build failure
```bash
# Ver logs
docker logs $(docker ps -q)

# Ou na plataforma: Build Logs
```

### Banco não carrega
```bash
# Verificar volume
docker volume ls

# Restaurar backup
docker-compose exec crm-app cp /app/data/backup_*.sqlite /app/data/crm.sqlite
```

---

## 📞 Suporte

- DigitalOcean: https://docs.digitalocean.com/
- AWS: https://docs.aws.amazon.com/
- Heroku: https://devcenter.heroku.com/
- Render: https://render.com/docs
- Railway: https://docs.railway.app/

---

**Qual plataforma você escolheu? Parabéns pelo próximo passo! 🚀**
