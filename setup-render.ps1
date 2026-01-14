#!/usr/bin/env powershell
# Script de Setup Automático - Render Deploy
# Execute: powershell -ExecutionPolicy Bypass -File .\setup-render.ps1

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    🚀 SETUP AUTOMÁTICO - RENDER DEPLOY                     ║" -ForegroundColor Cyan
Write-Host "║                                                                            ║" -ForegroundColor Cyan
Write-Host "║                CRM Vendas Pro - PostgreSQL para Render                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Cores
$green = "Green"
$red = "Red"
$yellow = "Yellow"
$cyan = "Cyan"

# ===== 1. VERIFICAR PRÉ-REQUISITOS =====
Write-Host "1️⃣  Verificando pré-requisitos..." -ForegroundColor $cyan
Write-Host "───────────────────────────────────────────────────────────────────────────────"

# Verificar Git
Write-Host "  ⏳ Verificando Git... " -NoNewline
try {
    $gitVersion = & git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓" -ForegroundColor $green
        Write-Host "    $gitVersion"
    } else {
        Write-Host "✗" -ForegroundColor $red
        Write-Host "    ❌ Git não instalado. Instale em: https://git-scm.com" -ForegroundColor $red
        exit 1
    }
} catch {
    Write-Host "✗" -ForegroundColor $red
    Write-Host "    ❌ Git não instalado. Instale em: https://git-scm.com" -ForegroundColor $red
    exit 1
}

# Verificar Node.js
Write-Host "  ⏳ Verificando Node.js... " -NoNewline
try {
    $nodeVersion = & node --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓" -ForegroundColor $green
        Write-Host "    $nodeVersion"
    } else {
        Write-Host "✗" -ForegroundColor $red
        Write-Host "    ❌ Node.js não instalado. Instale em: https://nodejs.org" -ForegroundColor $red
        exit 1
    }
} catch {
    Write-Host "✗" -ForegroundColor $red
    Write-Host "    ❌ Node.js não instalado. Instale em: https://nodejs.org" -ForegroundColor $red
    exit 1
}

# Verificar npm
Write-Host "  ⏳ Verificando npm... " -NoNewline
try {
    $npmVersion = & npm --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓" -ForegroundColor $green
        Write-Host "    npm $npmVersion"
    } else {
        Write-Host "✗" -ForegroundColor $red
        Write-Host "    ❌ npm não encontrado" -ForegroundColor $red
        exit 1
    }
} catch {
    Write-Host "✗" -ForegroundColor $red
    Write-Host "    ❌ npm não encontrado" -ForegroundColor $red
    exit 1
}

Write-Host ""

# ===== 2. PREPARAR GIT =====
Write-Host "2️⃣  Preparando repositório Git..." -ForegroundColor $cyan
Write-Host "───────────────────────────────────────────────────────────────────────────────"

# Criar .gitignore se não existir
if (-not (Test-Path ".gitignore")) {
    Write-Host "  ⏳ Criando .gitignore... " -NoNewline
    $gitignore = @"
node_modules/
.env
.env.local
crm.sqlite
*.log
.DS_Store
dist/
build/
"@
    Set-Content -Path ".gitignore" -Value $gitignore -Encoding UTF8
    Write-Host "✓" -ForegroundColor $green
} else {
    Write-Host "  ✓ .gitignore já existe" -ForegroundColor $green
}

# Verificar se git está inicializado
if (-not (Test-Path ".git")) {
    Write-Host "  ⏳ Inicializando Git... " -NoNewline
    & git init 2>&1 | Out-Null
    Write-Host "✓" -ForegroundColor $green
} else {
    Write-Host "  ✓ Repositório Git já existe" -ForegroundColor $green
}

# Verificar credenciais git
Write-Host "  ⏳ Verificando credenciais Git... " -NoNewline
$gitUser = & git config --global user.name 2>&1
if ([string]::IsNullOrEmpty($gitUser) -or $gitUser -like "*fatal*") {
    Write-Host ""
    Write-Host ""
    Write-Host "    ⚠️  Configure seu Git primeiro:" -ForegroundColor $yellow
    $email = Read-Host "    📧 Email"
    $name = Read-Host "    👤 Nome"
    
    & git config --global user.email $email 2>&1 | Out-Null
    & git config --global user.name $name 2>&1 | Out-Null
    Write-Host "    ✓ Git configurado" -ForegroundColor $green
} else {
    Write-Host "✓" -ForegroundColor $green
    Write-Host "    Usuário: $gitUser"
}

Write-Host ""

# ===== 3. GERAR JWT SECRET =====
Write-Host "3️⃣  Gerando credenciais seguras..." -ForegroundColor $cyan
Write-Host "───────────────────────────────────────────────────────────────────────────────"

Write-Host "  ⏳ Gerando JWT_SECRET... " -NoNewline
$bytes = New-Object Byte[] 32
$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
$rng.GetBytes($bytes)
$jwtSecret = -join ($bytes | ForEach-Object { "{0:x2}" -f $_ })
Write-Host "✓" -ForegroundColor $green
Write-Host "    ⚠️  JWT_SECRET gerado (salve em local seguro!)" -ForegroundColor $yellow

Write-Host ""

# ===== 4. VERIFICAR ARQUIVOS NECESSÁRIOS =====
Write-Host "4️⃣  Verificando arquivos essenciais..." -ForegroundColor $cyan
Write-Host "───────────────────────────────────────────────────────────────────────────────"

$files = @("backend/server.js", "backend/db.js", "backend/package.json", "backend/auth.js")
$allFound = $true

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor $green
    } else {
        Write-Host "  ✗ $file" -ForegroundColor $red
        $allFound = $false
    }
}

if (-not $allFound) {
    Write-Host ""
    Write-Host "  ❌ Alguns arquivos estão faltando!" -ForegroundColor $red
    exit 1
}

Write-Host ""

# ===== 5. FAZER GIT COMMIT =====
Write-Host "5️⃣  Fazendo commit do código..." -ForegroundColor $cyan
Write-Host "───────────────────────────────────────────────────────────────────────────────"

Write-Host "  ⏳ Adicionando arquivos... " -NoNewline
& git add . 2>&1 | Out-Null
Write-Host "✓" -ForegroundColor $green

# Verificar se há mudanças
$status = & git status --porcelain 2>&1
if ($status) {
    Write-Host "  ⏳ Criando commit... " -NoNewline
    & git commit -m "Deploy Render: PostgreSQL v2.0.0" 2>&1 | Out-Null
    Write-Host "✓" -ForegroundColor $green
} else {
    Write-Host "  ✓ Nenhuma mudança a commitar" -ForegroundColor $green
}

Write-Host ""

# ===== 6. VERIFICAR GITHUB =====
Write-Host "6️⃣  Status do repositório remoto..." -ForegroundColor $cyan
Write-Host "───────────────────────────────────────────────────────────────────────────────"

$remoteUrl = & git remote get-url origin 2>&1
if ($remoteUrl -and $remoteUrl -notlike "*fatal*") {
    Write-Host "  ✓ Remote já configurado" -ForegroundColor $green
    Write-Host "    URL: $remoteUrl"
} else {
    Write-Host "  ⚠️  Remote não configurado" -ForegroundColor $yellow
    Write-Host ""
    Write-Host "  📝 Próximos passos:" -ForegroundColor $cyan
    Write-Host "    1. Crie um repositório em github.com"
    Write-Host "    2. Execute:"
    Write-Host "       git remote add origin https://github.com/SEU_USER/crm-vendas-pro.git"
    Write-Host "       git branch -M main"
    Write-Host "       git push -u origin main"
    Write-Host ""
}

Write-Host ""

# ===== 7. CRIAR ARQUIVO DE VARIÁVEIS =====
Write-Host "7️⃣  Criando arquivo de configuração Render..." -ForegroundColor $cyan
Write-Host "───────────────────────────────────────────────────────────────────────────────"

Write-Host "  ⏳ Criando render-env.txt... " -NoNewline

$envContent = @"
# Copie estas variáveis para o Render Dashboard
# Settings → Environment Variables

PORT=10000
HOST=0.0.0.0
NODE_ENV=production

# PostgreSQL - PREENCHER DO RENDER
DB_HOST=seu-db.render.com
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=sua-senha-do-render
DB_NAME=crm_vendas_pro

# Segurança
JWT_SECRET=$jwtSecret

# Instruções:
# 1. No Render, copie a connection string do PostgreSQL
# 2. Extraia DB_HOST, DB_USER, DB_PASSWORD
# 3. Cole as variáveis acima no Dashboard
"@

Set-Content -Path "render-env.txt" -Value $envContent -Encoding UTF8
Write-Host "✓" -ForegroundColor $green
Write-Host "    ⚠️  Arquivo criado: render-env.txt" -ForegroundColor $yellow

Write-Host ""

# ===== RESUMO FINAL =====
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "✅ SETUP CONCLUÍDO!" -ForegroundColor $green
Write-Host ""
Write-Host "📋 PRÓXIMOS PASSOS:" -ForegroundColor $cyan
Write-Host ""
Write-Host "1️⃣  GITHUB" -ForegroundColor $cyan
Write-Host "    Se ainda não tiver repositório remoto:"
Write-Host "    • Vá em github.com"
Write-Host "    • Crie repositório: crm-vendas-pro"
Write-Host "    • Execute:"
Write-Host "      $yellow git remote add origin https://github.com/SEU_USER/crm-vendas-pro.git$green"
Write-Host "      $yellow git branch -M main$green"
Write-Host "      $yellow git push -u origin main$green"
Write-Host ""
Write-Host "2️⃣  RENDER - CRIAR POSTGRESQL" -ForegroundColor $cyan
Write-Host "    • Vá em render.com"
Write-Host "    • Dashboard → New + → PostgreSQL"
Write-Host "    • Nome: crm-vendas-pro-db"
Write-Host "    • Aguarde 2-5 minutos"
Write-Host "    • Copie a connection string"
Write-Host ""
Write-Host "3️⃣  RENDER - CRIAR WEB SERVICE" -ForegroundColor $cyan
Write-Host "    • Dashboard → New + → Web Service"
Write-Host "    • Conectar repositório GitHub"
Write-Host "    • Build: npm install"
Write-Host "    • Start: node backend/server.js"
Write-Host ""
Write-Host "4️⃣  RENDER - ADICIONAR VARIÁVEIS" -ForegroundColor $cyan
Write-Host "    • Abra: render-env.txt (criado neste diretório)"
Write-Host "    • Copie todas as variáveis"
Write-Host "    • Dashboard → Web Service → Environment"
Write-Host "    • Cole cada variável"
Write-Host ""
Write-Host "5️⃣  RENDER - FAZER DEPLOY" -ForegroundColor $cyan
Write-Host "    • Dashboard → Manual Deploy"
Write-Host "    • Ou: git push origin main (auto-deploy)"
Write-Host ""
Write-Host "6️⃣  TESTAR" -ForegroundColor $cyan
Write-Host "    • https://seu-servico.onrender.com"
Write-Host "    • Email: admin@crm.local"
Write-Host "    • Senha: JL10@dez"
Write-Host "    • $yellow Mudar senha após login!" -ForegroundColor $green
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "🔐 CREDENCIAIS GERADAS:" -ForegroundColor $green
Write-Host ""
Write-Host "  ⚠️  JWT_SECRET (copie e guarde em local seguro):" -ForegroundColor $yellow
Write-Host "  $jwtSecret"
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "📖 DOCUMENTAÇÃO:" -ForegroundColor $cyan
Write-Host "    • DEPLOY_RENDER.md (guia completo)"
Write-Host "    • RENDER_CHECKLIST.md (passo a passo)"
Write-Host "    • render-env.txt (variáveis geradas)"
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "🚀 Tudo pronto! Siga os próximos passos acima para fazer deploy." -ForegroundColor $green
Write-Host ""
