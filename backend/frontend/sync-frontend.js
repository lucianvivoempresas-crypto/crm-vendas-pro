// sync-frontend.js - Sincronização de dados entre servidor e IndexedDB

/**
 * Sincronizar dados do servidor para IndexedDB na inicialização
 */
async function syncDataFromServer() {
  try {
    if (!isAuthenticated()) {
      console.log('Usuário não autenticado, pulando sincronização');
      return;
    }

    console.log('Sincronizando dados do servidor...');
    
    // Buscar clientes do servidor
    try {
      const clientesRes = await fetch('/api/clientes', {
        headers: getAuthHeaders()
      });
      
      if (clientesRes.ok) {
        const clientesData = await clientesRes.json();
        console.log(`Encontrados ${clientesData.length} clientes no servidor`);
        
        // Limpar IndexedDB e popular com dados do servidor
        if (window.db && window.clientes !== undefined) {
          const tx = window.db.transaction('clientes', 'readwrite');
          const store = tx.objectStore('clientes');
          store.clear();
          
          for (const cliente of clientesData) {
            store.add(cliente);
          }
          
          // Atualizar array global
          window.clientes = clientesData;
          console.log('✓ Clientes sincronizados');
        }
      }
    } catch (err) {
      console.error('Erro ao sincronizar clientes:', err);
    }
    
    // Buscar vendas do servidor
    try {
      const vendasRes = await fetch('/api/vendas', {
        headers: getAuthHeaders()
      });
      
      if (vendasRes.ok) {
        const vendasData = await vendasRes.json();
        console.log(`Encontradas ${vendasData.length} vendas no servidor`);
        
        // Limpar IndexedDB e popular com dados do servidor
        if (window.db && window.vendas !== undefined) {
          const tx = window.db.transaction('vendas', 'readwrite');
          const store = tx.objectStore('vendas');
          store.clear();
          
          for (const venda of vendasData) {
            store.add(venda);
          }
          
          // Atualizar array global
          window.vendas = vendasData;
          console.log('✓ Vendas sincronizadas');
        }
      }
    } catch (err) {
      console.error('Erro ao sincronizar vendas:', err);
    }
    
  } catch (err) {
    console.error('Erro na sincronização:', err);
  }
}

/**
 * Salvar cliente no servidor ALÉM de IndexedDB
 */
async function saveClienteToServer(cliente) {
  try {
    if (!isAuthenticated()) return cliente; // Sem autenticação, salva só localmente
    
    const res = await fetch('/api/clientes', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeaders()
      },
      body: JSON.stringify({
        nome: cliente.nome,
        telefone: cliente.telefone,
        email: cliente.email
      })
    });
    
    if (!res.ok) {
      const error = await res.json();
      console.error('Erro ao salvar cliente no servidor:', error);
      return cliente; // Retorna com ID local se falhar
    }
    
    const serverCliente = await res.json();
    console.log('✓ Cliente salvo no servidor com ID:', serverCliente.id);
    return serverCliente;
  } catch (err) {
    console.error('Erro ao salvar cliente no servidor:', err);
    return cliente;
  }
}

/**
 * Atualizar cliente no servidor
 */
async function updateClienteToServer(cliente) {
  try {
    if (!isAuthenticated()) return cliente;
    
    const res = await fetch(`/api/clientes/${cliente.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeaders()
      },
      body: JSON.stringify({
        nome: cliente.nome,
        telefone: cliente.telefone,
        email: cliente.email
      })
    });
    
    if (!res.ok) {
      console.error('Erro ao atualizar cliente no servidor');
      return cliente;
    }
    
    console.log('✓ Cliente atualizado no servidor');
    return await res.json();
  } catch (err) {
    console.error('Erro ao atualizar cliente no servidor:', err);
    return cliente;
  }
}

/**
 * Deletar cliente no servidor
 */
async function deleteClienteFromServer(clienteId) {
  try {
    if (!isAuthenticated()) return true;
    
    const res = await fetch(`/api/clientes/${clienteId}`, {
      method: 'DELETE',
      headers: getAuthHeaders()
    });
    
    if (!res.ok) {
      console.error('Erro ao deletar cliente no servidor');
      return false;
    }
    
    console.log('✓ Cliente deletado no servidor');
    return true;
  } catch (err) {
    console.error('Erro ao deletar cliente no servidor:', err);
    return false;
  }
}

/**
 * Salvar venda no servidor ALÉM de IndexedDB
 */
async function saveVendaToServer(venda) {
  try {
    if (!isAuthenticated()) return venda;
    
    const res = await fetch('/api/vendas', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeaders()
      },
      body: JSON.stringify({
        produto: venda.produto,
        valor: venda.valor,
        comissao: venda.comissao,
        data: venda.data
      })
    });
    
    if (!res.ok) {
      console.error('Erro ao salvar venda no servidor');
      return venda;
    }
    
    const serverVenda = await res.json();
    console.log('✓ Venda salva no servidor com ID:', serverVenda.id);
    return serverVenda;
  } catch (err) {
    console.error('Erro ao salvar venda no servidor:', err);
    return venda;
  }
}

/**
 * Atualizar venda no servidor
 */
async function updateVendaToServer(venda) {
  try {
    if (!isAuthenticated()) return venda;
    
    const res = await fetch(`/api/vendas/${venda.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeaders()
      },
      body: JSON.stringify({
        produto: venda.produto,
        valor: venda.valor,
        comissao: venda.comissao,
        data: venda.data
      })
    });
    
    if (!res.ok) {
      console.error('Erro ao atualizar venda no servidor');
      return venda;
    }
    
    console.log('✓ Venda atualizada no servidor');
    return await res.json();
  } catch (err) {
    console.error('Erro ao atualizar venda no servidor:', err);
    return venda;
  }
}

/**
 * Deletar venda no servidor
 */
async function deleteVendaFromServer(vendaId) {
  try {
    if (!isAuthenticated()) return true;
    
    const res = await fetch(`/api/vendas/${vendaId}`, {
      method: 'DELETE',
      headers: getAuthHeaders()
    });
    
    if (!res.ok) {
      console.error('Erro ao deletar venda no servidor');
      return false;
    }
    
    console.log('✓ Venda deletada no servidor');
    return true;
  } catch (err) {
    console.error('Erro ao deletar venda no servidor:', err);
    return false;
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
      body: JSON.stringify({ clientes: clientesArray })
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
      body: JSON.stringify({ vendas: vendasArray })
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
