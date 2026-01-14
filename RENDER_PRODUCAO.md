# 🚀 OTIMIZAÇÕES PARA PRODUÇÃO NO RENDER

## ⚡ Performance

### 1. Connection Pool Render
No `db.js`, ajuste para produção:

```javascript
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'crm_vendas_pro',
  max: process.env.NODE_ENV === 'production' ? 20 : 5,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

### 2. Compressão de Resposta
Adicione em `server.js`:

```javascript
const compression = require('compression');
app.use(compression());
```

Instale:
```bash
npm install compression
```

### 3. Timeouts
```javascript
// Em server.js, após app = express()
app.use((req, res, next) => {
  res.setTimeout(30000); // 30 segundos
  next();
});
```

---

## 🔐 Segurança

### 1. CORS (Cross-Origin)
```bash
npm install cors
```

Em `server.js`:
```javascript
const cors = require('cors');
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS || 'https://seu-dominio.com',
  credentials: true
}));
```

### 2. Rate Limiting
```bash
npm install express-rate-limit
```

Em `server.js`:
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // 100 requests por IP
  message: 'Muitas requisições, tente novamente depois'
});

app.use('/api/', limiter);
```

### 3. Helmet (Headers de segurança)
```bash
npm install helmet
```

Em `server.js`:
```javascript
const helmet = require('helmet');
app.use(helmet());
```

---

## 📊 Monitoring

### 1. Health Check (já tem)
```javascript
app.get('/health', (req, res) => res.json({ status: 'OK' }));
```

Render verifica isso automaticamente!

### 2. Logging Estruturado
```bash
npm install winston
```

Em `server.js`:
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'crm-api' },
  transports: [
    new winston.transports.Console()
  ]
});

// Usar no lugar de console.log
logger.info('Servidor iniciado');
```

### 3. Error Tracking (opcional)
```bash
npm install sentry-node
```

Em `server.js`:
```javascript
const Sentry = require("@sentry/node");

Sentry.init({ 
  dsn: process.env.SENTRY_DSN 
});

app.use(Sentry.Handlers.errorHandler());
```

---

## 💾 Banco de Dados

### 1. Connection Pooling
Render gerencia isso, mas pode otimizar:

```javascript
// Em db.js
const pool = new Pool({
  // ... resto
  max: 20,
  min: 2,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
});
```

### 2. Índices (já criados)
Seus índices já estão em `setup-db.sql`:
```sql
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_clientes_usuario_id ON clientes(usuario_id);
CREATE INDEX idx_vendas_usuario_id ON vendas(usuario_id);
```

### 3. Query Optimization
Sempre use:
```javascript
// ✅ BOM - Parametrizado
const result = await pool.query(
  'SELECT * FROM usuarios WHERE email = $1',
  [email]
);

// ❌ RUIM - String concatenation
const result = await pool.query(
  `SELECT * FROM usuarios WHERE email = '${email}'`
);
```

Seu código já está correto!

---

## 🌍 Escalabilidade

### 1. Variáveis de Ambiente por Env
Render diferencia `production`, `staging`, `development`.

Use em `server.js`:
```javascript
const isProduction = process.env.NODE_ENV === 'production';

if (isProduction) {
  // Usar settings de produção
  pool.max = 20;
  JWT_EXPIRES_IN = '7d';
} else {
  // Usar settings de dev
  pool.max = 5;
  JWT_EXPIRES_IN = '1d';
}
```

### 2. Cache (opcional com Redis)
Se quiser adicionar depois:
```bash
npm install redis
```

### 3. Load Balancing
Render oferece load balancing automático. Não precisa fazer nada!

---

## 📈 Monitoramento no Render

### 1. Verificar Métricas
No dashboard do Render:
- **Metrics** → CPU, Memória, Banda
- **Logs** → Mensagens de erro

### 2. Alertas
Em **Settings** → **Notifications**:
- Email quando deploy falhar
- Email quando recurso expirar

### 3. Backup
Render faz backup automático do PostgreSQL.
Verifique em: Database → **Backups**

---

## 🔄 CI/CD Melhorado

### 1. Executar Testes Antes do Deploy
Adicione em `package.json`:
```json
{
  "scripts": {
    "start": "node backend/server.js",
    "test": "echo 'No tests yet'",
    "lint": "echo 'Add eslint for linting'"
  }
}
```

Render pode rodar testes, mas com seu código atual não há.

### 2. Environment Específicos
Crie serviços diferentes:
- `crm-vendas-pro` (produção)
- `crm-vendas-pro-staging` (teste)
- `crm-vendas-pro-dev` (desenvolvimento)

---

## 📋 Checklist Pré-Deploy

- [ ] CORS configurado
- [ ] Rate limiting adicionado
- [ ] Helmet instalado
- [ ] Health check testado
- [ ] Variáveis de ambiente corretas
- [ ] JWT_SECRET seguro (32+ caracteres)
- [ ] NODE_ENV=production
- [ ] DB_HOST é do Render
- [ ] HTTPS forçado (automático no Render)
- [ ] Auto-deploy ativado

---

## 🚀 Deploy Otimizado

Seu `server.js` já está ótimo, mas se quiser melhorar ainda mais:

```javascript
// No início de server.js
const isProduction = process.env.NODE_ENV === 'production';

if (isProduction) {
  console.log('⚙️ Modo Produção');
  // Desabilitar logs verbose
  process.env.DEBUG = '';
} else {
  console.log('🔧 Modo Desenvolvimento');
}

// Aumentar pool em produção
const poolConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  max: isProduction ? 25 : 5,
  min: isProduction ? 5 : 1,
};
```

---

## 📞 Monitoramento Contínuo

### Daily Check
```bash
# Testar health
curl https://seu-app.onrender.com/health

# Verificar logs
# Dashboard → Logs
```

### Weekly Check
- [ ] Dados crescendo normalmente?
- [ ] Performance aceitável?
- [ ] Erros nos logs?
- [ ] Disco/Memória OK?

### Monthly Check
- [ ] Backup funcionando?
- [ ] Acessos autorizados?
- [ ] Senhas ainda seguras?
- [ ] Plano adequado?

---

## 💰 Custo Estimado

| Recurso | Free | Starter | Standard |
|---------|------|---------|----------|
| Web Service | Grátis | $7/mês | $25/mês |
| PostgreSQL | - | $15/mês | $50/mês |
| Total Mínimo | - | $22/mês | $75/mês |

**Dica:** Comece com Free tier para testar, depois upgrade!

---

## 🎯 Próximos Passos

1. ✅ Deploy no Render (já feito!)
2. → Testar em produção
3. → Adicionar CORS se precisar frontend separado
4. → Implementar rate limiting
5. → Configurar domínio customizado
6. → Setup de backups automáticos
7. → Monitoramento com Sentry (opcional)
8. → Cache com Redis (opcional)

---

**Seu app está pronto para produção!** 🚀

Render gerencia tudo:
- ✅ HTTPS automático
- ✅ SSL/TLS
- ✅ Load balancing
- ✅ Auto-scaling (planos pagos)
- ✅ Backups automáticos
- ✅ CDN (planos pagos)
