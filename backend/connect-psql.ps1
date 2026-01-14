# Script para conectar ao PostgreSQL no Windows
# Uso: .\connect-psql.ps1

$PGPATH = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$PGPASSWORD = "JL10@dez"
$PGHOST = "localhost"
$PGUSER = "postgres"
$PGDATABASE = "crm_vendas_pro"

Write-Host "🔌 Conectando ao PostgreSQL..." -ForegroundColor Green
Write-Host "Host: $PGHOST | Usuário: $PGUSER | Database: $PGDATABASE" -ForegroundColor Cyan

$env:PGPASSWORD = $PGPASSWORD
& $PGPATH -U $PGUSER -h $PGHOST -d $PGDATABASE
