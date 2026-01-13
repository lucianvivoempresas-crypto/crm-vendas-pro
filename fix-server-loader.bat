@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Criando server.js loader na raiz
echo ========================================
echo.

REM Criar server.js loader
(
  echo // server.js - Loader que aponta para backend/server.js
  echo // Necessario porque Render procura aqui
  echo require('./backend/server.js');
) > server.js

echo Created server.js na raiz

echo.
echo Atualizando Procfile...
(
  echo web: node server.js
) > Procfile

echo.
echo Commitando...
echo.

"C:\Program Files\Git\bin\git.exe" add server.js Procfile
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: criar server.js loader na raiz para Render encontrar"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Render vai iniciar corretamente
echo ========================================
echo.
echo Aguarde 3-5 minutos para rebuild
echo.
echo Depois teste em:
echo https://crm-vendas-pro.onrender.com
echo.
pause
