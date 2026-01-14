# ⚡ QUICK REFERENCE - Guia Rápido

## 🚀 Setup em 5 Minutos

```bash
# 1. Criar banco PostgreSQL
psql -U postgres
CREATE DATABASE crm_vendas_pro;
\q

# 2. Configurar
cp .env.example .env
# Editar .env com suas credenciais

# 3. Instalar
npm install

# 4. Iniciar
npm start

# 5. Acessar
# Abrir http://localhost:3000
```

## 📝 Variáveis de Ambiente (.env)

```env
PORT=3000
HOST=localhost
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=crm_vendas_pro

JWT_SECRET=mude-isso-em-producao
```

## 🔑 Credenciais Padrão

| Campo | Valor |
|-------|-------|
| Email | admin@crm.local |
| Senha | JL10@dez |

**⚠️ Mudar após primeiro login!**

## 🔗 API Endpoints

### Autenticação
```
POST   /api/auth/register    - Registrar
POST   /api/auth/login       - Login
GET    /api/auth/me          - Dados do usuário
POST   /api/auth/create-user - Admin cria usuário
```

### Clientes
```
GET    /api/clientes         - Listar
POST   /api/clientes         - Criar
PUT    /api/clientes/:id     - Atualizar
DELETE /api/clientes/:id     - Deletar
POST   /api/bulk/clientes    - Importar múltiplos
```

### Vendas
```
GET    /api/vendas           - Listar
POST   /api/vendas           - Criar
PUT    /api/vendas/:id       - Atualizar
DELETE /api/vendas/:id       - Deletar
POST   /api/bulk/vendas      - Importar múltiplas
```

## 🧪 Testes Rápidos

```bash
# Health check
curl http://localhost:3000/health

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@crm.local","senha":"JL10@dez"}'

# Listar clientes (substituir TOKEN)
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/clientes
```

## 🆘 Problemas Comuns

| Problema | Solução |
|----------|---------|
| Porta 5432 recusada | PostgreSQL não está rodando: `psql -U postgres` |
| Database não existe | `CREATE DATABASE crm_vendas_pro;` |
| Senha incorreta | Alterar em .env ou reset: `ALTER USER postgres WITH PASSWORD 'nova';` |
| npm install falha | `npm cache clean --force && rm -r node_modules && npm install` |
| Cannot find module 'pg' | `npm install pg` |

## 📚 Documentação

| Arquivo | Propósito |
|---------|-----------|
| MIGRATION.md | Guia completo de instalação |
| README_MIGRACAO.md | Resumo técnico |
| SUMMARY.md | Detalhes de mudanças |
| TROUBLESHOOTING.md | Solução de problemas |
| ESTRUTURA_FINAL.md | Estrutura do projeto |

## 🎯 Checklist Pré-Lançamento

- [ ] PostgreSQL instalado e rodando
- [ ] Banco de dados criado
- [ ] .env configurado corretamente
- [ ] npm install executado
- [ ] npm start funcionando
- [ ] Login funciona com admin
- [ ] Listar clientes funciona
- [ ] Criar cliente funciona
- [ ] Criar venda funciona
- [ ] Senha admin alterada

## 📊 Arquivos Principais

```
backend/
├── db.js              - Configuração PostgreSQL
├── server.js          - Rotas principais
├── package.json       - Dependências
├── .env.example       - Variáveis
└── frontend/
    ├── auth-frontend.js    - Auth (sem localStorage)
    └── sync-frontend.js    - Sincronização (sem IndexedDB)
```

## 🔐 JWT Token

Obtido ao fazer login:
```json
{
  "id": 1,
  "email": "admin@crm.local",
  "nome": "Administrador",
  "role": "admin",
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

Usar no header:
```
Authorization: Bearer <token>
```

## 📈 Performance

- Pool de conexões: 20 conexões padrão
- Índices criados automaticamente
- Queries otimizadas
- Async/await para I/O não-bloqueante

## 🛑 Parar Servidor

```bash
# No terminal
Ctrl + C

# Verificar se parou
curl http://localhost:3000/health
# Deve retornar erro de conexão
```

## 🔄 Reiniciar PostgreSQL

```powershell
# Windows
net stop postgresql-x64-15  # versão pode variar
net start postgresql-x64-15

# Ou
pg_ctl -D "C:\Program Files\PostgreSQL\data" restart
```

## 📱 Estrutura do Banco

### Tabelas
- `usuarios` - Usuários do sistema
- `clientes` - Clientes dos usuários
- `vendas` - Vendas dos usuários

### Índices
- `idx_clientes_usuario_id`
- `idx_vendas_usuario_id`
- `idx_usuarios_email`

### Views (Opcional)
- `vw_vendas_por_usuario` - Relatório de vendas
- `vw_clientes_por_usuario` - Relatório de clientes

## 🚀 Deploy Rápido

```bash
# 1. Preparar servidor
# - Instalar PostgreSQL
# - Instalar Node.js
# - Clonar repositório

# 2. Configurar
cp .env.example .env
# Editar .env para ambiente de produção

# 3. Instalar
npm install
npm ci  # Para produção

# 4. Iniciar
npm start
# Ou usar PM2: pm2 start server.js

# 5. Configurar HTTPS
# - Usar reverse proxy (Nginx, Apache)
# - Obter certificado SSL (Let's Encrypt)
```

## 💡 Dicas

1. **Sempre fazer backup do banco antes de grandes mudanças**
   ```bash
   pg_dump -U postgres crm_vendas_pro > backup.sql
   ```

2. **Resetar password admin se esquecer**
   ```bash
   # Entrar no banco
   psql -U postgres -d crm_vendas_pro
   
   # Resetar para padrão
   UPDATE usuarios SET senha = (bcrypt_hash('JL10@dez', 10)) 
   WHERE email = 'admin@crm.local';
   ```

3. **Ver logs do servidor**
   ```bash
   npm start 2>&1 | tee app.log
   ```

4. **Testar sem interface**
   ```bash
   node -e "const {pool} = require('./db'); pool.query('SELECT 1').then(r => console.log('✓')).catch(e => console.log('✗', e.message));"
   ```

---

**Versão:** 2.0.0 (PostgreSQL)  
**Atualizado:** 14/01/2026  
**Status:** ✅ Pronto para Usar
