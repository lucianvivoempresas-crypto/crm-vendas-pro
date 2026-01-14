#!/usr/bin/env node
/**
 * QUICK START - CRM Vendas Pro PostgreSQL
 * Este script ajuda você a configurar e iniciar o CRM
 */

const fs = require('fs');
const path = require('path');

console.clear();
console.log(`
╔════════════════════════════════════════════════════════════════════════════╗
║                   🚀 CRM VENDAS PRO - QUICK START                          ║
║                  PostgreSQL Edition (v2.0.0)                               ║
╚════════════════════════════════════════════════════════════════════════════╝
`);

// Checklist
const steps = [
  {
    title: "✅ PostgreSQL instalado?",
    command: "psql --version",
    fix: "Instale: choco install postgresql"
  },
  {
    title: "✅ Node.js instalado?",
    command: "node --version",
    fix: "Instale: choco install nodejs"
  },
  {
    title: "✅ Arquivo .env existe?",
    check: () => fs.existsSync('.env'),
    fix: "Execute: cp .env.example .env"
  },
  {
    title: "✅ Banco de dados criado?",
    command: "psql -U postgres -h localhost -c 'SELECT datname FROM pg_database WHERE datname = 'crm_vendas_pro';'",
    fix: "Execute: psql -U postgres -c 'CREATE DATABASE crm_vendas_pro;'"
  },
  {
    title: "✅ node_modules instalado?",
    check: () => fs.existsSync('node_modules'),
    fix: "Execute: npm install"
  }
];

console.log(`
📋 PRÉ-REQUISITOS:
────────────────────────────────────────────────────────────────────────────
`);

steps.forEach((step, index) => {
  console.log(`${index + 1}. ${step.title}`);
});

console.log(`

🔧 PRÓXIMOS PASSOS:
────────────────────────────────────────────────────────────────────────────

1. Certifique-se de que todos os pré-requisitos acima estão OK

2. Configure o arquivo .env:
   $ cp .env.example .env
   $ code .env  # Edite com suas credenciais do PostgreSQL

3. Instale as dependências:
   $ npm install

4. Inicie o servidor:
   $ npm start

5. Acesse a aplicação:
   Navegue para: http://localhost:3000

📝 CREDENCIAIS PADRÃO:
────────────────────────────────────────────────────────────────────────────

   Email:  admin@crm.local
   Senha:  JL10@dez
   
   ⚠️  MUDE A SENHA APÓS O PRIMEIRO LOGIN!

🆘 PROBLEMAS?
────────────────────────────────────────────────────────────────────────────

Consulte os guias:
  • MIGRATION.md          → Guia de instalação
  • README_MIGRACAO.md    → Resumo técnico
  • TROUBLESHOOTING.md    → Solução de problemas

💡 DICA: Execute este script quando tiver dúvidas!

`);

// Verificação de PostgreSQL
try {
  const { execSync } = require('child_process');
  const version = execSync('psql --version', { encoding: 'utf-8' });
  console.log(`✓ PostgreSQL detectado: ${version.trim()}\n`);
} catch (e) {
  console.log(`✗ PostgreSQL não encontrado. Instale com: choco install postgresql\n`);
}

// Verificação de Node.js
try {
  const { execSync } = require('child_process');
  const version = execSync('node --version', { encoding: 'utf-8' });
  console.log(`✓ Node.js detectado: ${version.trim()}\n`);
} catch (e) {
  console.log(`✗ Node.js não encontrado. Instale com: choco install nodejs\n`);
}

// Verificação de .env
if (fs.existsSync('.env')) {
  console.log(`✓ Arquivo .env encontrado\n`);
} else {
  console.log(`✗ Arquivo .env não encontrado`);
  console.log(`  Execute: cp .env.example .env\n`);
}

// Verificação de node_modules
if (fs.existsSync('node_modules')) {
  console.log(`✓ node_modules encontrado\n`);
} else {
  console.log(`✗ node_modules não encontrado`);
  console.log(`  Execute: npm install\n`);
}

console.log(`
────────────────────────────────────────────────────────────────────────────

Ready to start? Run: npm start

Good luck! 🚀

────────────────────────────────────────────────────────────────────────────
`);
