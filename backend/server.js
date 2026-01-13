
const express = require('express');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
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
const DATABASE_PATH = process.env.DATABASE_PATH || './crm.sqlite';

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

// Banco SQLite
const db = new sqlite3.Database(DATABASE_PATH);
db.serialize(() => {
  // Tabela de usuários com role (admin/user)
  db.run(`CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE,
    cpf TEXT UNIQUE,
    senha TEXT NOT NULL,
    nome TEXT NOT NULL,
    role TEXT DEFAULT 'user',
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);
  
  // Criar usuário admin se não existir
  db.get('SELECT * FROM usuarios WHERE role = ?', ['admin'], (err, row) => {
    if (!row) {
      const adminEmail = 'admin@crm.local';
      const adminCpf = '02850697567';
      const adminSenha = 'JL10@dez';
      
      hashPassword(adminSenha).then(senhaHash => {
        db.run(
          'INSERT INTO usuarios (email, cpf, senha, nome, role) VALUES (?, ?, ?, ?, ?)',
          [adminEmail, adminCpf, senhaHash, 'Administrador', 'admin'],
          (err) => {
            if (!err) console.log('✓ Usuário admin criado automaticamente');
          }
        );
      });
    }
  });
  
  db.run(`CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER NOT NULL,
    nome TEXT,
    telefone TEXT,
    email TEXT,
    FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
  )`);
  
  db.run(`CREATE TABLE IF NOT EXISTS vendas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER NOT NULL,
    produto TEXT,
    valor REAL,
    comissao REAL,
    data TEXT,
    FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
  )`);
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

    db.run(
      'INSERT INTO usuarios (email, senha, nome) VALUES (?, ?, ?)',
      [email, senhaHash, nome],
      function(err) {
        if (err) {
          if (err.message.includes('UNIQUE constraint failed')) {
            return res.status(409).json({ error: 'Email já cadastrado' });
          }
          return res.status(500).json({ error: 'Erro ao registrar' });
        }

        const token = generateToken(this.lastID, email);
        res.status(201).json({
          id: this.lastID,
          email,
          nome,
          token
        });
      }
    );
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro no servidor' });
  }
});

// LOGIN - Autenticar usuário (email ou CPF)
app.post('/api/auth/login', (req, res) => {
  try {
    const { email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ error: 'Email/CPF e senha são obrigatórios' });
    }

    // Buscar por email OU cpf
    db.get(
      'SELECT * FROM usuarios WHERE email = ? OR cpf = ?',
      [email, email],
      async (err, usuario) => {
        if (err) return res.status(500).json({ error: 'Erro no servidor' });

        if (!usuario) {
          return res.status(401).json({ error: 'Email/CPF ou senha inválidos' });
        }

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
      }
    );
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro no servidor' });
  }
});

// VERIFICAR TOKEN - Validar autenticação
app.get('/api/auth/me', authMiddleware, (req, res) => {
  db.get('SELECT id, email, nome, role FROM usuarios WHERE id = ?', [req.user.userId], (err, usuario) => {
    if (err || !usuario) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.json(usuario);
  });
});

// CRIAR NOVO USUÁRIO (apenas admin)
app.post('/api/auth/create-user', authMiddleware, async (req, res) => {
  try {
    // Verificar se é admin
    db.get('SELECT role FROM usuarios WHERE id = ?', [req.user.userId], async (err, admin) => {
      if (err || !admin || admin.role !== 'admin') {
        return res.status(403).json({ error: 'Apenas administrador pode criar usuários' });
      }

      const { email, cpf, senha, nome } = req.body;

      if (!email || !cpf || !senha || !nome) {
        return res.status(400).json({ error: 'Email, CPF, senha e nome são obrigatórios' });
      }

      const senhaHash = await hashPassword(senha);

      db.run(
        'INSERT INTO usuarios (email, cpf, senha, nome, role) VALUES (?, ?, ?, ?, ?)',
        [email, cpf, senhaHash, nome, 'user'],
        function(err) {
          if (err) {
            if (err.message.includes('UNIQUE constraint failed')) {
              return res.status(409).json({ error: 'Email ou CPF já cadastrado' });
            }
            return res.status(500).json({ error: 'Erro ao criar usuário' });
          }

          res.status(201).json({
            id: this.lastID,
            email,
            cpf,
            nome,
            role: 'user'
          });
        }
      );
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro no servidor' });
  }
});

// ============ ROTAS DE API (com autenticação) ============

// Rota raiz - redirecionar para login ou CRM conforme autenticação
app.get('/', (req, res) => {
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0');
  res.set('Pragma', 'no-cache');
  res.set('Expires', '0');
  
  // Verificar se tem token no cookie
  const token = req.cookies?.auth_token || req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    // Sem token = servir login.html
    return res.sendFile(path.join(__dirname, '../frontend/login.html'));
  }
  
  // Com token = servir CRM
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// Proteger rotas de API com authMiddleware
app.get('/api/clientes', authMiddleware, (req, res) => {
  db.all('SELECT * FROM clientes WHERE usuario_id = ?', [req.user.userId], (err, rows) => {
    if (err) return res.status(500).json(err);
    res.json(rows);
  });
});

app.post('/api/clientes', authMiddleware, (req, res) => {
  const { nome, telefone, email } = req.body;
  db.run('INSERT INTO clientes (usuario_id, nome, telefone, email) VALUES (?,?,?,?)', 
    [req.user.userId, nome, telefone, email], 
    function(err) {
      if (err) return res.status(500).json(err);
      res.json({ id: this.lastID });
    });
});

app.get('/api/vendas', authMiddleware, (req, res) => {
  // Middleware que busca role do usuário
  db.get('SELECT role FROM usuarios WHERE id = ?', [req.user.userId], (err, user) => {
    if (err) return res.status(500).json(err);

    // Admin vê TODAS as vendas, user vê apenas suas
    const query = user.role === 'admin' 
      ? 'SELECT * FROM vendas' 
      : 'SELECT * FROM vendas WHERE usuario_id = ?';
    const params = user.role === 'admin' ? [] : [req.user.userId];

    db.all(query, params, (err, rows) => {
      if (err) return res.status(500).json(err);
      res.json(rows);
    });
  });
});

app.post('/api/vendas', authMiddleware, (req, res) => {
  const { produto, valor, comissao, data } = req.body;
  const dataVenda = data || new Date().toISOString();
  db.run('INSERT INTO vendas (usuario_id, produto, valor, comissao, data) VALUES (?,?,?,?,?)', 
    [req.user.userId, produto, valor, comissao, dataVenda], 
    function(err) {
      if (err) return res.status(500).json(err);
      res.json({ id: this.lastID, usuario_id: req.user.userId, produto, valor, comissao, data: dataVenda });
    });
});

// PUT /api/vendas/:id - Atualizar venda
app.put('/api/vendas/:id', authMiddleware, (req, res) => {
  const { produto, valor, comissao, data } = req.body;
  db.run('UPDATE vendas SET produto=?, valor=?, comissao=?, data=? WHERE id=? AND usuario_id=?', 
    [produto, valor, comissao, data, req.params.id, req.user.userId], 
    function(err) {
      if (err) return res.status(500).json(err);
      res.json({ id: req.params.id, produto, valor, comissao, data });
    });
});

// DELETE /api/vendas/:id - Deletar venda
app.delete('/api/vendas/:id', authMiddleware, (req, res) => {
  db.run('DELETE FROM vendas WHERE id=? AND usuario_id=?', 
    [req.params.id, req.user.userId], 
    function(err) {
      if (err) return res.status(500).json(err);
      res.json({ success: true });
    });
});

// PUT /api/clientes/:id - Atualizar cliente
app.put('/api/clientes/:id', authMiddleware, (req, res) => {
  const { nome, telefone, email } = req.body;
  db.run('UPDATE clientes SET nome=?, telefone=?, email=? WHERE id=? AND usuario_id=?', 
    [nome, telefone, email, req.params.id, req.user.userId], 
    function(err) {
      if (err) return res.status(500).json(err);
      res.json({ id: req.params.id, nome, telefone, email });
    });
});

// DELETE /api/clientes/:id - Deletar cliente
app.delete('/api/clientes/:id', authMiddleware, (req, res) => {
  db.run('DELETE FROM clientes WHERE id=? AND usuario_id=?', 
    [req.params.id, req.user.userId], 
    function(err) {
      if (err) return res.status(500).json(err);
      res.json({ success: true });
    });
});

// POST /api/bulk/clientes - Importar múltiplos clientes
app.post('/api/bulk/clientes', authMiddleware, (req, res) => {
  const { clientes: clientesArray } = req.body;
  if (!Array.isArray(clientesArray)) {
    return res.status(400).json({ error: 'Envie um array de clientes' });
  }
  
  let inserted = 0;
  let skipped = 0;
  
  const insertOne = (index) => {
    if (index >= clientesArray.length) {
      return res.json({ inserted, skipped, total: clientesArray.length });
    }
    
    const cliente = clientesArray[index];
    db.run(
      'INSERT OR REPLACE INTO clientes (usuario_id, nome, telefone, email) VALUES (?,?,?,?)', 
      [req.user.userId, cliente.nome, cliente.telefone, cliente.email], 
      function(err) {
        if (err) {
          console.error('Erro ao inserir cliente:', err);
          skipped++;
        } else {
          inserted++;
        }
        insertOne(index + 1);
      }
    );
  };
  
  insertOne(0);
});

// POST /api/bulk/vendas - Importar múltiplas vendas
app.post('/api/bulk/vendas', authMiddleware, (req, res) => {
  const { vendas: vendasArray } = req.body;
  if (!Array.isArray(vendasArray)) {
    return res.status(400).json({ error: 'Envie um array de vendas' });
  }
  
  let inserted = 0;
  let skipped = 0;
  
  const insertOne = (index) => {
    if (index >= vendasArray.length) {
      return res.json({ inserted, skipped, total: vendasArray.length });
    }
    
    const venda = vendasArray[index];
    db.run(
      'INSERT INTO vendas (usuario_id, produto, valor, comissao, data) VALUES (?,?,?,?,?)', 
      [req.user.userId, venda.produto, venda.valor, venda.comissao, venda.data], 
      function(err) {
        if (err) {
          console.error('Erro ao inserir venda:', err);
          skipped++;
        } else {
          inserted++;
        }
        insertOne(index + 1);
      }
    );
  };
  
  insertOne(0);
});

app.get('/health', (req, res) => res.json({ status: 'OK' }));

// Ouvir em 0.0.0.0 para ser acessível de fora (importante para Render/Docker)
app.listen(PORT, '0.0.0.0', () => {
  console.log(`CRM Vendas Pro rodando em http://0.0.0.0:${PORT}`);
  console.log(`Acesse em: http://localhost:${PORT} (local) ou via domínio (produção)`);
  console.log(`Database: ${DATABASE_PATH}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
