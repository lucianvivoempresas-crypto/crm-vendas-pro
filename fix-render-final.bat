@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Atualizando repositorio no GitHub...
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" add .gitignore package.json render.yaml
"C:\Program Files\Git\bin\git.exe" commit -m "Fix: .gitignore, dependencies e render config"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Render vai rebuild
echo ========================================
echo.
echo Acessando logs do Render...
echo Abra: https://dashboard.render.com
echo.
pause
