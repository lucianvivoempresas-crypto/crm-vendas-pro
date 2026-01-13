@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Adicionando Procfile e render.yaml
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" add Procfile render.yaml
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: Add Procfile para indicar start command correto"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Render vai rebuild com Procfile
echo ========================================
echo.
echo Logs do Render (ir para Settings e ver logs):
echo https://dashboard.render.com/services/crm-vendas-pro
echo.
pause
