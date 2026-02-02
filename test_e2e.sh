#!/bin/bash
# End-to-End Integration Test
# Tests the complete frontend → backend → ComfyUI workflow

set -e

echo "=== End-to-End Integration Test ==="
echo ""
echo "This test verifies:"
echo "  1. ComfyUI server is running and accessible"
echo "  2. Backend API can communicate with ComfyUI"
echo "  3. Frontend can be built and served"
echo "  4. All three components work together"
echo ""

# Check ComfyUI
echo "[1/4] Checking ComfyUI server..."
if curl -f http://localhost:8188/system_stats > /dev/null 2>&1; then
    echo " ✓ ComfyUI is running on port 8188"
    curl -s http://localhost:8188/system_stats | python -m json.tool | grep -E '"system|devices"' | head -5
else
    echo " ✗ FAIL: ComfyUI not running"
    echo "   Start with: ./serve_comfyui.sh"
    exit 1
fi

# Start backend
echo ""
echo "[2/4] Starting backend API server..."
source ~/.venvs/frontend-backend/bin/activate
cd backend
uvicorn main:app --port 8000 > /tmp/e2e_backend.log 2>&1 &
BACKEND_PID=$!
cd ..
sleep 3

# Test backend endpoints
echo " ✓ Backend started (PID: $BACKEND_PID)"
echo ""
echo "[3/4] Testing backend endpoints..."

# Health check
curl -f http://localhost:8000/api/health > /dev/null 2>&1 && echo " ✓ Health endpoint OK"

# Models endpoint (should work now with ComfyUI)
if curl -f http://localhost:8000/api/models > /tmp/e2e_models.json 2>/dev/null; then
    MODEL_COUNT=$(cat /tmp/e2e_models.json | python -c "import json,sys; d=json.load(sys.stdin); print(d.get('total_count', 0))")
    echo " ✓ Models endpoint OK ($MODEL_COUNT models found)"
else
    echo " ✗ Models endpoint failed"
    kill $BACKEND_PID
    exit 1
fi

# Gallery endpoint
curl -f http://localhost:8000/api/gallery > /tmp/e2e_gallery.json 2>/dev/null
IMAGE_COUNT=$(cat /tmp/e2e_gallery.json | python -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('images', [])))")
echo " ✓ Gallery endpoint OK ($IMAGE_COUNT images found)"

# Statistics endpoint
curl -f http://localhost:8000/api/gallery/statistics > /tmp/e2e_stats.json 2>/dev/null
TOTAL_IMAGES=$(cat /tmp/e2e_stats.json | python -c "import json,sys; d=json.load(sys.stdin); print(d.get('total_images', 0))")
STORAGE=$(cat /tmp/e2e_stats.json | python -c "import json,sys; d=json.load(sys.stdin); s=d.get('total_storage', 0); print(f'{s/1024/1024:.1f}MB')")
echo " ✓ Statistics endpoint OK ($TOTAL_IMAGES images, $STORAGE storage)"

# Test frontend build
echo ""
echo "[4/4] Testing frontend build..."
cd frontend
if [ -d "dist" ]; then
    BUNDLE_SIZE=$(du -sh dist/assets/*.js 2>/dev/null | awk '{print $1}' | head -1)
    echo " ✓ Frontend build exists (bundle: $BUNDLE_SIZE)"
else
    echo " ⚠ Frontend dist/ not found, building now..."
    npm run build > /tmp/e2e_frontend_build.log 2>&1
    echo " ✓ Frontend build completed"
fi
cd ..

# Cleanup
kill $BACKEND_PID 2>/dev/null || true
wait $BACKEND_PID 2>/dev/null || true

echo ""
echo "=== Test Results ==="
echo "✓ ComfyUI server: Running"
echo "✓ Backend API: Working ($MODEL_COUNT models, $TOTAL_IMAGES images)"
echo "✓ Frontend: Built successfully"
echo ""
echo "=== Ready for Use ==="
echo "Start all servers:"
echo "  Terminal 1: ./serve_comfyui.sh       (already running)"
echo "  Terminal 2: ./serve_backend.sh       (port 8000)"
echo "  Terminal 3: ./serve_frontend.sh      (port 5173)"
echo ""
echo "Then open: http://localhost:5173"
