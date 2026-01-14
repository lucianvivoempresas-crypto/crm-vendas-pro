# Script de Deploy Render - PowerShell (Windows)
# Execute: powershell -ExecutionPolicy Bypass -File .\setup-render.ps1

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    🚀 SETUP AUTOMÁTICO - RENDER DEPLOY                     ║" -ForegroundColor Cyan
Write-Host "║                                                                            ║" -ForegroundColor Cyan
Write-Host "║                CRM Vendas Pro - PostgreSQL para Render                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Cores
$success = "Green"
$error = "Red"
$warning = "Yellow"
$info = "Cyan"

# ===== 1. VERIFICAR PRÉ-REQUISITOS =====
Write-Host "1️⃣  Verificando pré-requisitos..." -ForegroundColor $info
Write-Host "─" * 80

# Verificar Git
Write-Host "  ⏳ Verificando Git..." -NoNewline
try {
    $gitVersion = git --version 2>$null
    Write-Host " ✓" -ForegroundColor $success
    Write-Host "    $gitVersion"
} catch {
    Write-Host " ✗" -ForegroundColor $error
    Write-Host "    ❌ Git não instalado. Instale em: https://git-scm.com" -ForegroundColor $error
    exit 1
}

# Verificar Node.js
Write-Host "  ⏳ Verificando Node.js..." -NoNewline
try {
    $nodeVersion = node --version 2>$null
    Write-Host " ✓" -ForegroundColor $success
    Write-Host "    $nodeVersion"
} catch {
    Write-Host " ✗" -ForegroundColor $error
    Write-Host "    ❌ Node.js não instalado. Instale em: https://nodejs.org" -ForegroundColor $error
    exit 1
}

# Verificar npm
Write-Host "  ⏳ Verificando npm..." -NoNewline
try {
    $npmVersion = npm --version 2>$null
    Write-Host " ✓" -ForegroundColor $success
    Write-Host "    npm $npmVersion"
} catch {
    Write-Host " ✗" -ForegroundColor $error
    Write-Host "    ❌ npm não encontrado" -ForegroundColor $error
    exit 1
}

Write-Host ""

# ===== 2. VERIFICAR/CRIAR .GITIGNORE =====
Write-Host "2️⃣  Preparando repositório Git..." -ForegroundColor $info
Write-Host "─" * 80

# Criar .gitignore se não existir
if (-not (Test-Path ".gitignore")) {
    Write-Host "  ⏳ Criando .gitignore..." -NoNewline
    @"
node_modules/
.env
.env.local
crm.sqlite
*.log
.DS_Store
dist/
build/
"@ | Out-File -Encoding UTF8 ".gitignore"
    Write-Host " ✓" -ForegroundColor $success
} else {
    Write-Host "  ✓ .gitignore já existe" -ForegroundColor $success
}

# Verificar se git está inicializado
if (-not (Test-Path ".git")) {
    Write-Host "  ⏳ Inicializando Git..." -NoNewline
    git init | Out-Null
    Write-Host " ✓" -ForegroundColor $success
} else {
    Write-Host "  ✓ Repositório Git já existe" -ForegroundColor $success
}

# Verificar credenciais git
Write-Host "  ⏳ Verificando credenciais Git..." -NoNewline
$gitUser = git config --global user.name 2>$null
if (-not $gitUser) {
    Write-Host ""
    Write-Host ""
    Write-Host "    ⚠️  Configure seu Git primeiro:" -ForegroundColor $warning
    $email = Read-Host "    📧 Email"
    $name = Read-Host "    👤 Nome"
    
    git config --global user.email "$email"
    git config --global user.name "$name"
    Write-Host "    ✓ Git configurado" -ForegroundColor $success
} else {
    Write-Host " ✓" -ForegroundColor $success
    Write-Host "    Usuário: $gitUser"
}

Write-Host ""

# ===== 3. GERAR JWT SECRET =====
Write-Host "3️⃣  Gerando credenciais seguras..." -ForegroundColor $info
Write-Host "─" * 80

Write-Host "  ⏳ Gerando JWT_SECRET..." -NoNewline
$jwtSecret = -join ((1..32) | ForEach-Object { [convert]::ToString((Get-Random -Maximum 16), 16) })
Write-Host " ✓" -ForegroundColor $success
Write-Host "    JWT_SECRET gerado (salve em local seguro!)" -ForegroundColor $warning

Write-Host ""

# ===== 4. CRIAR ARQUIVO .env.example =====
Write-Host "4️⃣  Verificando arquivo .env.example..." -ForegroundColor $info
Write-Host "─" * 80

if (-not (Test-Path "backend\.env.example")) {
    Write-Host "  ⚠️  .env.example não encontrado!" -ForegroundColor $warning
    Write-Host "  Certifique-se de que está no diretório correto" -ForegroundColor $warning
} else {
    Write-Host "  ✓ .env.example encontrado" -ForegroundColor $success
}

Write-Host ""

# ===== 5. VERIFICAR ARQUIVOS NECESSÁRIOS =====
Write-Host "5️⃣  Verificando arquivos essenciais..." -ForegroundColor $info
Write-Host "─" * 80

$files = @(
    "backend\server.js",
    "backend\db.js",
    "backend\package.json",
    "backend\auth.js"
)

$allFound = $true
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor $success
    } else {
        Write-Host "  ✗ $file" -ForegroundColor $error
        $allFound = $false
    }
}

if (-not $allFound) {
    Write-Host ""
    Write-Host "  ❌ Alguns arquivos estão faltando!" -ForegroundColor $error
    exit 1
}

Write-Host ""

# ===== 6. FAZER GIT COMMIT =====
Write-Host "6️⃣  Fazendo commit do código..." -ForegroundColor $info
Write-Host "─" * 80

Write-Host "  ⏳ Adicionando arquivos..." -NoNewline
git add . 2>$null
Write-Host " ✓" -ForegroundColor $success

# Verificar se há mudanças
$status = git status --porcelain 2>$null
if ($status) {
    Write-Host "  ⏳ Criando commit..." -NoNewline
    git commit -m "Deploy Render: PostgreSQL v2.0.0" 2>$null
    Write-Host " ✓" -ForegroundColor $success
} else {
    Write-Host "  ✓ Nenhuma mudança a commitar" -ForegroundColor $success
}

Write-Host ""

# ===== 7. VERIFICAR GITHUB =====
Write-Host "7️⃣  Status do repositório remoto..." -ForegroundColor $info
Write-Host "─" * 80

$remoteUrl = git remote get-url origin 2>$null
if ($remoteUrl) {
    Write-Host "  ✓ Remote já configurado" -ForegroundColor $success
    Write-Host "    URL: $remoteUrl"
} else {
    Write-Host "  ⚠️  Remote não configurado" -ForegroundColor $warning
    Write-Host ""
    Write-Host "  📝 Próximos passos:" -ForegroundColor $info
    Write-Host "    1. Crie um repositório em github.com"
    Write-Host "    2. Execute:" -ForegroundColor $info
    Write-Host "       git remote add origin https://github.com/SEU_USER/crm-vendas-pro.git"
    Write-Host "       git branch -M main"
    Write-Host "       git push -u origin main"
    Write-Host ""
}

Write-Host ""

# ===== 8. CRIAR ARQUIVO DE VARIÁVEIS =====
Write-Host "8️⃣  Criando arquivo de configuração Render..." -ForegroundColor $info
Write-Host "─" * 80

Write-Host "  ⏳ Criando render-env.txt..." -NoNewline
@"
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
"@ | Out-File -Encoding UTF8 "render-env.txt"
Write-Host " ✓" -ForegroundColor $success
Write-Host "    Arquivo criado: render-env.txt" -ForegroundColor $warning

Write-Host ""

# ===== RESUMO FINAL =====
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "✅ SETUP CONCLUÍDO!" -ForegroundColor $success
Write-Host ""
Write-Host "📋 PRÓXIMOS PASSOS:" -ForegroundColor $info
Write-Host ""
Write-Host "1️⃣  GITHUB" -ForegroundColor $info
Write-Host "    Se ainda não tiver repositório remoto:"
Write-Host "    • Vá em github.com"
Write-Host "    • Crie repositório: crm-vendas-pro"
Write-Host "    • Execute:" -ForegroundColor $warning
Write-Host "      git remote add origin https://github.com/SEU_USER/crm-vendas-pro.git"
Write-Host "      git branch -M main"
Write-Host "      git push -u origin main"
Write-Host ""
Write-Host "2️⃣  RENDER - CRIAR POSTGRESQL" -ForegroundColor $info
Write-Host "    • Vá em render.com"
Write-Host "    • Dashboard → New + → PostgreSQL"
Write-Host "    • Nome: crm-vendas-pro-db"
Write-Host "    • Aguarde 2-5 minutos"
Write-Host "    • Copie a connection string"
Write-Host ""
Write-Host "3️⃣  RENDER - CRIAR WEB SERVICE" -ForegroundColor $info
Write-Host "    • Dashboard → New + → Web Service"
Write-Host "    • Conectar repositório GitHub"
Write-Host "    • Build: npm install"
Write-Host "    • Start: node backend/server.js"
Write-Host ""
Write-Host "4️⃣  RENDER - ADICIONAR VARIÁVEIS" -ForegroundColor $info
Write-Host "    • Abra: render-env.txt (criado neste diretório)"
Write-Host "    • Copie todas as variáveis"
Write-Host "    • Dashboard → Web Service → Environment"
Write-Host "    • Cole cada variável"
Write-Host ""
Write-Host "5️⃣  RENDER - FAZER DEPLOY" -ForegroundColor $info
Write-Host "    • Dashboard → Manual Deploy"
Write-Host "    • Ou: git push origin main (auto-deploy)"
Write-Host ""
Write-Host "6️⃣  TESTAR" -ForegroundColor $info
Write-Host "    • https://seu-servico.onrender.com"
Write-Host "    • Email: admin@crm.local"
Write-Host "    • Senha: JL10@dez"
Write-Host "    • Mudar senha após login!" -ForegroundColor $warning
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "🔐 CREDENCIAIS GERADAS:" -ForegroundColor $success
Write-Host ""
Write-Host "  JWT_SECRET (copie e guarde em local seguro):" -ForegroundColor $warning
Write-Host "  $jwtSecret" -ForegroundColor $warning
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "📖 DOCUMENTAÇÃO:" -ForegroundColor $info
Write-Host "    • DEPLOY_RENDER.md (guia completo)"
Write-Host "    • RENDER_CHECKLIST.md (passo a passo)"
Write-Host "    • render-env.txt (variáveis geradas)"
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "🚀 Tudo pronto! Siga os próximos passos acima para fazer deploy." -ForegroundColor $success
Write-Host ""
