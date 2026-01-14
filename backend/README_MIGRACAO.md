# 🚀 CRM Vendas Pro - Migração PostgreSQL Concluída

## 📌 O que foi alterado

### Backend
- ✅ **Migração SQLite → PostgreSQL** - Banco de dados agora usa PostgreSQL em vez de arquivos locais
- ✅ **Remoção de localStorage** - Sem mais salvamento de dados locais
- ✅ **Async/Await com Pool de Conexões** - Melhor performance e escalabilidade
- ✅ **Nova estrutura de banco** com tabelas e índices otimizados
- ✅ Arquivo `db.js` criado com configuração PostgreSQL

### Frontend
- ✅ **Removido localStorage** - Dados não são mais salvos localmente
- ✅ **Removido IndexedDB** - Sincronização apenas com servidor
- ✅ **Autenticação via Cookies** - Token armazenado em cookie seguro
- ✅ `auth-frontend.js` atualizado
- ✅ `sync-frontend.js` refatorizado para servidor apenas

## 🔧 Instalação Rápida

### 1️⃣ Pré-requisitos
```powershell
# Instalar PostgreSQL
choco install postgresql

# Ou baixe em: https://www.postgresql.org/download/
```

### 2️⃣ Criar Banco de Dados
```sql
CREATE DATABASE crm_vendas_pro;
```

### 3️⃣ Configurar Ambiente
```powershell
cd backend

# Copiar arquivo de exemplo
cp .env.example .env

# Editar .env com suas credenciais PostgreSQL
```

### 4️⃣ Instalar Dependências
```powershell
npm install
```

### 5️⃣ Iniciar Servidor
```powershell
npm start
```

## 📊 Estrutura do Banco PostgreSQL

### Tabelas Criadas Automaticamente:

**usuarios**
- id (SERIAL PRIMARY KEY)
- email (VARCHAR UNIQUE)
- cpf (VARCHAR UNIQUE)
- senha (VARCHAR - bcrypt)
- nome (VARCHAR)
- role (VARCHAR - 'admin' ou 'user')
- criado_em (TIMESTAMP)

**clientes**
- id (SERIAL PRIMARY KEY)
- usuario_id (FOREIGN KEY)
- nome, telefone, email
- criado_em (TIMESTAMP)

**vendas**
- id (SERIAL PRIMARY KEY)
- usuario_id (FOREIGN KEY)
- produto, valor, comissao
- data (TIMESTAMP)
- criado_em (TIMESTAMP)

## 🔐 Segurança

- ✅ Senhas com bcrypt (10 rounds)
- ✅ JWT para autenticação (7 dias expiry)
- ✅ Cookies com SameSite=Lax
- ✅ Validação em todas as rotas
- ⚠️ **Mudar JWT_SECRET em produção!**

```bash
# Gerar novo JWT_SECRET
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## 🎯 Dados de Acesso Padrão

| Campo | Valor |
|-------|-------|
| Email | admin@crm.local |
| CPF | 02850697567 |
| Senha | JL10@dez |

**⚠️ MUDAR SENHA DO ADMIN APÓS PRIMEIRO LOGIN!**

## 📡 API Endpoints

### Autenticação
```
POST /api/auth/register    # Registrar novo usuário
POST /api/auth/login       # Fazer login
GET  /api/auth/me          # Obter dados do usuário
POST /api/auth/create-user # Criar usuário (admin only)
```

### Clientes
```
GET    /api/clientes           # Listar clientes do usuário
POST   /api/clientes           # Criar novo cliente
PUT    /api/clientes/:id       # Atualizar cliente
DELETE /api/clientes/:id       # Deletar cliente
POST   /api/bulk/clientes      # Importar múltiplos clientes
```

### Vendas
```
GET    /api/vendas             # Listar vendas (admin vê todas)
POST   /api/vendas             # Criar nova venda
PUT    /api/vendas/:id         # Atualizar venda
DELETE /api/vendas/:id         # Deletar venda
POST   /api/bulk/vendas        # Importar múltiplas vendas
```

## 🧪 Testando

### Health Check
```bash
curl http://localhost:3000/health
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@crm.local","senha":"JL10@dez"}'
```

### Listar Clientes (com token)
```bash
curl -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  http://localhost:3000/api/clientes
```

## 🐛 Troubleshooting

### PostgreSQL não conecta
```powershell
# Verificar se PostgreSQL está rodando
psql -U postgres -h localhost

# Verificar credenciais em .env
```

### Erro "database does not exist"
```sql
CREATE DATABASE crm_vendas_pro;
```

### Erro de autenticação
- Verificar .env
- Resetar senha: `ALTER USER postgres WITH PASSWORD 'nova_senha';`

## 📝 Notas Importantes

- ✅ **Sem mais arquivos .sqlite** - Tudo está no PostgreSQL
- ✅ **Sem mais localStorage** - Dados persisten apenas no servidor
- ✅ **Melhor escalabilidade** - PostgreSQL suporta múltiplos usuários
- ✅ **Mais seguro** - Dados centralizados no servidor
- ✅ **Pronto para produção** - Com melhorias de performance

## 🚀 Próximos Passos (Opcional)

- [ ] Implementar refresh tokens
- [ ] Adicionar rate limiting
- [ ] Configurar HTTPS/SSL
- [ ] Backup automático do banco
- [ ] Logs de auditoria
- [ ] Cache com Redis

## 📞 Suporte

Qualquer dúvida sobre a migração, consulte o arquivo `MIGRATION.md`

---

**Versão:** 2.0.0 (PostgreSQL)  
**Data:** 14/01/2026  
**Status:** ✅ Pronto para Produção
