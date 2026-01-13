@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro

echo.
echo ========================================
echo Implementando RBAC (Role-Based Access)
echo ========================================
echo.

"C:\Program Files\Git\bin\git.exe" add .
"C:\Program Files\Git\bin\git.exe" commit -m "Feature: implementar RBAC - admin vê todas vendas, users vêem só suas"

echo.
echo Fazendo push...
echo.

"C:\Program Files\Git\bin\git.exe" push origin main

echo.
echo ========================================
echo PRONTO! Novo sistema implementado
echo ========================================
echo.
echo CREDENCIAIS ADMIN (criadas automaticamente):
echo   Login: 02850697567 (ou admin@crm.local)
echo   Senha: JL10@dez
echo.
echo Aguarde 3-5 minutos para rebuild
echo.
echo Depois teste:
echo 1. Acesse: https://crm-vendas-pro.onrender.com
echo 2. Login com: 02850697567 / JL10@dez
echo 3. Admin verá TODAS as vendas
echo 4. Outros usuários verão apenas suas vendas
echo.
pause
