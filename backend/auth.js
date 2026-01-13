// auth.js - Middleware e funções de autenticação
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const JWT_SECRET = process.env.JWT_SECRET || 'sua-chave-secreta-aqui-mudar-em-producao';
const JWT_EXPIRES_IN = '7d'; // Token expira em 7 dias

/**
 * Hash de senha com bcrypt
 */
async function hashPassword(password) {
  return bcrypt.hash(password, 10);
}

/**
 * Comparar senha com hash
 */
async function verifyPassword(password, hash) {
  return bcrypt.compare(password, hash);
}

/**
 * Gerar JWT token
 */
function generateToken(userId, email) {
  return jwt.sign(
    { userId, email },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
}

/**
 * Middleware para verificar JWT
 */
function authMiddleware(req, res, next) {
  try {
    const token = req.headers.authorization?.split(' ')[1]; // "Bearer token"
    
    if (!token) {
      return res.status(401).json({ error: 'Token não fornecido' });
    }

    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expirado' });
    }
    res.status(401).json({ error: 'Token inválido' });
  }
}

module.exports = {
  hashPassword,
  verifyPassword,
  generateToken,
  authMiddleware,
  JWT_SECRET,
  JWT_EXPIRES_IN
};
