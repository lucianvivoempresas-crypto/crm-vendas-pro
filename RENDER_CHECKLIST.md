# ✅ CHECKLIST DEPLOY RENDER - Passo a Passo

## 1️⃣ PREPARAÇÃO LOCAL

```bash
# Ir para pasta do projeto
cd c:\crm-vendas-pro

# Verificar se tem git iniciado
git status

# Se não tiver, inicializar
git init
git config user.email "seu@email.com"
git config user.name "Seu Nome"
```

### ✓ Verificar arquivos necessários
- [x] `backend/server.js` → ✅ Atualizado
- [x] `backend/db.js` → ✅ Criado
- [x] `backend/package.json` → ✅ Atualizado
- [x] `backend/.env.example` → ✅ Criado
- [x] `.gitignore` → Se não tiver, criar

### ✓ Se não tiver .gitignore, criar:
```bash
cat > .gitignore << 'EOF'
node_modules/
.env
.env.local
crm.sqlite
*.log
.DS_Store
EOF

git add .gitignore
git commit -m "Add gitignore"
```

---

## 2️⃣ ENVIAR PARA GITHUB

```bash
# 1. Adicionar todos os arquivos
git add .

# 2. Fazer commit
git commit -m "Migração SQLite→PostgreSQL v2.0.0"

# 3. Se repo não existe, criar no github.com
# - Novo repositório chamado: crm-vendas-pro
# - Copie a URL do repositório

# 4. Adicionar origem
git remote add origin https://github.com/SEU_USER/crm-vendas-pro.git

# 5. Renomear branch se necessário
git branch -M main

# 6. Fazer push
git push -u origin main
```

✅ **Arquivos agora estão no GitHub!**

---

## 3️⃣ CRIAR POSTGRESQL NO RENDER

Vá para https://render.com

1. Fazer login/criar conta
2. Dashboard → **New +**
3. Selecionar **PostgreSQL**

Preencher:
```
Name: crm-vendas-pro-db
Database: crm_vendas_pro
User: postgres
Region: São Paulo (ou sua região)
PostgreSQL Version: 15
```

4. Clique **Create Database**
5. **⏳ Aguardar 2-5 minutos**
6. Quando pronto, copiar a **Connection String**

Será algo como:
```
postgresql://postgres:SENHA@SERVIDOR.render.com:5432/crm_vendas_pro
```

---

## 4️⃣ CRIAR WEB SERVICE NO RENDER

1. Dashboard → **New +**
2. Selecionar **Web Service**
3. Conectar GitHub
   - Autorizar Render
   - Selecionar repositório: `crm-vendas-pro`
4. Preencher:
```
Name: crm-vendas-pro
Environment: Node
Region: São Paulo
Branch: main
Root Directory: (deixar vazio)
Build Command: npm install
Start Command: node backend/server.js
```

5. **Não clicar em Deploy ainda!** Precisamos de environment vars

---

## 5️⃣ ADICIONAR VARIÁVEIS DE AMBIENTE

Antes de fazer deploy, vá em **Environment** e adicione cada uma:

### Extrair dados da connection string:
Se sua connection string é:
```
postgresql://postgres:abc123def@oregon.render.com:5432/crm_vendas_pro
```

Então:
- DB_HOST = `oregon.render.com`
- DB_USER = `postgres`
- DB_PASSWORD = `abc123def`
- DB_NAME = `crm_vendas_pro`
- DB_PORT = `5432`

### Gerar JWT_SECRET seguro:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Copie a saída (será uma string hex longa)

### Adicionar no Render:
Clique **Add Environment Variable** para cada uma:

| Key | Value |
|-----|-------|
| PORT | 10000 |
| HOST | 0.0.0.0 |
| NODE_ENV | production |
| DB_HOST | oregon.render.com |
| DB_PORT | 5432 |
| DB_USER | postgres |
| DB_PASSWORD | abc123def |
| DB_NAME | crm_vendas_pro |
| JWT_SECRET | (sua chave gerada) |

✅ **Salvar após cada uma!**

---

## 6️⃣ FAZER DEPLOY

Opção A - Deploy Automático:
```bash
git add .
git commit -m "Ready to deploy"
git push origin main
```

Render fará deploy automaticamente!

Opção B - Deploy Manual:
1. Dashboard → `crm-vendas-pro`
2. Clique **Manual Deploy**
3. Selecione **Deploy latest commit**

⏳ **Aguardar 2-3 minutos para build completar**

---

## 7️⃣ VERIFICAR DEPLOY

### Verificar logs:
1. Vá em **Logs** (no dashboard do serviço)
2. Procure por:
   ```
   ✓ Tabelas criadas com sucesso
   ✓ Usuário admin criado automaticamente
   CRM Vendas Pro rodando em http://0.0.0.0:10000
   ```

### Se ver errros:
Procure a mensagem de erro nos logs e procure em `DEPLOY_RENDER.md` na seção TROUBLESHOOTING.

---

## 8️⃣ TESTAR APLICAÇÃO

### Health check:
```bash
curl https://crm-vendas-pro.onrender.com/health
```

Resposta esperada:
```json
{"status":"OK"}
```

### Testar login:
1. Abra no navegador:
   ```
   https://crm-vendas-pro.onrender.com
   ```

2. Faça login:
   - Email: `admin@crm.local`
   - Senha: `JL10@dez`

3. Se funcionar, **parabéns!** ✅

### Se não funcionar:
Volte aos logs e procure a mensagem de erro.

---

## 9️⃣ PÓS-DEPLOY

### Mudar senha admin:
```bash
# Conectar ao banco Render
psql postgresql://postgres:SENHA@SERVIDOR.render.com:5432/crm_vendas_pro

# Mudar senha
UPDATE usuarios 
SET senha = crypt('NOVA_SENHA_SEGURA', gen_salt('bf'))
WHERE email = 'admin@crm.local';

# Sair
\q
```

### Ativar auto-deploy:
1. Settings → GitHub
2. Auto-deploy: **ON**
3. Agora cada `git push` faz deploy automático!

### Configurar domínio customizado (opcional):
1. Settings → Custom Domain
2. Adicione seu domínio
3. Configure DNS no seu registrador

---

## 📋 VERIFICAÇÃO FINAL

Todos os itens devem estar ✅

- [ ] Código no GitHub
- [ ] PostgreSQL criado no Render
- [ ] Web Service criado no Render
- [ ] Todas as 8 environment variables adicionadas
- [ ] Deploy completou sem erros
- [ ] Logs mostram "Tabelas criadas"
- [ ] Health check retorna OK
- [ ] Login funciona
- [ ] Dados persistem após refresh
- [ ] Senha admin foi mudada

---

## 🎯 RESUMO

Você agora tem:

```
https://crm-vendas-pro.onrender.com
```

Com:
- ✅ PostgreSQL online
- ✅ Backend Node.js
- ✅ Autenticação funcionando
- ✅ Dados persistindo
- ✅ HTTPS automático
- ✅ Auto-deploy ativado

---

## 🆘 PROBLEMAS?

Se algo não funcionar:

1. Leia os logs no dashboard
2. Procure a mensagem de erro em `DEPLOY_RENDER.md`
3. Se não encontrar, verifique:
   - Environment variables corretas
   - GitHub token autorizado
   - Build command: `npm install`
   - Start command: `node backend/server.js`

---

**Pronto para deploy!** 🚀
