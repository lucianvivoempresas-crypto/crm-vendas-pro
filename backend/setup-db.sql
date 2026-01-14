-- PostgreSQL Setup Script
-- Execute este script como superuser para criar o banco de dados e usuário

-- Criar banco de dados
CREATE DATABASE crm_vendas_pro
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';

-- Conectar ao novo banco
\c crm_vendas_pro

-- Criar extensões úteis
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Criar tabelas
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    senha VARCHAR(255) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('admin', 'user')),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nome VARCHAR(255),
    telefone VARCHAR(20),
    email VARCHAR(255),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vendas (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    produto VARCHAR(255) NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    comissao DECIMAL(10, 2),
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_clientes_usuario_id ON clientes(usuario_id);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes(email);
CREATE INDEX IF NOT EXISTS idx_vendas_usuario_id ON vendas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_vendas_data ON vendas(data DESC);
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_role ON usuarios(role);

-- Criar view para relatórios (opcional)
CREATE OR REPLACE VIEW vw_vendas_por_usuario AS
SELECT 
    u.id,
    u.nome,
    u.email,
    COUNT(v.id) as total_vendas,
    SUM(v.valor) as valor_total,
    SUM(v.comissao) as comissao_total
FROM usuarios u
LEFT JOIN vendas v ON u.id = v.usuario_id
WHERE u.role = 'user'
GROUP BY u.id, u.nome, u.email
ORDER BY valor_total DESC NULLS LAST;

-- Criar view para relatório de clientes
CREATE OR REPLACE VIEW vw_clientes_por_usuario AS
SELECT 
    u.id,
    u.nome,
    u.email,
    COUNT(c.id) as total_clientes
FROM usuarios u
LEFT JOIN clientes c ON u.id = c.usuario_id
GROUP BY u.id, u.nome, u.email
ORDER BY total_clientes DESC;

-- Criar função para atualizar atualizado_em
CREATE OR REPLACE FUNCTION update_atualizado_em()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar triggers para atualizar atualizado_em
DROP TRIGGER IF EXISTS trg_usuarios_updated ON usuarios;
CREATE TRIGGER trg_usuarios_updated
BEFORE UPDATE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION update_atualizado_em();

DROP TRIGGER IF EXISTS trg_clientes_updated ON clientes;
CREATE TRIGGER trg_clientes_updated
BEFORE UPDATE ON clientes
FOR EACH ROW
EXECUTE FUNCTION update_atualizado_em();

DROP TRIGGER IF EXISTS trg_vendas_updated ON vendas;
CREATE TRIGGER trg_vendas_updated
BEFORE UPDATE ON vendas
FOR EACH ROW
EXECUTE FUNCTION update_atualizado_em();

-- Conceder permissões (opcional - usar usuário 'postgres' para criar aplicação)
-- ALTER USER postgres WITH PASSWORD 'nova_senha_aqui';

-- ✅ Banco de dados criado com sucesso!
-- Para conectar: psql -U postgres -d crm_vendas_pro
