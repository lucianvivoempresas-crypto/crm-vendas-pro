# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar arquivos de dependências
COPY backend/package*.json ./

# Instalar dependências
RUN npm ci --only=production

# Stage 2: Runtime
FROM node:18-alpine

WORKDIR /app

# Instalar curl para health check
RUN apk add --no-cache curl

# Copiar node_modules do builder
COPY --from=builder /app/node_modules ./node_modules

# Copiar código da aplicação
COPY backend/server.js .
COPY backend/frontend ./frontend

# Criar diretório para dados persistentes (banco de dados)
RUN mkdir -p /app/data

# Expor porta
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Definir variáveis de ambiente
ENV NODE_ENV=production
ENV DATABASE_PATH=/app/data/crm.sqlite

# Comando para iniciar
CMD ["node", "server.js"]
