// sync-frontend.js - Sincronização de dados com o servidor PostgreSQL
// NOTA: Removido IndexedDB - todos os dados são mantidos apenas no servidor

/**
 * Buscar clientes do servidor
 */
async function fetchClientes() {
  try {
    if (!isAuthenticated()) {
      throw new Error('Usuário não autenticado');
    }

    const res = await fetch('/api/clientes', {
      headers: getAuthHeaders(),
      credentials: 'include'
    });
    
    if (!res.ok) {
      throw new Error('Erro ao buscar clientes');
    }
    
    const clientes = await res.json();
    console.log(`✓ ${clientes.length} clientes carregados do servidor`);
    window.clientes = clientes; // Manter em memória
    return clientes;
  } catch (err) {
    console.error('Erro ao buscar clientes:', err);
    throw err;
  }
}

/**
 * Buscar vendas do servidor
 */
async function fetchVendas() {
  try {
    if (!isAuthenticated()) {
      throw new Error('Usuário não autenticado');
    }

    const res = await fetch('/api/vendas', {
      headers: getAuthHeaders(),
      credentials: 'include'
    });
    
    if (!res.ok) {
      throw new Error('Erro ao buscar vendas');
    }
    
    const vendas = await res.json();
    console.log(`✓ ${vendas.length} vendas carregadas do servidor`);
    window.vendas = vendas; // Manter em memória
    return vendas;
  } catch (err) {
    console.error('Erro ao buscar vendas:', err);
    throw err;
  }
}

/**
 * Sincronizar dados do servidor na inicialização
 */
async function syncDataFromServer() {
  try {
    if (!isAuthenticated()) {
      console.log('Usuário não autenticado, pulando sincronização');
      return;
    }

    console.log('Sincronizando dados do servidor...');
    
    // Buscar clientes
    try {
      await fetchClientes();
    } catch (err) {
      console.error('Erro ao sincronizar clientes:', err);
    }
    
    // Buscar vendas
    try {
      await fetchVendas();
    } catch (err) {
      console.error('Erro ao sincronizar vendas:', err);
    }
    
  } catch (err) {
    console.error('Erro na sincronização:', err);
  }
}

/**
 * Salvar cliente no servidor
 */
async function saveClienteToServer(cliente) {
  try {
    if (!isAuthenticated()) {
      throw new Error('Usuário não autenticado');
    }
    
    const res = await fetch('/api/clientes', {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify({
        nome: cliente.nome,
        telefone: cliente.telefone,
        email: cliente.email
      }),
      credentials: 'include'
    });
    
    if (!res.ok) {
      const error = await res.json();
      throw new Error(error.error || 'Erro ao salvar cliente');
    }
    
    const serverCliente = await res.json();
    console.log('✓ Cliente salvo no servidor com ID:', serverCliente.id);
    return serverCliente;
  } catch (err) {
    console.error('Erro ao salvar cliente no servidor:', err);
    throw err;
  }
}

/**
 * Atualizar cliente no servidor
 */
async function updateClienteToServer(cliente) {
  try {
    if (!isAuthenticated()) {
      throw new Error('Usuário não autenticado');
    }
    
    const res = await fetch(`/api/clientes/${cliente.id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify({
        nome: cliente.nome,
        telefone: cliente.telefone,
        email: cliente.email
      }),
      credentials: 'include'
    });
    
    if (!res.ok) {
      throw new Error('Erro ao atualizar cliente');
    }
    
    console.log('✓ Cliente atualizado no servidor');
    return await res.json();
  } catch (err) {
    console.error('Erro ao atualizar cliente no servidor:', err);
    throw err;
  }
}

/**
 * Deletar cliente no servidor
 */
async function deleteClienteFromServer(clienteId) {
  try {
    if (!isAuthenticated()) {
      throw new Error('Usuário não autenticado');
    }
    
    const res = await fetch(`/api/clientes/${clienteId}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
      credentials: 'include'
    });
    
    if (!res.ok) {
      throw new Error('Erro ao deletar cliente');
    }
    
    console.log('✓ Cliente deletado no servidor');
    return true;
  } catch (err) {
    console.error('Erro ao deletar cliente no servidor:', err);
    throw err;
  }
}

/**
 * Salvar venda no servidor
 */
async function saveVendaToServer(venda) {
  try {
    if (!isAuthenticated()) {
      throw new Error('Usuário não autenticado');
    }
    
    const res = await fetch('/api/vendas', {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify({
        produto: venda.produto,
        valor: venda.valor,
        comissao: venda.comissao,
        data: venda.data
      }),
      credentials: 'include'
    });
    
    if (!res.ok) {
      throw new Error('Erro ao salvar venda');
    }
    
    const serverVenda = await res.json();
    console.log('✓ Venda salva no servidor com ID:', serverVenda.id);
    return serverVenda;
  } catch (err) {
    console.error('Erro ao salvar venda no servidor:', err);
    throw err;
  }
}

/**
 * Atualizar venda no servidor
 */
async function updateVendaToServer(venda) {
  try {
    if (!isAuthenticated()) {
      throw new Error('Usuário não autenticado');
    }
    
    const res = await fetch(`/api/vendas/${venda.id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify({
        produto: venda.produto,
        valor: venda.valor,
        comissao: venda.comissao,
        data: venda.data
      }),
      credentials: 'include'
    });
    
    if (!res.ok) {
      throw new Error('Erro ao atualizar venda');
    }
    
    console.log('✓ Venda atualizada no servidor');
    return await res.json();
  } catch (err) {
    console.error('Erro ao atualizar venda no servidor:', err);
    throw err;
  }
}

/**
 * Deletar venda no servidor
 */
async function deleteVendaFromServer(vendaId) {
  try {
    if (!isAuthenticated()) {
      throw new Error('Usuário não autenticado');
    }
    
    const res = await fetch(`/api/vendas/${vendaId}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
      credentials: 'include'
    });
    
    if (!res.ok) {
      throw new Error('Erro ao deletar venda');
    }
    
    console.log('✓ Venda deletada no servidor');
    return true;
  } catch (err) {
    console.error('Erro ao deletar venda no servidor:', err);
    throw err;
  }
}

/**
 * Fazer bulk import de clientes para o servidor
 */
async function bulkImportClientesToServer(clientesArray) {
  try {
    if (!isAuthenticated()) {
      throw new Error('Não autenticado');
    }
    
    if (!Array.isArray(clientesArray) || clientesArray.length === 0) {
      throw new Error('Array de clientes vazio');
    }
    
    const res = await fetch('/api/bulk/clientes', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeaders()
      },
      body: JSON.stringify({ clientes: clientesArray }),
      credentials: 'include'
    });
    
    if (!res.ok) {
      const error = await res.json();
      throw new Error(error.error || 'Erro ao importar clientes');
    }
    
    const result = await res.json();
    console.log(`✓ Importação: ${result.inserted} inseridos, ${result.skipped} pulados`);
    return result;
  } catch (err) {
    console.error('Erro ao fazer bulk import de clientes:', err);
    throw err;
  }
}

/**
 * Fazer bulk import de vendas para o servidor
 */
async function bulkImportVendasToServer(vendasArray) {
  try {
    if (!isAuthenticated()) {
      throw new Error('Não autenticado');
    }
    
    if (!Array.isArray(vendasArray) || vendasArray.length === 0) {
      throw new Error('Array de vendas vazio');
    }
    
    const res = await fetch('/api/bulk/vendas', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeaders()
      },
      body: JSON.stringify({ vendas: vendasArray }),
      credentials: 'include'
    });
    
    if (!res.ok) {
      const error = await res.json();
      throw new Error(error.error || 'Erro ao importar vendas');
    }
    
    const result = await res.json();
    console.log(`✓ Importação: ${result.inserted} inseridas, ${result.skipped} puladas`);
    return result;
  } catch (err) {
    console.error('Erro ao fazer bulk import de vendas:', err);
    throw err;
  }
}
