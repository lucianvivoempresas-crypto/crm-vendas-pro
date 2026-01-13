@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Corrigindo autenticacao com cookies
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" add .
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: usar cookies HTTP para autenticacao persistente entre paginas"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Sistema de cookies implementado
echo ========================================
echo.
echo Aguarde 3-5 minutos para rebuild
echo.
echo Agora vai funcionar:
echo 1. Acessa: https://crm-vendas-pro.onrender.com
echo 2. Mostra login.html (sem token no cookie)
echo 3. Login: 02850697567 / JL10@dez
echo 4. Cookie é salvo automaticamente
echo 5. Redireciona para CRM
echo 6. Logout limpa o cookie
echo 7. Volta para login
echo.
pause
