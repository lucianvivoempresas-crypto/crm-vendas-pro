
const express = require('express');
const path = require('path');
const { pool, initDatabase } = require('./db');
const { hashPassword, verifyPassword, generateToken, authMiddleware } = require('./auth');

const app = express();
app.use(express.json());

// Parser de cookies (simples, sem biblioteca)
app.use((req, res, next) => {
  req.cookies = {};
  if (req.headers.cookie) {
    req.headers.cookie.split(';').forEach(cookie => {
      const [name, value] = cookie.trim().split('=');
      req.cookies[name] = value;
    });
  }
  next();
});

// Configurações
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || 'localhost';

// Middleware para desabilitar cache do index.html e arquivos críticos
app.use((req, res, next) => {
  if (req.path === '/' || req.path === '/index.html') {
    res.set('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0');
    res.set('Pragma', 'no-cache');
    res.set('Expires', '0');
  }
  next();
});

// Servir frontend com cache para outros arquivos
app.use(express.static(path.join(__dirname, '../frontend'), {
  maxAge: '1h',
  etag: false
}));

// Inicializar banco PostgreSQL
initDatabase().catch(err => {
  console.error('Falha ao inicializar banco:', err);
  process.exit(1);
});

// ============ ROTAS DE AUTENTICAÇÃO ============

// REGISTRO - Criar novo usuário
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, senha, nome } = req.body;

    if (!email || !senha || !nome) {
      return res.status(400).json({ error: 'Email, senha e nome são obrigatórios' });
    }

    const senhaHash = await hashPassword(senha);

    const result = await pool.query(
      'INSERT INTO usuarios (email, senha, nome) VALUES ($1, $2, $3) RETURNING id, email, nome',
      [email, senhaHash, nome]
    );

    const usuario = result.rows[0];
    const token = generateToken(usuario.id, usuario.email);
    
    res.status(201).json({
      id: usuario.id,
      email: usuario.email,
      nome: usuario.nome,
      token
    });
  } catch (err) {
    if (err.code === '23505') { // Violação de constraint UNIQUE
      return res.status(409).json({ error: 'Email já cadastrado' });
    }
    console.error(err);
    res.status(500).json({ error: 'Erro ao registrar' });
  }
});

// LOGIN - Autenticar usuário (email ou CPF)
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ error: 'Email/CPF e senha são obrigatórios' });
    }

    // Buscar por email OU cpf
    const result = await pool.query(
      'SELECT * FROM usuarios WHERE email = $1 OR cpf = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Email/CPF ou senha inválidos' });
    }

    const usuario = result.rows[0];
    const valida = await verifyPassword(senha, usuario.senha);
    
    if (!valida) {
      return res.status(401).json({ error: 'Email/CPF ou senha inválidos' });
    }

    const token = generateToken(usuario.id, usuario.email);
    res.json({
      id: usuario.id,
      email: usuario.email,
      nome: usuario.nome,
      role: usuario.role,
      token
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro no servidor' });
  }
});

// VERIFICAR TOKEN - Validar autenticação
app.get('/api/auth/me', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, email, nome, role FROM usuarios WHERE id = $1',
      [req.user.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro no servidor' });
  }
});

// CRIAR NOVO USUÁRIO (apenas admin)
app.post('/api/auth/create-user', authMiddleware, async (req, res) => {
  try {
    // Verificar se é admin
    const adminCheck = await pool.query('SELECT role FROM usuarios WHERE id = $1', [req.user.userId]);
    
    if (adminCheck.rows.length === 0 || adminCheck.rows[0].role !== 'admin') {
      return res.status(403).json({ error: 'Apenas administrador pode criar usuários' });
    }

    const { email, cpf, senha, nome } = req.body;

    if (!email || !cpf || !senha || !nome) {
      return res.status(400).json({ error: 'Email, CPF, senha e nome são obrigatórios' });
    }

    const senhaHash = await hashPassword(senha);

    const result = await pool.query(
      'INSERT INTO usuarios (email, cpf, senha, nome, role) VALUES ($1, $2, $3, $4, $5) RETURNING id, email, cpf, nome, role',
      [email, cpf, senhaHash, nome, 'user']
    );

    const usuario = result.rows[0];
    res.status(201).json({
      id: usuario.id,
      email: usuario.email,
      cpf: usuario.cpf,
      nome: usuario.nome,
      role: usuario.role
    });
  } catch (err) {
    if (err.code === '23505') { // Violação de constraint UNIQUE
      return res.status(409).json({ error: 'Email ou CPF já cadastrado' });
    }
    console.error(err);
    res.status(500).json({ error: 'Erro ao criar usuário' });
  }
});

// ============ ROTAS DE API (com autenticação) ============

// Rota raiz - redirecionar para login ou CRM conforme autenticação
app.get('/', (req, res) => {
  // Desabilitar cache ANTES de servir qualquer coisa
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0, private');
  res.set('Pragma', 'no-cache');
  res.set('Expires', '0');
  res.set('Surrogate-Control', 'no-store');
  
  // Verificar se tem token no cookie
  const cookieToken = req.cookies?.auth_token;
  const headerToken = req.headers.authorization?.split(' ')[1];
  const token = cookieToken || headerToken;
  
  console.log(`[AUTH] GET / - Cookie: ${cookieToken ? 'SIM' : 'NÃO'}, Header: ${headerToken ? 'SIM' : 'NÃO'}, Token válido: ${token ? 'SIM' : 'NÃO'}`);
  
  if (!token) {
    // Sem token = servir login.html
    console.log('[AUTH] Sem token, servindo login.html');
    return res.sendFile(path.join(__dirname, '../frontend/login.html'));
  }
  
  // Com token = servir CRM
  console.log('[AUTH] Com token, servindo index.html');
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// Proteger rotas de API com authMiddleware
app.get('/api/clientes', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM clientes WHERE usuario_id = $1 ORDER BY criado_em DESC',
      [req.user.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar clientes' });
  }
});

app.post('/api/clientes', authMiddleware, async (req, res) => {
  try {
    const { nome, telefone, email } = req.body;
    const result = await pool.query(
      'INSERT INTO clientes (usuario_id, nome, telefone, email) VALUES ($1, $2, $3, $4) RETURNING id, usuario_id, nome, telefone, email',
      [req.user.userId, nome, telefone, email]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao criar cliente' });
  }
});

app.get('/api/vendas', authMiddleware, async (req, res) => {
  try {
    // Buscar role do usuário
    const userResult = await pool.query('SELECT role FROM usuarios WHERE id = $1', [req.user.userId]);
    const user = userResult.rows[0];

    // Admin vê TODAS as vendas, user vê apenas suas
    let result;
    if (user.role === 'admin') {
      result = await pool.query('SELECT * FROM vendas ORDER BY data DESC');
    } else {
      result = await pool.query(
        'SELECT * FROM vendas WHERE usuario_id = $1 ORDER BY data DESC',
        [req.user.userId]
      );
    }
    
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar vendas' });
  }
});

app.post('/api/vendas', authMiddleware, async (req, res) => {
  try {
    const { produto, valor, comissao, data } = req.body;
    const dataVenda = data || new Date().toISOString();
    
    const result = await pool.query(
      'INSERT INTO vendas (usuario_id, produto, valor, comissao, data) VALUES ($1, $2, $3, $4, $5) RETURNING id, usuario_id, produto, valor, comissao, data',
      [req.user.userId, produto, valor, comissao, dataVenda]
    );
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao criar venda' });
  }
});

// PUT /api/vendas/:id - Atualizar venda
app.put('/api/vendas/:id', authMiddleware, async (req, res) => {
  try {
    const { produto, valor, comissao, data } = req.body;
    const result = await pool.query(
      'UPDATE vendas SET produto=$1, valor=$2, comissao=$3, data=$4 WHERE id=$5 AND usuario_id=$6 RETURNING *',
      [produto, valor, comissao, data, req.params.id, req.user.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Venda não encontrada' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao atualizar venda' });
  }
});

// DELETE /api/vendas/:id - Deletar venda
app.delete('/api/vendas/:id', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'DELETE FROM vendas WHERE id=$1 AND usuario_id=$2',
      [req.params.id, req.user.userId]
    );
    
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Venda não encontrada' });
    }
    
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao deletar venda' });
  }
});

// PUT /api/clientes/:id - Atualizar cliente
app.put('/api/clientes/:id', authMiddleware, async (req, res) => {
  try {
    const { nome, telefone, email } = req.body;
    const result = await pool.query(
      'UPDATE clientes SET nome=$1, telefone=$2, email=$3 WHERE id=$4 AND usuario_id=$5 RETURNING *',
      [nome, telefone, email, req.params.id, req.user.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Cliente não encontrado' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao atualizar cliente' });
  }
});

// DELETE /api/clientes/:id - Deletar cliente
app.delete('/api/clientes/:id', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'DELETE FROM clientes WHERE id=$1 AND usuario_id=$2',
      [req.params.id, req.user.userId]
    );
    
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Cliente não encontrado' });
    }
    
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao deletar cliente' });
  }
});

// POST /api/bulk/clientes - Importar múltiplos clientes
app.post('/api/bulk/clientes', authMiddleware, async (req, res) => {
  try {
    const { clientes: clientesArray } = req.body;
    if (!Array.isArray(clientesArray)) {
      return res.status(400).json({ error: 'Envie um array de clientes' });
    }
    
    let inserted = 0;
    let skipped = 0;
    
    for (const cliente of clientesArray) {
      try {
        await pool.query(
          'INSERT INTO clientes (usuario_id, nome, telefone, email) VALUES ($1, $2, $3, $4)',
          [req.user.userId, cliente.nome, cliente.telefone, cliente.email]
        );
        inserted++;
      } catch (err) {
        console.error('Erro ao inserir cliente:', err);
        skipped++;
      }
    }
    
    res.json({ inserted, skipped, total: clientesArray.length });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao importar clientes' });
  }
});

// POST /api/bulk/vendas - Importar múltiplas vendas
app.post('/api/bulk/vendas', authMiddleware, async (req, res) => {
  try {
    const { vendas: vendasArray } = req.body;
    if (!Array.isArray(vendasArray)) {
      return res.status(400).json({ error: 'Envie um array de vendas' });
    }
    
    let inserted = 0;
    let skipped = 0;
    
    for (const venda of vendasArray) {
      try {
        await pool.query(
          'INSERT INTO vendas (usuario_id, produto, valor, comissao, data) VALUES ($1, $2, $3, $4, $5)',
          [req.user.userId, venda.produto, venda.valor, venda.comissao, venda.data]
        );
        inserted++;
      } catch (err) {
        console.error('Erro ao inserir venda:', err);
        skipped++;
      }
    }
    
    res.json({ inserted, skipped, total: vendasArray.length });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao importar vendas' });
  }
});

app.get('/health', (req, res) => res.json({ status: 'OK' }));

// Ouvir em 0.0.0.0 para ser acessível de fora (importante para Render/Docker)
app.listen(PORT, '0.0.0.0', () => {
  console.log(`CRM Vendas Pro rodando em http://0.0.0.0:${PORT}`);
  console.log(`Acesse em: http://localhost:${PORT} (local) ou via domínio (produção)`);
  console.log(`Database: PostgreSQL`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
