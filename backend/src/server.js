const express = require('express');
const path = require('path');

const app = express();

// Servir o frontend
app.use(express.static(path.join(__dirname, '../frontend')));

// Rota raiz
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK' });
});

app.listen(3000, () => {
  console.log('CRM rodando em http://localhost:3000');
});
