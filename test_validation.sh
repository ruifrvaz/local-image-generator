#!/bin/bash
# Component Validation Test
echo "=== Component Validation Test ==="
PASS=0
TOTAL=5

# Test 1
echo "[1/5] Backend Python imports..."
cd backend
~/.venvs/frontend-backend/bin/python -c "from app.api import generation; from app.models.schemas import GenerationRequest" 2>/dev/null && echo " ✓ Backend imports OK" && ((PASS++)) || echo " ✗ Failed"
cd ..

# Test 2
echo "[2/5] Frontend dependencies..."
[ -d "frontend/node_modules" ] && echo " ✓ Dependencies OK" && ((PASS++)) || echo " ✗ Missing"

# Test 3
echo "[3/5] Frontend build..."
[ -f "frontend/dist/index.html" ] && echo " ✓ Build exists" && ((PASS++)) || echo " ⚠ Not built"

# Test 4
echo "[4/5] Python venv..."
~/.venvs/frontend-backend/bin/python --version 2>/dev/null && echo " ✓ Venv OK" && ((PASS++)) || echo " ✗ Missing"

# Test 5
echo "[5/5] Startup scripts..."
[ -x "serve_comfyui.sh" ] && [ -x "serve_backend.sh" ] && [ -x "serve_frontend.sh" ] && echo " ✓ Scripts OK" && ((PASS++)) || echo " ⚠ Check permissions"

echo ""
echo "=== Results: $PASS/$TOTAL passed ==="
[ $PASS -ge 4 ] && echo "✅ Ready to use!" || echo "⚠ Review failures"
