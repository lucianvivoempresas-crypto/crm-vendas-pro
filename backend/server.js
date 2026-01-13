
const express = require('express');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const app = express();
app.use(express.json());

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
  db.run(`CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    telefone TEXT,
    email TEXT
  )`);
  db.run(`CREATE TABLE IF NOT EXISTS vendas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    produto TEXT,
    valor REAL,
    comissao REAL,
    data TEXT
  )`);
});

app.get('/', (req, res) => {
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0');
  res.set('Pragma', 'no-cache');
  res.set('Expires', '0');
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// API básica
app.get('/api/clientes', (req, res) => {
  db.all('SELECT * FROM clientes', [], (err, rows) => {
    if (err) return res.status(500).json(err);
    res.json(rows);
  });
});

app.post('/api/clientes', (req, res) => {
  const { nome, telefone, email } = req.body;
  db.run('INSERT INTO clientes (nome, telefone, email) VALUES (?,?,?)', [nome, telefone, email], function(err) {
    if (err) return res.status(500).json(err);
    res.json({ id: this.lastID });
  });
});

app.get('/api/vendas', (req, res) => {
  db.all('SELECT * FROM vendas', [], (err, rows) => {
    if (err) return res.status(500).json(err);
    res.json(rows);
  });
});

app.post('/api/vendas', (req, res) => {
  const { produto, valor, comissao } = req.body;
  const data = new Date().toISOString();
  db.run('INSERT INTO vendas (produto, valor, comissao, data) VALUES (?,?,?,?)', [produto, valor, comissao, data], function(err) {
    if (err) return res.status(500).json(err);
    res.json({ id: this.lastID });
  });
});

app.get('/health', (req, res) => res.json({ status: 'OK' }));

app.listen(PORT, HOST, () => {
  console.log(`CRM Vendas Pro rodando em http://${HOST}:${PORT}`);
  console.log(`Database: ${DATABASE_PATH}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
