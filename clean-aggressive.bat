@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo LIMPEZA AGRESSIVA - Remover node_modules
echo ========================================
echo.

REM Remove node_modules do cache Git (force)
"C:\Program Files\Git\bin\git.exe" rm -r --cached node_modules 2>nul
"C:\Program Files\Git\bin\git.exe" rm -r --cached backend/node_modules 2>nul
"C:\Program Files\Git\bin\git.exe" rm -r --cached src/backend/node_modules 2>nul

REM Apagar node_modules localmente
if exist "node_modules" rmdir /s /q node_modules
if exist "backend\node_modules" rmdir /s /q backend\node_modules
if exist "src\backend\node_modules" rmdir /s /q src\backend\node_modules

echo.
echo Verificando .gitignore...
echo.

REM Atualizar .gitignore
(
    echo node_modules/
    echo npm-debug.log*
    echo *.sqlite
    echo *.sqlite-journal
) > .gitignore.new

REM Backup do antigo
ren .gitignore .gitignore.bak 2>nul
ren .gitignore.new .gitignore

echo.
echo Commitando limpeza...
echo.

"C:\Program Files\Git\bin\git.exe" add .gitignore
"C:\Program Files\Git\bin\git.exe" commit -m "Clean: remover node_modules completamente"

echo.
echo Forcando push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main --force-with-lease

echo.
echo ========================================
echo PRONTO! Rebuild será do zero
echo ========================================
echo.
echo Abra Render Settings e clique "Clear Build Cache"
echo https://dashboard.render.com
echo.
pause
