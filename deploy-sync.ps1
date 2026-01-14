# Deploy script - Sincronização de dados com servidor
Write-Host "===== Deploy: Sincronizacao de Dados com Servidor =====" -ForegroundColor Cyan
Write-Host ""

Set-Location C:\crm-vendas-pro

Write-Host "[1] Verificando status git..."
& git status

Write-Host ""
Write-Host "[2] Adicionando mudancas..."
& git add -A

Write-Host ""
Write-Host "[3] Fazendo commit..."
& git commit -m "feat: sincronizacao de dados com servidor (clientes/vendas) e correcoes de autenticacao"

Write-Host ""
Write-Host "[4] Fazendo push..."
& git push

Write-Host ""
Write-Host "===== Deploy Completo! =====" -ForegroundColor Green
Write-Host ""
Write-Host "Mudancas implementadas:" -ForegroundColor Yellow
Write-Host "✓ Endpoints API expandidos (PUT/DELETE para clientes/vendas)"
Write-Host "✓ Bulk import endpoints (/api/bulk/clientes, /api/bulk/vendas)"
Write-Host "✓ sync-frontend.js - Sincronizacao bidirecional cliente/servidor"
Write-Host "✓ Dados importados agora sao salvos tanto em IndexedDB como no servidor"
Write-Host "✓ Na inicializacao, dados do servidor sao carregados para IndexedDB"
Write-Host "✓ Autenticacao: Register agora salva token em cookie"
Write-Host ""
Write-Host "Proxy da Render (crm-vendas-pro.onrender.com) ira fazer rebuild automatico em 3-5 minutos" -ForegroundColor Yellow
Write-Host ""
Read-Host "Pressione Enter para continuar"
