@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Testando aplicacao online...
echo ========================================
echo.

REM Teste 1: Verificar se todos os commits foram feitos
"C:\Program Files\Git\bin\git.exe" log --oneline -5

echo.
echo ========================================
echo Status do repositorio:
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" status

echo.
echo ========================================
echo Abrindo dashboard do Render...
echo https://dashboard.render.com
echo ========================================
echo.
echo Aguarde 3-5 minutos para o app iniciar
echo.
pause
