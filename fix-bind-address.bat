@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Corrigindo bind address para 0.0.0.0
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" add backend/server.js
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: bind server em 0.0.0.0 para Render acessar"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Render vai detectar a porta
echo ========================================
echo.
echo Aguarde 2-3 minutos de rebuild
echo.
echo Depois acesse:
echo https://crm-vendas-pro.onrender.com
echo.
pause
