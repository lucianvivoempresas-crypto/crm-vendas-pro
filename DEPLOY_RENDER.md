# 🚀 DEPLOY NO RENDER - Guia Completo

## ✅ PRÉ-REQUISITOS

- [x] Código atualizado para PostgreSQL (já feito!)
- [x] Conta no Render (https://render.com)
- [x] Repositório GitHub (git push)

---

## 📋 PASSO 1: Preparar Código para Render

### 1.1 Verificar package.json
```json
{
  "name": "crm-vendas-pro",
  "version": "2.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node server.js"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.10.0",
    "jsonwebtoken": "^9.0.0",
    "bcrypt": "^5.1.0"
  }
}
```

✅ Já está correto!

### 1.2 Criar .gitignore (se não tiver)
```bash
cat > .gitignore << 'EOF'
node_modules/
.env
.env.local
crm.sqlite
*.log
.DS_Store
EOF
```

### 1.3 Verificar server.js escuta em 0.0.0.0
```javascript
// ✅ Já está assim no seu código:
app.listen(PORT, '0.0.0.0', () => {
  console.log(`CRM Vendas Pro rodando em http://0.0.0.0:${PORT}`);
});
```

---

## 📍 PASSO 2: Fazer Push no GitHub

```bash
# 1. Ir para raiz do projeto
cd c:\crm-vendas-pro

# 2. Inicializar git (se não tiver)
git init

# 3. Adicionar todos os arquivos
git add .

# 4. Fazer commit
git commit -m "Migração SQLite para PostgreSQL v2.0.0"

# 5. Adicionar origem remota
git remote add origin https://github.com/SEU_USER/crm-vendas-pro.git

# 6. Fazer push
git branch -M main
git push -u origin main
```

Se já tem repositório:
```bash
git add .
git commit -m "Atualização: PostgreSQL, removido localStorage"
git push origin main
```

---

## 🔧 PASSO 3: Criar PostgreSQL no Render

### 3.1 Acessar Render
- Ir para: https://render.com
- Fazer login
- Dashboard → New +

### 3.2 Criar Database PostgreSQL
1. Clique **New +** → **PostgreSQL**
2. Preencha:
   - **Name:** crm-vendas-pro-db
   - **Database:** crm_vendas_pro
   - **User:** postgres
   - **Region:** São Paulo (ou sua região)
   - **PostgreSQL Version:** 15
3. Clique **Create Database**
4. **Aguarde 2-5 minutos** para criar
5. Copie a connection string quando ficar pronta

---

## 🌐 PASSO 4: Criar Web Service no Render

### 4.1 Criar novo serviço
1. Dashboard → New +
2. Selecione **Web Service**
3. Conecte seu repositório GitHub
4. Preencha:
   - **Name:** crm-vendas-pro
   - **Environment:** Node
   - **Region:** São Paulo
   - **Branch:** main
   - **Build Command:** `npm install`
   - **Start Command:** `node backend/server.js`

### 4.2 Configurar variáveis de ambiente
Antes de fazer deploy, vá em **Environment** e adicione:

```
PORT=10000
HOST=0.0.0.0
NODE_ENV=production

DB_HOST=seu-db-host.render.com
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=sua-senha-do-render
DB_NAME=crm_vendas_pro

JWT_SECRET=gere-uma-chave-segura-com-comando-abaixo
```

**Para gerar JWT_SECRET seguro:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Copie a saída e coloque em JWT_SECRET.

### 4.3 Copiar conexão PostgreSQL do Render
1. Vá na aba do banco de dados PostgreSQL que criou
2. Copie a connection string similar a:
   ```
   postgresql://postgres:senha@servidor.render.com:5432/crm_vendas_pro
   ```
3. Extraia os dados:
   - DB_HOST: `servidor.render.com`
   - DB_USER: `postgres`
   - DB_PASSWORD: `senha`
   - DB_NAME: `crm_vendas_pro`
   - DB_PORT: `5432`

---

## ⚙️ PASSO 5: Ajustar Código para Render

Seu code já está pronto, mas verifique:

### 5.1 Verificar db.js (já está OK)
```javascript
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'crm_vendas_pro',
});
```

### 5.2 Verificar server.js (já está OK)
```javascript
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || 'localhost';

app.listen(PORT, '0.0.0.0', () => {
  console.log(`CRM Vendas Pro rodando em http://0.0.0.0:${PORT}`);
});
```

---

## 🚀 PASSO 6: Fazer Deploy

### 6.1 Opção A: Deploy automático (recomendado)
```bash
# Fazer push no GitHub
git add .
git commit -m "Deploy no Render"
git push origin main
```

**O Render fará deploy automaticamente!**

### 6.2 Opção B: Deploy manual via Dashboard
1. Vá em **Dashboard**
2. Selecione o serviço `crm-vendas-pro`
3. Clique **Manual Deploy** → **Deploy latest commit**

---

## ✅ PASSO 7: Verificar Deploy

### 7.1 Ver logs
1. No Dashboard do serviço
2. Clique em **Logs**
3. Procure por:
   ```
   ✓ Tabelas criadas com sucesso
   ✓ Usuário admin criado automaticamente
   CRM Vendas Pro rodando em http://0.0.0.0:10000
   ```

### 7.2 Testar aplicação
```bash
# Health check
curl https://seu-servico.onrender.com/health

# Resultado esperado:
{"status":"OK"}
```

### 7.3 Testar login
```bash
curl -X POST https://seu-servico.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@crm.local","senha":"JL10@dez"}'
```

---

## 🆘 TROUBLESHOOTING RENDER

### Erro: "Cannot find module 'pg'"
**Solução:**
```bash
# Verifique que package.json tem pg
npm install pg

# Faça push novamente
git add package-lock.json
git commit -m "Update dependencies"
git push origin main
```

### Erro: "Database connection refused"
**Solução:**
1. Verifique credenciais em Environment variables
2. Aguarde 5 minutos após criar DB
3. Teste conexão local com: `psql -U postgres -h seu-host -d crm_vendas_pro`

### Erro: "Port already in use"
**Solução:** Render usa PORT 10000, já está configurado no código ✅

### Build fails
**Solução:**
1. Vá em **Build Logs**
2. Procure pela linha de erro
3. Verifique se package.json está correto
4. Teste localmente: `npm install && npm start`

---

## 📊 CHECKLIST FINAL

- [ ] Código no GitHub (git push)
- [ ] PostgreSQL criado no Render
- [ ] Web Service criado no Render
- [ ] Environment variables configuradas
- [ ] Build passou (sem erros)
- [ ] Logs mostram "Tabelas criadas"
- [ ] Health check funciona
- [ ] Login funciona

---

## 🔗 URL DE PRODUÇÃO

Após deploy bem-sucedido, seu CRM estará em:

```
https://seu-servico.onrender.com
```

Exemplo:
```
https://crm-vendas-pro.onrender.com
```

---

## 🔐 ÚLTIMAS CONFIGURAÇÕES

### 1. Mudar senha admin em produção
```bash
# Via SQL
psql -U postgres -h seu-db.render.com -d crm_vendas_pro
UPDATE usuarios SET senha = crypt('nova_senha_segura', gen_salt('bf'))
WHERE email = 'admin@crm.local';
\q
```

### 2. Configurar domínio customizado (opcional)
1. Vá em **Settings** do serviço no Render
2. **Custom Domain**
3. Aponte seu domínio para Render

### 3. Enable auto-deploy
1. **Settings** → **GitHub**
2. **Auto-deploy** = ON
3. Cada push no main fará deploy automático

---

## 📈 MONITORAMENTO

### Ver métricas
- Dashboard → Seu serviço
- Aba **Metrics**
- Veja: CPU, Memória, Banda

### Ver logs em tempo real
```bash
# Render oferece logs na web
# Ou via terminal (se tiver CLI)
# Clique em "Logs" no dashboard
```

---

## 💾 BACKUP DO BANCO

### Backup automático no Render
- Render faz backup diário
- Vá em Database → **Backups**

### Backup manual
```bash
# Via seu computador
pg_dump -U postgres -h seu-db.render.com -d crm_vendas_pro > backup.sql

# Restaurar
psql -U postgres -h seu-db.render.com -d crm_vendas_pro < backup.sql
```

---

## 🎯 RESUMO RÁPIDO

```bash
# 1. Preparar
git add .
git commit -m "PostgreSQL deployment"
git push origin main

# 2. Render Dashboard
# - Criar PostgreSQL
# - Criar Web Service
# - Adicionar Environment vars
# - Fazer deploy

# 3. Testar
curl https://seu-servico.onrender.com/health

# 4. Login
# https://seu-servico.onrender.com
# Email: admin@crm.local
# Senha: JL10@dez
```

---

## ❓ DÚVIDAS COMUNS

**P: Quanto custa?**
R: Render oferece free tier (limitado) e planos pagos. Database PostgreSQL começa em $15/mês.

**P: Quanto tempo demora?**
R: PostgreSQL: 2-5 min. Web Service: 1-2 min.

**P: Auto-deploy funciona?**
R: Sim! Configure em Settings → GitHub → Auto-deploy ON

**P: Dados são persistidos?**
R: Sim! PostgreSQL no Render persiste dados.

**P: Posso usar meu domínio?**
R: Sim! Settings → Custom Domain

---

**Versão:** 2.0.0 (Render Deploy)  
**Data:** 14/01/2026  
**Status:** ✅ Pronto para Deploy
