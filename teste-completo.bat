@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo TESTE FINAL - Verificando tudo
echo ========================================
echo.

echo [1] Verificando arquivos essenciais...
if exist "package.json" echo ✓ package.json OK
if exist "Procfile" echo ✓ Procfile OK
if exist "render.yaml" echo ✓ render.yaml OK
if exist "backend\server.js" echo ✓ backend\server.js OK
if exist "backend\frontend\index.html" echo ✓ frontend\index.html OK

echo.
echo [2] Verificando Git...
"C:\Program Files\Git\bin\git.exe" log --oneline -3

echo.
echo [3] Status do Git...
"C:\Program Files\Git\bin\git.exe" status

echo.
echo ========================================
echo INSTRUCOES FINAIS
echo ========================================
echo.
echo 1. Acesse: https://dashboard.render.com
echo 2. Clique em "crm-vendas-pro"
echo 3. Veja a aba "Logs"
echo 4. Aguarde ate ver: "CRM Vendas Pro rodando em..."
echo 5. Depois acesse: https://crm-vendas-pro.onrender.com
echo.
echo Se tiver erro, me manda a screenshot do log!
echo.
pause
