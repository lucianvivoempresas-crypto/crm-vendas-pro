# 🚀 DEPLOY RENDER - CRM VENDAS PRO

> Automação completa para deploy na plataforma Render com PostgreSQL

## 📋 Resumo do Que Foi Feito

```
✅ SQLite → PostgreSQL (migração completa)
✅ localStorage → Cookies + Server (segurança melhorada)
✅ IndexedDB → Server API (persistência centralizada)
✅ 14 rotas convertidas para async/await
✅ Autenticação com JWT (7 dias de expiração)
✅ Database auto-initialization na primeira execução
✅ 3 tabelas com índices e constraints
✅ Admin automático: admin@crm.local / JL10@dez
```

## 🎯 Próximos Passos

### 1️⃣ Executar Setup Automático

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File .\setup-render.ps1
```

**Mac/Linux (Bash):**
```bash
bash setup-render.sh
```

**O que isso faz:**
- ✓ Verifica Git, Node.js, npm
- ✓ Cria .gitignore
- ✓ Inicializa Git repository
- ✓ Gera JWT_SECRET seguro
- ✓ Verifica arquivos essenciais
- ✓ Faz commit automático
- ✓ Cria render-env.txt com variáveis

### 2️⃣ Conectar com GitHub

```bash
# Se não tiver remote configurado ainda:
git remote add origin https://github.com/SEU_USUARIO/crm-vendas-pro.git
git branch -M main
git push -u origin main

# Ou use o script:
bash github-push.sh
```

**Ou manualmente no GitHub:**
1. Vá em https://github.com/new
2. Crie repositório: `crm-vendas-pro`
3. Copie o comando `git remote add origin ...`
4. Execute no seu terminal

### 3️⃣ Criar PostgreSQL no Render

1. Vá em https://render.com
2. Entre na Dashboard
3. Clique em **New +** → **PostgreSQL**
4. Preenchha:
   - **Name**: `crm-vendas-pro-db`
   - **Database**: `crm_vendas_pro` (será criado)
   - **User**: `postgres` (padrão)
   - Deixe defaults para o resto
5. Clique **Create Database**
6. **Aguarde 2-5 minutos**
7. Copie a **connection string** (próximo passo)

### 4️⃣ Criar Web Service no Render

1. No Dashboard do Render
2. Clique em **New +** → **Web Service**
3. **Conectar repositório GitHub** (crm-vendas-pro)
4. Preenchha:
   - **Name**: `crm-vendas-pro` (ou outro nome único)
   - **Build Command**: `npm install`
   - **Start Command**: `node backend/server.js`
   - **Region**: Selecione mais próximo
5. **NÃO CLIQUE EM CREATE AINDA** → vá para passo 5

### 5️⃣ Adicionar Variáveis de Ambiente

1. Abra o arquivo **render-env.txt** (criado na raiz do projeto)
2. Copie o conteúdo
3. No Render, antes de criar o Web Service:
   - Seção **Environment Variables**
   - Cole cada variável (ou copie/cola tudo)
4. **IMPORTANTE:** Preencha estes campos do PostgreSQL:
   ```
   DB_HOST: [host do seu PostgreSQL do Render]
   DB_USER: postgres
   DB_PASSWORD: [password que criou]
   DB_NAME: crm_vendas_pro
   DB_PORT: 5432
   ```

5. Clique em **Create Web Service**
6. **Aguarde 1-2 minutos** para deploy

### 6️⃣ Verificar Deploy

```bash
# Health check (deve retornar 200 OK)
curl https://seu-servico.onrender.com/health

# Testar login (deve retornar token JWT)
curl -X POST https://seu-servico.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@crm.local","password":"JL10@dez"}'
```

**Ou veja os logs:**
1. Dashboard → seu Web Service
2. Clique em **Logs**
3. Procure por "Servidor iniciado" ou "Tabelas criadas com sucesso"

### 7️⃣ Primeiros Passos (IMPORTANTE!)

1. **Acessar aplicação:**
   ```
   URL: https://seu-servico.onrender.com
   Email: admin@crm.local
   Senha: JL10@dez
   ```

2. **Mudar senha do admin:**
   - Faça login
   - Vá em Configurações → Perfil
   - Altere a senha (use algo forte!)
   - **GUARDE A NOVA SENHA EM LOCAL SEGURO**

3. **Testar operações:**
   - Adicione um cliente
   - Crie uma venda
   - Exporte dados
   - Verifique se está sincronizando

## 🐛 Problemas Comuns

### "Erro: Connection Refused"
```
❌ Database não consegue conectar

✅ Solução:
  1. Verifique se PostgreSQL foi criado no Render (aguarde 5 min)
  2. Copie exatamente a URL do PostgreSQL
  3. Verifique as variáveis de ambiente
  4. Redeploy manual: Dashboard → Deploy → Manual
```

### "Tabelas não foram criadas"
```
❌ Database vazio

✅ Solução:
  1. Verifique os logs: Dashboard → Logs
  2. Procure por erros SQL
  3. Se não criou, execute manualmente:
     - Vá no Render Database
     - Clique em "Connect" → "PSQL"
     - Cole o conteúdo de db-schema.sql
```

### "Admin não consegue fazer login"
```
❌ Usuário admin não foi criado

✅ Solução:
  1. Verifique JWT_SECRET está setado
  2. Verifique senha: JL10@dez (exatamente)
  3. Aguarde 30s e tente novamente
  4. Se persistir, apague tabela usuarios:
     DROP TABLE usuarios;
     - Redeploy para recriar
```

### "CORS ou Cookie errors"
```
❌ Frontend não consegue comunicar com backend

✅ Solução:
  1. Verifique URL do backend no seu navegador
  2. Console do navegador → Application → Cookies
  3. Deve ter: auth_token com SameSite=Lax
  4. Se vazio, faça login novamente
```

## 📚 Documentação

- **DEPLOY_RENDER.md** - Guia completo passo a passo
- **RENDER_CHECKLIST.md** - Checklist interativa
- **RENDER_PRODUCAO.md** - Otimizações de produção
- **TROUBLESHOOTING.md** - Solução de problemas

## 🔐 Segurança

```
✅ Senhas: bcrypt 10 rounds
✅ JWT: 7 dias de expiração
✅ Queries: Parameterizadas (sem SQL injection)
✅ Cookies: SameSite=Lax para CSRF
✅ Database: Private no Render (sem acesso público)
✅ Secrets: JWT_SECRET via environment variables
```

## 📞 Suporte

Se tiver problemas:

1. **Leia a documentação** em TROUBLESHOOTING.md
2. **Veja os logs** no Render Dashboard
3. **Tente redeploy** manual
4. **Verifique credenciais** de conexão PostgreSQL

## ✅ Checklist Final

- [ ] Setup script executado sem erros
- [ ] GitHub repositório criado e conectado
- [ ] Código fez push para GitHub
- [ ] PostgreSQL criado no Render (aguardou inicialização)
- [ ] Web Service criado no Render
- [ ] Variáveis de ambiente adicionadas
- [ ] Deploy concluído (verificar logs)
- [ ] Acessou a aplicação com sucesso
- [ ] Fez login com admin@crm.local / JL10@dez
- [ ] Alterou a senha do admin
- [ ] Testou criar cliente/venda
- [ ] Testou sincronizar dados

---

**Status:** 🚀 Pronto para deploy!

**Última atualização:** 2026-01-14
**Versão:** PostgreSQL v2.0.0
**Ambiente:** Render.com
