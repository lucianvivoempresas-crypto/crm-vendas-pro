# 🔧 Guia de Troubleshooting - PostgreSQL

## ❌ Problema: "Error: connect ECONNREFUSED 127.0.0.1:5432"

### Diagnóstico
PostgreSQL não está rodando ou não consegue conectar

### Soluções
```powershell
# 1. Verificar se PostgreSQL está instalado
psql --version

# 2. Iniciar o serviço PostgreSQL (Windows)
net start postgresql-x64-XX  # Onde XX é a versão

# 3. Ou reiniciar manualmente
pg_ctl -D "C:\Program Files\PostgreSQL\data" start

# 4. Testar conexão
psql -U postgres -h localhost

# 5. Se não conectar, verificar se porta 5432 está aberta
netstat -an | findstr 5432
```

---

## ❌ Problema: "FATAL: database 'crm_vendas_pro' does not exist"

### Diagnóstico
O banco de dados não foi criado

### Soluções
```sql
-- Conectar como superuser
psql -U postgres

-- Criar banco de dados
CREATE DATABASE crm_vendas_pro
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';

-- Verificar
\l

-- Sair
\q
```

---

## ❌ Problema: "FATAL: password authentication failed for user 'postgres'"

### Diagnóstico
Senha do PostgreSQL incorreta no `.env`

### Soluções
```powershell
# 1. Verificar credenciais em .env
cat .env | grep DB_

# 2. Reset de senha do PostgreSQL
psql -U postgres

# 3. Na prompt SQL
ALTER USER postgres WITH PASSWORD 'nova_senha_aqui';
\q

# 4. Atualizar .env com a nova senha
# DB_PASSWORD=nova_senha_aqui
```

---

## ❌ Problema: "role 'postgres' does not exist"

### Diagnóstico
PostgreSQL foi desinstalado e reinstalado, ou usuário foi deletado

### Solução
```powershell
# Reinstalar PostgreSQL completamente
choco uninstall postgresql
choco install postgresql
```

---

## ❌ Problema: Porta 5432 já está em uso

### Diagnóstico
Outro serviço está usando a mesma porta

### Soluções
```powershell
# 1. Encontrar o processo que usa a porta 5432
netstat -ano | findstr :5432

# 2. Encerrar o processo (PID é o número final)
taskkill /PID <PID> /F

# 3. Ou alterar porta do PostgreSQL em .env
# DB_PORT=5433

# Depois criar banco nessa porta
psql -U postgres -p 5433
```

---

## ❌ Problema: "Error: Command failed with exit code 1"

### Diagnóstico
Erro geral ao executar npm install ou npm start

### Soluções
```powershell
# 1. Limpar cache npm
npm cache clean --force

# 2. Remover node_modules
rm -r node_modules
rm package-lock.json

# 3. Reinstalar
npm install

# 4. Se persistir, verificar logs
npm start 2>&1 | tee app.log
```

---

## ❌ Problema: "Cannot find module 'pg'"

### Diagnóstico
Módulo PostgreSQL não foi instalado

### Solução
```powershell
# Instalação manual
npm install pg
```

---

## ⚠️ Problema: Servidor inicia mas não consegue fazer login

### Diagnóstico
Banco de dados criado mas sem tabelas

### Solução
```powershell
# O servidor cria automaticamente na primeira execução
# Se não funcionou, executar manualmente

psql -U postgres -d crm_vendas_pro -f setup-db.sql
```

---

## 🔍 Verificações de Saúde

### Verificar conexão PostgreSQL
```powershell
# Test direto
psql -U postgres -h localhost -d crm_vendas_pro -c "SELECT NOW();"

# Via curl (se servidor está rodando)
curl http://localhost:3000/health
```

### Verificar tabelas criadas
```sql
psql -U postgres -d crm_vendas_pro

-- Listar todas as tabelas
\dt

-- Ver estrutura de uma tabela
\d usuarios

-- Ver índices
\di

-- Ver views
\dv

-- Sair
\q
```

### Verificar usuário admin
```sql
psql -U postgres -d crm_vendas_pro

SELECT id, email, nome, role FROM usuarios WHERE role = 'admin';

-- Resultado esperado:
-- id | email           | nome           | role
-- ---+-----------------+----------------+------
-- 1  | admin@crm.local | Administrador  | admin
```

---

## 🧪 Testes de Integração

### Teste 1: Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@crm.local",
    "senha": "JL10@dez"
  }'
```

Resposta esperada:
```json
{
  "id": 1,
  "email": "admin@crm.local",
  "nome": "Administrador",
  "role": "admin",
  "token": "eyJhbGciOiJIUzI1NiIsInR..."
}
```

### Teste 2: Listar clientes
```bash
# Substituir TOKEN_AQUI pelo token recebido no login
curl -H "Authorization: Bearer TOKEN_AQUI" \
  http://localhost:3000/api/clientes
```

Resposta esperada (array vazio ou com clientes):
```json
[]
```

### Teste 3: Criar cliente
```bash
curl -X POST http://localhost:3000/api/clientes \
  -H "Authorization: Bearer TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "telefone": "11999999999",
    "email": "joao@example.com"
  }'
```

---

## 📊 Monitoramento

### Ver logs do servidor
```powershell
# Com timestamp
npm start | tee -a logs.txt

# Ver erros em tempo real
npm start 2>&1 | Select-String "ERROR"
```

### Verificar uso de memória do PostgreSQL
```powershell
# No Windows
Get-Process postgres | Select-Object ProcessName, Memory, Handles
```

### Conexões ativas no PostgreSQL
```sql
SELECT datname, usename, count(*) as connection_count
FROM pg_stat_activity
GROUP BY datname, usename;
```

---

## 🔄 Recuperação de Erros Comuns

### Erro: "too many connections"
```sql
-- Ver conexões ativas
SELECT datname, usename, count(*) FROM pg_stat_activity GROUP BY datname, usename;

-- Encerrar conexões (cuidado!)
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname = 'crm_vendas_pro' AND pid <> pg_backend_pid();
```

### Erro: "relation already exists"
```sql
-- Verificar se tabelas existem
\dt

-- Se existem, pode ignorar o erro na inicialização
-- Ou deletar e recriar:
DROP TABLE IF EXISTS vendas CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
```

### Erro: "Invalid UTF-8 sequence"
```sql
-- Recriar banco com encoding correto
CREATE DATABASE crm_vendas_pro
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';
```

---

## 📞 Checklist de Diagnóstico

Ao relatar um erro, forneça:

- [ ] Versão do Node.js (`node -v`)
- [ ] Versão do PostgreSQL (`psql --version`)
- [ ] SO e versão
- [ ] Conteúdo do `.env` (sem secrets!)
- [ ] Saída completa do erro
- [ ] Resultado de `npm start`
- [ ] Resultado de `psql -U postgres -h localhost -c "SELECT NOW();"`

---

## 🆘 Último Recurso: Reset Completo

```powershell
# 1. Parar servidor
Ctrl+C

# 2. Deletar banco (CUIDADO - perderá todos os dados!)
psql -U postgres
DROP DATABASE IF EXISTS crm_vendas_pro;
CREATE DATABASE crm_vendas_pro;
\q

# 3. Limpar ambiente local
rm -r node_modules
rm package-lock.json

# 4. Reinstalar
npm install

# 5. Iniciar
npm start
```

O banco será recriado automaticamente na inicialização!

---

**Última atualização:** 14/01/2026  
**Versão:** PostgreSQL 2.0.0
