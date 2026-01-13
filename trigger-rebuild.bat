@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Forcar rebuild do Render
echo ========================================
echo.

REM Fazer um commit vazio para forcar rebuild
"C:\Program Files\Git\bin\git.exe" commit --allow-empty -m "Trigger: rebuild do Render para instalar dependencias"

echo.
echo Fazendo push para trigger rebuild...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo Render vai fazer rebuild completo
echo ========================================
echo.
echo Abra: https://dashboard.render.com
echo Veja em "Logs" ate terminar
echo Demorara 5-10 minutos
echo.
pause
