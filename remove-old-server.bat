@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Removendo arquivo antigo...
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" rm backend/src/server.js --force

echo.
echo Commitando remocao...
echo.

"C:\Program Files\Git\bin\git.exe" commit -m "Remove: arquivo antigo backend/src/server.js"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Render vai rebuild
echo ========================================
echo.
echo Aguarde 3-5 minutos e acesse:
echo https://crm-vendas-pro.onrender.com
echo.
pause
