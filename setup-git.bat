@echo off
cd /d c:\crm-vendas-pro

REM Configurar Git
git config --global user.name "CRM User"
git config --global user.email "crm@vendas.com"

REM Inicializar repositório
git init

REM Adicionar todos os arquivos
git add .

REM Fazer commit
git commit -m "CRM Vendas Pro - Pronto para deploy"

REM Mostrar status
git status

REM Mostrar informações
echo.
echo ========================================
echo Git inicializado com sucesso!
echo ========================================
echo.
pause
