// auth-frontend.js - Funções de autenticação para o frontend
// NOTA: Removido localStorage - usando apenas cookies e sessão

/**
 * Fazer login com email/CPF
 */
async function login(emailOrCpf, senha) {
  try {
    const res = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: emailOrCpf, senha }),
      credentials: 'include' // IMPORTANTE: enviar/receber cookies
    });

    if (!res.ok) {
      const error = await res.json();
      throw new Error(error.error || 'Erro ao fazer login');
    }

    const data = await res.json();
    
    // Salvar token apenas em cookie (seguro)
    document.cookie = `auth_token=${data.token}; path=/; max-age=604800; SameSite=Lax`;
    
    // Guardar em memória (não persiste após refresh)
    window.currentUser = data;

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
      body: JSON.stringify({ email, senha, nome }),
      credentials: 'include' // IMPORTANTE: enviar/receber cookies
    });

    if (!res.ok) {
      const error = await res.json();
      throw new Error(error.error || 'Erro ao registrar');
    }

    const data = await res.json();

    // Salvar token apenas em cookie (seguro)
    document.cookie = `auth_token=${data.token}; path=/; max-age=604800; SameSite=Lax`;
    
    // Guardar em memória
    window.currentUser = data;

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
  // Remover cookie
  document.cookie = 'auth_token=; path=/; max-age=0;';
  
  // Limpar memória
  window.currentUser = null;
  
  window.location.href = '/login.html';
}

/**
 * Verificar se usuário está autenticado
 */
function isAuthenticated() {
  return !!getToken();
}

/**
 * Obter token do cookie
 */
function getToken() {
  const cookies = document.cookie.split(';');
  for (let cookie of cookies) {
    const [name, value] = cookie.trim().split('=');
    if (name === 'auth_token') return value;
  }
  return null;
}

/**
 * Buscar dados do usuário do servidor
 */
async function getCurrentUser() {
  try {
    const res = await fetch('/api/auth/me', {
      headers: getAuthHeaders(),
      credentials: 'include'
    });
    
    if (!res.ok) return null;
    
    const user = await res.json();
    window.currentUser = user;
    return user;
  } catch (err) {
    console.error('Error fetching current user:', err);
    return null;
  }
}

/**
 * Verificar se usuário é admin
 */
async function isAdmin() {
  const user = window.currentUser || await getCurrentUser();
  return user?.role === 'admin';
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
