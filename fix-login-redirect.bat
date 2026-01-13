@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Corrigindo rota de login
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" add .
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: redirecionar para login.html automaticamente se nao autenticado"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Sistema de login corrigido
echo ========================================
echo.
echo Aguarde 3-5 minutos para rebuild
echo.
echo Depois teste:
echo 1. Abra: https://crm-vendas-pro.onrender.com
echo 2. Deve mostrar TELA DE LOGIN automaticamente
echo 3. Login: 02850697567 / JL10@dez
echo 4. Vai redirecionar para CRM
echo 5. Logout vai levar de volta para login
echo.
pause
