# Instruções de Deploy - Importante!

## Status das Mudanças

Todos os seguintes arquivos foram modificados e estão prontos para serem commitados:

1. **backend/server.js**
   - Adicionado logs melhores para autenticação na rota `/`
   - Desabilitado cache agressivo
   - Melhorada verificação de cookie

2. **backend/frontend/auth-frontend.js**
   - Adicionado `credentials: 'include'` no fetch de login
   - Adicionado `credentials: 'include'` no fetch de register
   - Agora o navegador SEMPRE envia cookies automaticamente

3. **backend/frontend/sync-frontend.js**
   - Adicionado `credentials: 'include'` em TODOS os 8 fetch calls:
     - POST /api/clientes (novo)
     - PUT /api/clientes/:id (update)
     - DELETE /api/clientes/:id (delete)
     - POST /api/vendas (novo)
     - PUT /api/vendas/:id (update)
     - DELETE /api/vendas/:id (delete)
     - POST /api/bulk/clientes (import)
     - POST /api/bulk/vendas (import)

## O Problema Anterior

O navegador **NÃO estava enviando o cookie automaticamente** para o servidor em requisições AJAX (fetch).
Isso acontecia porque:

```javascript
// ANTES - Cookie NÃO era enviado
const res = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, senha })
});

// AGORA - Cookie É enviado automaticamente
const res = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, senha }),
  credentials: 'include'  // ← ISSO ENVIA O COOKIE!
});
```

## Proximos Passos - VOCÊ PRECISA FAZER

Abra um terminal PowerShell e execute:

```powershell
cd C:\crm-vendas-pro

# Ver o que mudou
git status

# Adicionar os arquivos
git add backend/server.js backend/frontend/auth-frontend.js backend/frontend/sync-frontend.js

# Fazer commit
git commit -m "fix: adicionar credentials include nos fetches para enviar cookies automaticamente"

# Fazer push
git push

# Verificar se funcionou
git log --oneline -n 3
```

## Resultado Esperado

Após fazer o push:
1. GitHub receberá as mudanças
2. Render verá o novo commit (em 1-2 minutos)
3. Render fará rebuild automático (3-5 minutos)
4. App em crm-vendas-pro.onrender.com terá as novas mudanças

## Testando Depois do Deploy

1. Acesse https://crm-vendas-pro.onrender.com/
2. Se não tiver cookie:
   - Deve mostrar **login.html** (NÃO o CRM)
   - Você verá a tela de login

3. Login com:
   - Email ou CPF: **02850697567**
   - Senha: **JL10@dez**

4. Após login:
   - Cookie `auth_token` será criado
   - Browser enviará cookie em todas as requisições
   - Rota `/` do servidor verificará cookie
   - Você será redirecionado para **index.html** (CRM)

5. Abrir em outro dispositivo com mesmo login:
   - Dados importados devem sincronizar
   - Tudo deve estar salvo no SQLite do servidor

## Se Ainda Não Funcionar

Possíveis causas:

1. **Cache do navegador** - Limpe:
   - Ctrl+Shift+Delete → Limpar cache
   - Ou Ctrl+F5 para hard refresh

2. **Render ainda com code antigo**
   - Ir para https://dashboard.render.com
   - Procurar o projeto "crm-vendas-pro"
   - Clicar em "Manual Deploy" para forçar rebuild

3. **Cookie não está sendo definido**
   - Abrir DevTools (F12)
   - Ir para aba "Application" → "Cookies"
   - Verificar se `auth_token` aparece

4. **Servidor não recebendo cookie**
   - Logs do servidor devem mostrar: `[AUTH] Cookie: SIM` ou `[AUTH] Cookie: NÃO`
   - Se `NÃO`, o problema é que o navegador não está enviando

## Próximas Melhorias

Após confirmar que login funciona:

1. Testar importação de dados
2. Verificar sincronização em outro dispositivo
3. Implementar interface admin para criar usuários
4. Adicionar tela de gerenciamento de usuários
