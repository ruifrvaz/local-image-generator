#!/bin/bash
# Start Frontend Dev Server
# Traceability: STK-FRONTEND-001

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$SCRIPT_DIR/frontend"

cd "$FRONTEND_DIR"

echo "[INFO] Starting frontend dev server on port 5173..."
npm run dev
