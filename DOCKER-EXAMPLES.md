# Exemplos de Configuração Docker Compose para Diferentes Cenários

## 1. Desenvolvimento Local (docker-compose.yml padrão)

Este arquivo já está configurado para:
- Aplicação na porta 3000
- Banco de dados em volume local
- Sem SSL/HTTPS
- Sem Nginx (acesso direto)

```bash
docker-compose up -d
# Acessar: http://localhost:3000
```

---

## 2. Produção com Nginx e SSL

Criar: `docker-compose.prod.yml`

```yaml
version: '3.8'

services:
  crm-app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: crm-vendas-pro
    environment:
      - NODE_ENV=production
      - DATABASE_PATH=/app/data/crm.sqlite
      - PORT=3000
      - HOST=0.0.0.0
    volumes:
      - crm-data:/app/data
    restart: always
    networks:
      - crm-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    container_name: crm-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - crm-app
    restart: always
    networks:
      - crm-network

volumes:
  crm-data:
    driver: local

networks:
  crm-network:
    driver: bridge
```

Deploy:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

---

## 3. Com PostgreSQL (em vez de SQLite)

Para aplicações maiores, usar PostgreSQL é mais robusto.

Criar: `docker-compose.postgres.yml`

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: crm-postgres
    environment:
      - POSTGRES_USER=crm_user
      - POSTGRES_PASSWORD=sua_senha_forte
      - POSTGRES_DB=crm_vendas
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: always
    networks:
      - crm-network

  crm-app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: crm-vendas-pro
    environment:
      - NODE_ENV=production
      - DATABASE_TYPE=postgres
      - DATABASE_URL=postgresql://crm_user:sua_senha_forte@postgres:5432/crm_vendas
      - PORT=3000
      - HOST=0.0.0.0
    depends_on:
      - postgres
    restart: always
    networks:
      - crm-network

  nginx:
    image: nginx:alpine
    container_name: crm-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - crm-app
    restart: always
    networks:
      - crm-network

volumes:
  postgres-data:
    driver: local

networks:
  crm-network:
    driver: bridge
```

---

## 4. Com Redis (para cache/sessions)

```yaml
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: crm-redis
    restart: always
    networks:
      - crm-network

  crm-app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: crm-vendas-pro
    environment:
      - NODE_ENV=production
      - REDIS_URL=redis://redis:6379
      - DATABASE_PATH=/app/data/crm.sqlite
    depends_on:
      - redis
    volumes:
      - crm-data:/app/data
    restart: always
    networks:
      - crm-network

  nginx:
    # ... configuração usual ...

volumes:
  crm-data:
    driver: local

networks:
  crm-network:
    driver: bridge
```

---

## 5. Com Backup Automático (using Cron)

```yaml
version: '3.8'

services:
  crm-app:
    # ... configuração usual ...

  backup:
    image: busybox
    container_name: crm-backup
    volumes:
      - crm-data:/app/data
      - ./backups:/backups
      - /etc/localtime:/etc/localtime:ro
    command: sh -c "while true; do cp /app/data/crm.sqlite /backups/backup_$(date +%Y%m%d_%H%M%S).sqlite && find /backups -name '*.sqlite' -mtime +30 -delete && sleep 86400; done"
    restart: always
    networks:
      - crm-network

volumes:
  crm-data:
    driver: local

networks:
  crm-network:
    driver: bridge
```

---

## 6. Com Monitoramento (Prometheus + Grafana)

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: crm-prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: always
    networks:
      - crm-network

  grafana:
    image: grafana/grafana:latest
    container_name: crm-grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
    restart: always
    networks:
      - crm-network

  crm-app:
    # ... configuração usual ...

volumes:
  prometheus-data:
  grafana-data:
  crm-data:

networks:
  crm-network:
    driver: bridge
```

---

## Selecionar Qual Usar

```bash
# Desenvolvimento
docker-compose up -d

# Produção
docker-compose -f docker-compose.prod.yml up -d

# Com PostgreSQL
docker-compose -f docker-compose.postgres.yml up -d

# Com Redis
docker-compose -f docker-compose.postgres.yml -f docker-compose.redis.yml up -d

# Com Monitoramento
docker-compose -f docker-compose.prod.yml -f docker-compose.monitoring.yml up -d
```

---

## Dicas

1. **Usar múltiplos arquivos**: `docker-compose -f compose1.yml -f compose2.yml up`
2. **Override de variáveis**: Criar `.env` e usar `${VARIAVEL}`
3. **Health checks**: Garantem que serviços dependentes esperam inicialização
4. **Volumes**: Persistem dados entre restarts
5. **Networks**: Isolam comunicação entre containers

---

**Escolha a configuração que melhor se adequa ao seu caso de uso!**
