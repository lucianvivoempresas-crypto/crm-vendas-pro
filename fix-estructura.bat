@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Corrigindo estrutura do projeto
echo ========================================
echo.

REM Criar novo package.json correto na raiz
(
  echo {
  echo   "name": "crm-vendas-pro",
  echo   "version": "2.0.0",
  echo   "description": "CRM Sistema de Gestao de Vendas Online",
  echo   "main": "backend/server.js",
  echo   "scripts": {
  echo     "start": "node backend/server.js",
  echo     "dev": "node backend/server.js"
  echo   },
  echo   "dependencies": {
  echo     "express": "^4.18.2",
  echo     "sqlite3": "^5.1.6",
  echo     "jsonwebtoken": "^9.1.2",
  echo     "bcrypt": "^5.1.1"
  echo   },
  echo   "engines": {
  echo     "node": ">=14.0.0"
  echo   }
  echo }
) > package.json

echo Created package.json na raiz

echo.
echo Removendo server.js da raiz (alias errado)...
del server.js 2>nul

echo.
echo Atualizando Procfile...
(
  echo web: node backend/server.js
) > Procfile

echo.
echo Commitando correcoes...
echo.

"C:\Program Files\Git\bin\git.exe" add package.json Procfile
"C:\Program Files\Git\bin\git.exe" rm --cached server.js 2>nul
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: corrigir estrutura - remover server.js, atualizar package.json com dependencias"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Render vai instalar dependencias
echo ========================================
echo.
echo Aguarde 5-10 minutos para rebuild
echo.
pause
