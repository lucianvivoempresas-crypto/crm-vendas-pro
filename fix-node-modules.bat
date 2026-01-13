@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Removendo node_modules do Git
echo ========================================
echo.

REM Remover node_modules do histórico do Git
"C:\Program Files\Git\bin\git.exe" rm -r --cached node_modules backend/node_modules 2>nul

REM Adicionar ao .gitignore se não existir
echo node_modules/ >> .gitignore

echo.
echo Commitando remocao...
echo.

"C:\Program Files\Git\bin\git.exe" add .gitignore
"C:\Program Files\Git\bin\git.exe" commit -m "Remove: node_modules do repositorio (rebuild em Linux)"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Render vai rebuild do zero
echo ========================================
echo.
echo Aguarde 5-10 minutos para build completo
echo.
pause
