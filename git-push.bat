@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Conectando ao GitHub...
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" remote add origin https://github.com/lucianvivoempresas-crypto/crm-vendas-pro.git

echo.
echo ========================================
echo Renomeando branch para 'main'...
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" branch -M main

echo.
echo ========================================
echo Fazendo PUSH para GitHub...
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" push -u origin main

echo.
echo ========================================
echo SUCESSO! Verificando...
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" remote -v

echo.
echo Seu repositorio esta em:
echo https://github.com/lucianvivoempresas-crypto/crm-vendas-pro
echo.
pause
