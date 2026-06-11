#!/usr/bin/env bash
# start_backend.sh — Inicia o servidor FastAPI a partir da raiz do projeto
# Uso: bash start_backend.sh

set -e

cd "$(dirname "$0")"

# Carrega variáveis de ambiente
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

BACKEND_HOST="${BACKEND_HOST:-127.0.0.1}"
BACKEND_PORT="${BACKEND_PORT:-8000}"

echo "Iniciando GÊNESIS Backend em http://${BACKEND_HOST}:${BACKEND_PORT} ..."
uvicorn backend.app.main:app --host "$BACKEND_HOST" --port "$BACKEND_PORT" --reload
