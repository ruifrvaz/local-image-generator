#!/bin/bash
# Start Backend API Server
# Traceability: STK-BACKEND-001

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
VENV_PATH="$HOME/.venvs/frontend-backend"

# Activate virtual environment
if [ ! -d "$VENV_PATH" ]; then
    echo "[ERROR] Virtual environment not found at $VENV_PATH"
    echo "[ERROR] Run setup scripts first: setup/0_check_gpu.sh through setup/6_env_export.sh"
    exit 1
fi

source "$VENV_PATH/bin/activate"

cd "$BACKEND_DIR"

echo "[INFO] Starting backend API server on port 8000..."
uvicorn main:app --reload --host 0.0.0.0 --port 8000
