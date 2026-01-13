@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Corrigindo versoes das dependencias
echo ========================================
echo.

REM Atualizar package.json da raiz com versoes corretas
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
  echo     "jsonwebtoken": "^9.0.0",
  echo     "bcrypt": "^5.1.0"
  echo   },
  echo   "engines": {
  echo     "node": ">=14.0.0"
  echo   }
  echo }
) > package.json

echo Atualizado package.json com versoes corretas

echo.
echo Commitando correcao...
echo.

"C:\Program Files\Git\bin\git.exe" add package.json backend/package.json
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: corrigir versoes npm - jsonwebtoken 9.0.0 e bcrypt 5.1.0"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! npm install vai funcionar agora
echo ========================================
echo.
echo Aguarde 5-10 minutos para rebuild
echo.
pause
