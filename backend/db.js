// db.js - Configuração PostgreSQL com Pool de conexões
const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'crm_vendas_pro',
});

// Testa conexão
pool.on('error', (err) => {
  console.error('Erro no pool de conexões:', err);
  process.exit(1);
});

/**
 * Inicializar banco de dados com tabelas
 */
async function initDatabase() {
  const client = await pool.connect();
  try {
    console.log('Inicializando banco de dados PostgreSQL...');

    // Tabela de usuários
    await client.query(`
      CREATE TABLE IF NOT EXISTS usuarios (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        cpf VARCHAR(11) UNIQUE,
        senha VARCHAR(255) NOT NULL,
        nome VARCHAR(255) NOT NULL,
        role VARCHAR(20) DEFAULT 'user',
        criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Tabela de clientes
    await client.query(`
      CREATE TABLE IF NOT EXISTS clientes (
        id SERIAL PRIMARY KEY,
        usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
        nome VARCHAR(255),
        telefone VARCHAR(20),
        email VARCHAR(255),
        criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Tabela de vendas
    await client.query(`
      CREATE TABLE IF NOT EXISTS vendas (
        id SERIAL PRIMARY KEY,
        usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
        produto VARCHAR(255),
        valor DECIMAL(10, 2),
        comissao DECIMAL(10, 2),
        data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Criar índices para melhor performance
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_clientes_usuario_id ON clientes(usuario_id);
      CREATE INDEX IF NOT EXISTS idx_vendas_usuario_id ON vendas(usuario_id);
      CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
    `);

    console.log('✓ Tabelas criadas com sucesso');

    // Verificar se admin existe
    const { rows } = await client.query('SELECT * FROM usuarios WHERE role = $1', ['admin']);
    
    if (rows.length === 0) {
      // Criar admin padrão
      const { hashPassword } = require('./auth');
      const adminEmail = 'admin@crm.local';
      const adminCpf = '02850697567';
      const adminSenha = 'JL10@dez';
      
      const senhaHash = await hashPassword(adminSenha);
      
      await client.query(
        'INSERT INTO usuarios (email, cpf, senha, nome, role) VALUES ($1, $2, $3, $4, $5)',
        [adminEmail, adminCpf, senhaHash, 'Administrador', 'admin']
      );
      
      console.log('✓ Usuário admin criado automaticamente');
      console.log(`  Email: ${adminEmail}`);
      console.log(`  Senha: ${adminSenha}`);
    }

  } catch (err) {
    console.error('Erro ao inicializar banco:', err);
    throw err;
  } finally {
    client.release();
  }
}

module.exports = {
  pool,
  initDatabase
};
