#!/usr/bin/env powershell
# Script para configurar Git e fazer commit

Set-Location "C:\crm-vendas-pro"

# Configurar Git
& "C:\Program Files\Git\bin\git.exe" config --global user.name "CRM User"
& "C:\Program Files\Git\bin\git.exe" config --global user.email "crm@vendas.com"

# Inicializar repositório
& "C:\Program Files\Git\bin\git.exe" init

# Adicionar arquivos
& "C:\Program Files\Git\bin\git.exe" add .

# Fazer commit
& "C:\Program Files\Git\bin\git.exe" commit -m "CRM Vendas Pro - Pronto para deploy"

# Status
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Git inicializado com sucesso!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

& "C:\Program Files\Git\bin\git.exe" status
