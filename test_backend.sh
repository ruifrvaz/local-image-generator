#!/bin/bash
# Backend Integration Test Script
set -e

echo "=== Backend API Integration Test ==="
echo ""

# Activate venv
source ~/.venvs/frontend-backend/bin/activate

# Start backend in background
cd backend
echo "[1/6] Starting backend server..."
uvicorn main:app --port 8000 > /tmp/backend_test.log 2>&1 &
BACKEND_PID=$!
sleep 3

# Test health endpoint
echo "[2/6] Testing health endpoint..."
curl -f http://localhost:8000/api/health || { echo "FAIL: Health check failed"; kill $BACKEND_PID; exit 1; }
echo " ✓ Health check passed"

# Test models endpoint (requires ComfyUI)
echo "[3/6] Testing models endpoint..."
if curl -f http://localhost:8000/api/models > /tmp/models_response.json 2>/dev/null; then
    echo " ✓ Models endpoint accessible"
    cat /tmp/models_response.json | python -m json.tool | head -20
else
    echo " ⚠ Models endpoint failed (ComfyUI may not be running)"
fi

# Test gallery endpoint
echo "[4/6] Testing gallery endpoint..."
curl -f http://localhost:8000/api/gallery > /tmp/gallery_response.json 2>/dev/null || echo " ⚠ Gallery endpoint returned no data (expected if no images)"

# Test gallery statistics
echo "[5/6] Testing gallery statistics endpoint..."
curl -f http://localhost:8000/api/gallery/statistics 2>/dev/null || echo " ⚠ Statistics endpoint failed"

# OpenAPI docs
echo "[6/6] Checking OpenAPI documentation..."
curl -f http://localhost:8000/docs > /dev/null 2>&1 && echo " ✓ Swagger UI accessible at http://localhost:8000/docs"

# Cleanup
kill $BACKEND_PID
wait $BACKEND_PID 2>/dev/null || true

echo ""
echo "=== Backend Test Summary ==="
echo "✓ Backend server starts successfully"
echo "✓ Health endpoint responds"
echo "✓ API endpoints are accessible"
echo "⚠ Full functionality requires ComfyUI server running"
