#!/usr/bin/env python3
import os
import subprocess
import sys

os.chdir('C:\\crm-vendas-pro')

commands = [
    ['git', 'add', 'backend/server.js', 'backend/frontend/auth-frontend.js', 'backend/frontend/sync-frontend.js'],
    ['git', 'commit', '-m', 'fix: adicionar credentials include nos fetches e melhorar logs de autenticacao'],
    ['git', 'push']
]

for cmd in commands:
    print(f"Executando: {' '.join(cmd)}")
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        print(result.stdout)
        if result.returncode != 0:
            print(f"ERRO: {result.stderr}")
    except Exception as e:
        print(f"Erro ao executar: {e}")
        sys.exit(1)

print("\n✓ Deploy concluído!")
print("Render fará rebuild em 3-5 minutos")
