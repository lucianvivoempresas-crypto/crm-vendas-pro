@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Adicionando server.js na raiz
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" add server.js
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: criar server.js na raiz que aponta para backend"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Render vai rebuild agora
echo ========================================
echo.
echo Abra: https://dashboard.render.com
echo Veja os logs em: 2-3 minutos
echo.
echo A URL sera: https://crm-vendas-pro.onrender.com
echo.
pause
