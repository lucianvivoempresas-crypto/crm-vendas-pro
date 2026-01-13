@echo off
chcp 65001 >nul
cd /d C:\crm-vendas-pro
"C:\Program Files\Git\bin\git.exe" config --global user.name "CRM User"
"C:\Program Files\Git\bin\git.exe" config --global user.email "crm@vendas.com"
"C:\Program Files\Git\bin\git.exe" init
"C:\Program Files\Git\bin\git.exe" add .
"C:\Program Files\Git\bin\git.exe" commit -m "CRM Vendas Pro - Deploy ready"
"C:\Program Files\Git\bin\git.exe" status
pause
