# Migração de SQLite para PostgreSQL

## 📋 Resumo das Mudanças

- ✅ Banco de dados mudou de SQLite para **PostgreSQL**
- ✅ Removido salvamento local (.sqlite)
- ✅ Todas as rotas atualizadas para usar async/await com pool PostgreSQL
- ✅ Melhor performance e escalabilidade

## 🚀 Como Configurar

### 1. Instalar PostgreSQL

**Windows (usando Chocolatey):**
```powershell
choco install postgresql
```

**Ou baixar em:** https://www.postgresql.org/download/

### 2. Criar Banco de Dados

```sql
-- Abrir pgAdmin ou psql
CREATE DATABASE crm_vendas_pro;
```

### 3. Configurar Variáveis de Ambiente

1. Copiar `.env.example` para `.env`:
```powershell
cp .env.example .env
```

2. Editar `.env` com suas credenciais PostgreSQL:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=sua_senha_aqui
DB_NAME=crm_vendas_pro
JWT_SECRET=uma-chave-muito-segura-e-aleatoria
```

### 4. Instalar Dependências

```powershell
cd backend
npm install
```

### 5. Iniciar o Servidor

```powershell
npm start
```

A aplicação criará automaticamente:
- Tabelas (usuarios, clientes, vendas)
- Índices para performance
- Usuário admin padrão

## 📝 Dados do Admin Padrão

**Email:** admin@crm.local  
**CPF:** 02850697567  
**Senha:** JL10@dez

## 🔄 Migração de Dados Antigos (Se Aplicável)

Se você tinha dados no SQLite anterior, é possível exportá-los:

```javascript
// Script de migração (executar uma vez)
const sqlite3 = require('sqlite3');
const { pool } = require('./db');

const oldDb = new sqlite3.Database('./crm.sqlite');

// Exportar dados e importar no PostgreSQL
// (Contatar suporte se necessário)
```

## 🔐 Segurança em Produção

Antes de colocar em produção:

1. **Mudar JWT_SECRET:**
   ```bash
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

2. **Usar um gerenciador de secrets** (AWS Secrets Manager, Vault, etc.)

3. **Configurar SSL no PostgreSQL**

4. **Habilitar HTTPS**

5. **Usar variáveis de ambiente seguras**

## 📊 Verificar Conexão

```powershell
curl http://localhost:3000/health
```

Resposta esperada:
```json
{ "status": "OK" }
```

## 🛠 Troubleshooting

### "Error: connect ECONNREFUSED 127.0.0.1:5432"
- PostgreSQL não está rodando
- Verificar: `psql -U postgres -h localhost`

### "error: database "crm_vendas_pro" does not exist"
- Criar banco: `CREATE DATABASE crm_vendas_pro;`

### "error: password authentication failed"
- Verificar credenciais no `.env`
- Reset de password: `ALTER USER postgres WITH PASSWORD 'nova_senha';`

## 📞 Suporte

Qualquer dúvida sobre a migração, entre em contato!
