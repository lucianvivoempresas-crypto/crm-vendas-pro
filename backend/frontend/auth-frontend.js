// auth-frontend.js - Funções de autenticação para o frontend

/**
 * Fazer login com email/CPF
 */
async function login(emailOrCpf, senha) {
  try {
    const res = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: emailOrCpf, senha })
    });

    if (!res.ok) {
      const error = await res.json();
      throw new Error(error.error || 'Erro ao fazer login');
    }

    const data = await res.json();
    
    // Salvar token no localStorage E em cookie
    localStorage.setItem('auth_token', data.token);
    localStorage.setItem('user_id', data.id);
    localStorage.setItem('user_email', data.email);
    localStorage.setItem('user_nome', data.nome);
    localStorage.setItem('user_role', data.role);

    // Salvar em cookie para o servidor ler
    document.cookie = `auth_token=${data.token}; path=/; max-age=604800; SameSite=Lax`;

    return data;
  } catch (err) {
    console.error('Login error:', err);
    throw err;
  }
}

/**
 * Fazer registro
 */
async function register(email, senha, nome) {
  try {
    const res = await fetch('/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, senha, nome })
    });

    if (!res.ok) {
      const error = await res.json();
      throw new Error(error.error || 'Erro ao registrar');
    }

    const data = await res.json();

    // Salvar token no localStorage E em cookie
    localStorage.setItem('auth_token', data.token);
    localStorage.setItem('user_id', data.id);
    localStorage.setItem('user_email', data.email);
    localStorage.setItem('user_nome', data.nome);
    localStorage.setItem('user_role', data.role || 'user');

    // Salvar em cookie para o servidor ler
    document.cookie = `auth_token=${data.token}; path=/; max-age=604800; SameSite=Lax`;

    return data;
  } catch (err) {
    console.error('Register error:', err);
    throw err;
  }
}

/**
 * Fazer logout
 */
function logout() {
  localStorage.removeItem('auth_token');
  localStorage.removeItem('user_id');
  localStorage.removeItem('user_email');
  localStorage.removeItem('user_nome');
  localStorage.removeItem('user_role');
  
  // Remover cookie
  document.cookie = 'auth_token=; path=/; max-age=0;';
  
  window.location.href = '/login.html';
}

/**
 * Verificar se usuário está autenticado
 */
function isAuthenticated() {
  return !!localStorage.getItem('auth_token');
}

/**
 * Obter token atual
 */
function getToken() {
  return localStorage.getItem('auth_token');
}

/**
 * Obter dados do usuário
 */
function getCurrentUser() {
  return {
    id: localStorage.getItem('user_id'),
    email: localStorage.getItem('user_email'),
    nome: localStorage.getItem('user_nome'),
    role: localStorage.getItem('user_role') || 'user'
  };
}

/**
 * Verificar se usuário é admin
 */
function isAdmin() {
  return getCurrentUser().role === 'admin';
}

/**
 * Headers com autenticação
 */
function getAuthHeaders() {
  const token = getToken();
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  };
}

/**
 * Redirecionar para login se não autenticado
 */
function requireAuth() {
  if (!isAuthenticated()) {
    window.location.href = '/login.html';
  }
}
