# ✅ DEPLOY CHECKLIST - RENDER

## 🎯 FASE 1: PREPARAÇÃO LOCAL (5 min)

### 1.1 - Executar Setup
```
[ ] Windows:  powershell -ExecutionPolicy Bypass -File .\setup-render.ps1
[ ] Mac/Linux: bash setup-render.sh
[ ] Tudo passou ✓? (sem erros em vermelho)
```

**Resultado esperado:**
```
✅ SETUP CONCLUÍDO!
✓ Git configurado
✓ JWT_SECRET gerado
✓ render-env.txt criado
```

### 1.2 - Revisar Variáveis
```
[ ] Abrir arquivo: render-env.txt (criado na raiz)
[ ] Ver JWT_SECRET gerado
[ ] Copiar conteúdo para usar depois
```

**Arquivo render-env.txt deve conter:**
```
PORT=10000
HOST=0.0.0.0
NODE_ENV=production
DB_HOST=...
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=...
DB_NAME=crm_vendas_pro
JWT_SECRET=...
```

---

## 🐙 FASE 2: GITHUB (3 min)

### 2.1 - Criar Repositório
```
[ ] Ir em: https://github.com/new
[ ] Nome do repositório: crm-vendas-pro
[ ] Descrição: CRM com PostgreSQL + Render
[ ] Private ou Public? (sua escolha)
[ ] Não marque "Add README" (já tem)
[ ] Clique: Create repository
```

### 2.2 - Conectar & Push
**Opção A - Automático (recomendado):**
```
[ ] Mac/Linux: bash github-push.sh
[ ] Siga os prompts (cole a URL do repositório)
```

**Opção B - Manual:**
```bash
[ ] git remote add origin https://github.com/SEU_USUARIO/crm-vendas-pro.git
[ ] git branch -M main
[ ] git push -u origin main
```

**Resultado esperado:**
```
✓ Counting objects: ...
✓ Deltification: ...
✓ To https://github.com/SEU_USUARIO/crm-vendas-pro.git
✓ [new branch] main -> main
```

### 2.3 - Verificar
```
[ ] Ir em: https://github.com/SEU_USUARIO/crm-vendas-pro
[ ] Ver código no repositório
[ ] Ver arquivo: backend/server.js, db.js, etc.
```

---

## 🗄️ FASE 3: POSTGRESQL RENDER (5 min + 2-5 min espera)

### 3.1 - Criar Database
```
[ ] Ir em: https://render.com/dashboard
[ ] Fazer login ou criar conta
[ ] Clicar: New + (canto superior direito)
[ ] Selecionar: PostgreSQL
```

### 3.2 - Configurar Database
```
[ ] Name: crm-vendas-pro-db
[ ] Database: crm_vendas_pro
[ ] User: postgres
[ ] Region: Selecione mais próximo de você
[ ] Clicar: Create Database
[ ] ⏳ AGUARDE 2-5 MINUTOS
```

### 3.3 - Copiar Credenciais
Após database estar pronto:
```
[ ] No dashboard, ver a database criada
[ ] Clicar no nome: crm-vendas-pro-db
[ ] Copiar a connection string (URL completa)
[ ] Extrair informações:
    DB_HOST: xxx.db.onrender.com
    DB_USER: postgres
    DB_PASSWORD: xxxxxxxxxxxx
    DB_NAME: crm_vendas_pro
    DB_PORT: 5432
```

**Connection string exemplo:**
```
postgresql://postgres:xxxxx@crm-vendas-pro-db.xxxx.onrender.com:5432/crm_vendas_pro
```

**Extrair assim:**
- `postgres` = DB_USER
- `xxxxx` = DB_PASSWORD
- `crm-vendas-pro-db.xxxx.onrender.com` = DB_HOST
- `crm_vendas_pro` = DB_NAME
- `5432` = DB_PORT (sempre)

---

## 🌐 FASE 4: WEB SERVICE RENDER (5 min)

### 4.1 - Criar Web Service
```
[ ] No Render Dashboard
[ ] Clicar: New +
[ ] Selecionar: Web Service
[ ] Conectar repositório: crm-vendas-pro (GitHub)
[ ] ⏳ Pode pedir autorização do GitHub - autorize
```

### 4.2 - Configurar Build & Deploy
```
[ ] Name: crm-vendas-pro (ou outro nome único)
[ ] Region: Mesma do database
[ ] Branch: main
[ ] Build Command: npm install
[ ] Start Command: node backend/server.js
```

### 4.3 - Adicionar Variáveis de Ambiente
**IMPORTANTE: Antes de criar, faça isso:**

```
[ ] Scroll para baixo até "Environment"
[ ] Clicar: Add Environment Variable
[ ] Adicionar cada variável (ou pode copiar/colar tudo)
```

**Variáveis (copie do seu render-env.txt):**
```
PORT = 10000
HOST = 0.0.0.0
NODE_ENV = production
DB_HOST = [do PostgreSQL acima]
DB_PORT = 5432
DB_USER = postgres
DB_PASSWORD = [do PostgreSQL acima]
DB_NAME = crm_vendas_pro
JWT_SECRET = [do render-env.txt]
```

### 4.4 - Criar Service
```
[ ] Revisar todas as configurações ☝️
[ ] Clicar: Create Web Service
[ ] ⏳ AGUARDE 1-2 MINUTOS (deploy automático)
[ ] Ver mensagem: "deployed successfully"
```

### 4.5 - Verificar Deploy
```
[ ] No dashboard, clique no serviço criado
[ ] Vá para: Logs
[ ] Procure por uma dessas mensagens:
    ✓ "Servidor iniciado"
    ✓ "Tabelas criadas com sucesso"
    ✓ "Listening on port 10000"
```

**Se tiver erros vermelhos:**
```
[ ] Ver a mensagem de erro exata
[ ] Comum: "DATABASE CONNECTION FAILED"
    → Verifique variáveis de ambiente (DB_HOST, senha, etc)
[ ] Clique: Manual Deploy (para tentar novamente)
```

---

## 🧪 FASE 5: TESTES (5 min)

### 5.1 - Acessar Aplicação
```
[ ] No Render Dashboard, seu Web Service
[ ] Copie a URL (ex: https://crm-vendas-pro.onrender.com)
[ ] Abra no navegador
[ ] Deve aparecer: Login page
```

### 5.2 - Health Check
```bash
[ ] Terminal: curl https://SEU_URL/health
[ ] Deve retornar: {"status":"ok"} ou algo parecido
```

### 5.3 - Login Admin
```
[ ] Email: admin@crm.local
[ ] Senha: JL10@dez
[ ] Clique: Login
[ ] ✓ Deve entrar na dashboard
```

### 5.4 - Funcionalidades Básicas
```
[ ] Criar novo cliente (+ button)
[ ] Preencher dados e salvar
[ ] Listar clientes (deve aparecer na lista)
[ ] Criar venda ligada ao cliente
[ ] Exportar dados (deve baixar CSV)
```

### 5.5 - Verificar Database
```
[ ] No Render, vá em seu PostgreSQL
[ ] Botão: Connect → PSQL Browser
[ ] Execute:
    SELECT COUNT(*) FROM usuarios;  (deve ter admin)
    SELECT COUNT(*) FROM clientes;  (deve ter os que criou)
    SELECT COUNT(*) FROM vendas;    (deve ter as que criou)
```

---

## 🔐 FASE 6: SEGURANÇA (3 min)

### 6.1 - Mudar Senha Admin
```
[ ] Faça login como admin@crm.local / JL10@dez
[ ] Vá em: Configurações → Perfil (ou similar)
[ ] Campo: Mudar senha
[ ] Digite nova senha (forte!):
    Ex: M@t4H@rd2026!Pass
[ ] Confirme e salve
[ ] Faça logout e login de novo com nova senha
```

### 6.2 - Guardar Credenciais
```
[ ] Copie estas informações para local SEGURO:
    - JWT_SECRET (do render-env.txt)
    - Nova senha do admin
    - URL da aplicação
[ ] Considere usar gerenciador de senhas
```

### 6.3 - Verificar Logs
```
[ ] Render Dashboard → seu Web Service → Logs
[ ] Ver que não tem erros estranhos
[ ] Ver que está tudo rodando normal
```

---

## 📊 FASE 7: OTIMIZAÇÕES (opcional)

### 7.1 - Aumentar Timeouts (se tiver lentidão)
No Render Web Service → Settings:
```
[ ] Health Check: /health
[ ] Health Check Path: /health
[ ] Increase Timeout (se falhar muito)
```

### 7.2 - Auto-Deploy do GitHub
```
[ ] Render Web Service → Settings
[ ] "Auto-Deploy": enabled (deve estar)
[ ] Assim toda vez que fizer git push, atualiza
```

### 7.3 - Monitoramento
```
[ ] Verificar logs regularmente
[ ] Nota: Render não tem logs de longa duração (free plan)
[ ] Consider: Render paid plan se precisar
```

---

## ✅ CHECKLIST FINAL

```
✓ Setup local executado
✓ render-env.txt criado
✓ GitHub repositório criado
✓ Código fez push para GitHub
✓ PostgreSQL criado no Render
✓ Web Service criado no Render
✓ Variáveis de ambiente adicionadas
✓ Deploy completado com sucesso
✓ Aplicação acessível (URL funciona)
✓ Health check passa
✓ Admin consegue fazer login
✓ Pode criar clientes/vendas
✓ Senha do admin foi alterada
✓ Dados estão no PostgreSQL
```

---

## 🆘 ERROS COMUNS & SOLUÇÕES

| Erro | Causa | Solução |
|------|-------|--------|
| `Connection refused` | Database não respondendo | Aguarde + min, verify DB_HOST/password |
| `Cannot find module 'pg'` | npm install não rodou | Check: Build Command = `npm install` |
| `Invalid JWT_SECRET` | Não está setado | Copy JWT_SECRET do render-env.txt |
| `Login falha` | Senha errada ou admin não criado | Tente: `JL10@dez` exatamente |
| `CORS error` | Frontend em domínio diferente | Cookies configurados automaticamente |
| `504 Gateway Timeout` | Muito lento (free plan) | Upgrade plano ou optimize queries |

---

## 🎉 SUCESSO!

Se chegou aqui e tudo funcionou:

```
✅ CRM VENDAS PRO
✅ PostgreSQL Configurado
✅ Render Deployed
✅ Admin Login Funciona
✅ Dados Sincronizando
✅ Pronto para Uso!
```

**Próximas ações:**
1. Adicionar mais usuários/clientes/vendas
2. Testar funcionalidades
3. Treinar equipe
4. Considerar backup automático
5. Monitor performance

---

**Data:** 2026-01-14  
**Versão:** PostgreSQL v2.0.0  
**Plataforma:** Render.com  
**Status:** 🚀 PRONTO PARA PRODUÇÃO
