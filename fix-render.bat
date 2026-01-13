@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Commitando arquivos corrigidos...
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" add package.json render.yaml
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: adicionar package.json na raiz para Render"

echo.
echo ========================================
echo Fazendo push...
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Render vai fazer rebuild automaticamente
echo ========================================
echo.
echo Aguarde 2-3 minutos e acesse:
echo https://crm-vendas-pro.onrender.com
echo.
pause
