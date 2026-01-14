# Script de Setup Automatico - Render Deploy
# Execute: powershell -ExecutionPolicy Bypass -File .\setup-render-simple.ps1

Write-Host ""
Write-Host "=========================================="
Write-Host "  SETUP AUTOMATICO - RENDER DEPLOY"
Write-Host "  CRM Vendas Pro - PostgreSQL"
Write-Host "=========================================="
Write-Host ""

# ===== 1. VERIFICAR PRE-REQUISITOS =====
Write-Host "[1/7] Verificando pre-requisitos..." -ForegroundColor Cyan

Write-Host "  Verificando Git... " -NoNewline
$gitVersion = git --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK" -ForegroundColor Green
    Write-Host "    $gitVersion"
} else {
    Write-Host "FALHA" -ForegroundColor Red
    Write-Host "    Git nao instalado. Instale em: https://git-scm.com" -ForegroundColor Red
    exit 1
}

Write-Host "  Verificando Node.js... " -NoNewline
$nodeVersion = node --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK" -ForegroundColor Green
    Write-Host "    $nodeVersion"
} else {
    Write-Host "FALHA" -ForegroundColor Red
    Write-Host "    Node.js nao instalado. Instale em: https://nodejs.org" -ForegroundColor Red
    exit 1
}

Write-Host "  Verificando npm... " -NoNewline
$npmVersion = npm --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK" -ForegroundColor Green
    Write-Host "    npm $npmVersion"
} else {
    Write-Host "FALHA" -ForegroundColor Red
    Write-Host "    npm nao encontrado" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ===== 2. PREPARAR GIT =====
Write-Host "[2/7] Preparando repositorio Git..." -ForegroundColor Cyan

if (-not (Test-Path ".gitignore")) {
    Write-Host "  Criando .gitignore... " -NoNewline
    $gitignore = "node_modules/`n.env`n.env.local`ncrm.sqlite`n*.log`n.DS_Store`ndist/`nbuild/`n"
    Set-Content -Path ".gitignore" -Value $gitignore -Encoding UTF8
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "  .gitignore ja existe" -ForegroundColor Green
}

if (-not (Test-Path ".git")) {
    Write-Host "  Inicializando Git... " -NoNewline
    git init 2>&1 | Out-Null
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "  Repositorio Git ja existe" -ForegroundColor Green
}

Write-Host "  Verificando credenciais Git... " -NoNewline
$gitUser = git config --global user.name 2>&1
if ([string]::IsNullOrEmpty($gitUser) -or $gitUser -like "*fatal*") {
    Write-Host ""
    Write-Host "    Configurando Git..."
    $email = Read-Host "      Email"
    $name = Read-Host "      Nome"
    
    git config --global user.email $email 2>&1 | Out-Null
    git config --global user.name $name 2>&1 | Out-Null
    Write-Host "    OK - Git configurado" -ForegroundColor Green
} else {
    Write-Host "OK" -ForegroundColor Green
    Write-Host "    Usuario: $gitUser"
}

Write-Host ""

# ===== 3. GERAR JWT SECRET =====
Write-Host "[3/7] Gerando credenciais seguras..." -ForegroundColor Cyan
Write-Host "  Gerando JWT_SECRET... " -NoNewline

$bytes = New-Object Byte[] 32
$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
$rng.GetBytes($bytes)
$jwtSecret = -join ($bytes | ForEach-Object { "{0:x2}" -f $_ })
Write-Host "OK" -ForegroundColor Green
Write-Host "    IMPORTANTE: Copie e guarde em local seguro!" -ForegroundColor Yellow

Write-Host ""

# ===== 4. VERIFICAR ARQUIVOS =====
Write-Host "[4/7] Verificando arquivos essenciais..." -ForegroundColor Cyan

$files = @("backend/server.js", "backend/db.js", "backend/package.json", "backend/auth.js")
$allFound = $true

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  OK - $file" -ForegroundColor Green
    } else {
        Write-Host "  FALTA - $file" -ForegroundColor Red
        $allFound = $false
    }
}

if (-not $allFound) {
    Write-Host ""
    Write-Host "  ERRO: Alguns arquivos estao faltando!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ===== 5. GIT COMMIT =====
Write-Host "[5/7] Fazendo commit do codigo..." -ForegroundColor Cyan

Write-Host "  Adicionando arquivos... " -NoNewline
git add . 2>&1 | Out-Null
Write-Host "OK" -ForegroundColor Green

$status = git status --porcelain 2>&1
if ($status) {
    Write-Host "  Criando commit... " -NoNewline
    git commit -m "Deploy Render: PostgreSQL v2.0.0" 2>&1 | Out-Null
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "  Nenhuma mudanca a commitar" -ForegroundColor Green
}

Write-Host ""

# ===== 6. VERIFICAR GITHUB =====
Write-Host "[6/7] Status do repositorio remoto..." -ForegroundColor Cyan

$remoteUrl = git remote get-url origin 2>&1
if ($remoteUrl -and $remoteUrl -notlike "*fatal*") {
    Write-Host "  Remote ja configurado" -ForegroundColor Green
    Write-Host "    URL: $remoteUrl"
} else {
    Write-Host "  ATENCAO: Remote nao configurado" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Proximos passos:"
    Write-Host "    1. Crie repositorio em github.com"
    Write-Host "    2. Execute:"
    Write-Host '       git remote add origin https://github.com/SEU_USER/crm-vendas-pro.git'
    Write-Host "       git branch -M main"
    Write-Host "       git push -u origin main"
    Write-Host ""
}

Write-Host ""

# ===== 7. CRIAR ARQUIVO VARIAVEIS =====
Write-Host "[7/7] Criando arquivo de configuracao..." -ForegroundColor Cyan
Write-Host "  Criando render-env.txt... " -NoNewline

$envContent = @"
# Copie estas variaveis para o Render Dashboard
# Settings -> Environment Variables

PORT=10000
HOST=0.0.0.0
NODE_ENV=production

# PostgreSQL - PREENCHER DO RENDER
DB_HOST=seu-db.render.com
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=sua-senha-do-render
DB_NAME=crm_vendas_pro

# Seguranca
JWT_SECRET=$jwtSecret

# Instrucoes:
# 1. No Render, copie a connection string do PostgreSQL
# 2. Extraia DB_HOST, DB_USER, DB_PASSWORD
# 3. Cole as variaveis acima no Dashboard
"@

Set-Content -Path "render-env.txt" -Value $envContent -Encoding UTF8
Write-Host "OK" -ForegroundColor Green
Write-Host "    Arquivo criado: render-env.txt" -ForegroundColor Yellow

Write-Host ""
Write-Host "=========================================="
Write-Host ""
Write-Host "SUCESSO! SETUP CONCLUIDO" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "[1] GITHUB"
Write-Host "    - Vá em github.com"
Write-Host "    - Crie repositorio: crm-vendas-pro"
Write-Host "    - Execute os comandos git (veja acima)"
Write-Host ""
Write-Host "[2] RENDER - PostgreSQL"
Write-Host "    - Vá em render.com"
Write-Host "    - New + -> PostgreSQL"
Write-Host "    - Nome: crm-vendas-pro-db"
Write-Host "    - Aguarde 2-5 minutos"
Write-Host ""
Write-Host "[3] RENDER - Web Service"
Write-Host "    - New + -> Web Service"
Write-Host "    - Conectar GitHub"
Write-Host "    - Build: npm install"
Write-Host "    - Start: node backend/server.js"
Write-Host ""
Write-Host "[4] RENDER - Variaveis"
Write-Host "    - Copie conteudo de render-env.txt"
Write-Host "    - Cole em Environment Variables"
Write-Host ""
Write-Host "[5] TESTE"
Write-Host "    - Acesse: https://seu-servico.onrender.com"
Write-Host "    - Email: admin@crm.local"
Write-Host "    - Senha: JL10@dez"
Write-Host "    - MUDE A SENHA!"
Write-Host ""
Write-Host "=========================================="
Write-Host ""
Write-Host "CREDENCIAIS GERADAS:" -ForegroundColor Green
Write-Host ""
Write-Host "JWT_SECRET (COPIE E GUARDE):"
Write-Host "$jwtSecret" -ForegroundColor Yellow
Write-Host ""
Write-Host "=========================================="
Write-Host ""
