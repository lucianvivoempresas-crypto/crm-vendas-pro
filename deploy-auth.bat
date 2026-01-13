@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Adicionando sistema de autenticacao
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" add .
"C:\Program Files\Git\bin\git.exe" commit -m "Feature: implementar autenticacao com JWT e bcrypt"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Deploy em progresso
echo ========================================
echo.
echo Aguarde 3-5 minutos para reconstrucao
echo.
echo Depois teste:
echo 1. Abra: https://crm-vendas-pro.onrender.com
echo 2. Clique em "Registrar"
echo 3. Crie uma conta
echo 4. Faca login
echo 5. Comece a usar o CRM
echo.
pause
