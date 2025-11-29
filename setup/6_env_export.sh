#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Export Environment Variables for Image Generation
################################################################################
# Purpose: Configure environment for optimal SDXL generation on RTX 5090
#
# What it does:
#   - Sets PYTORCH_CUDA_ALLOC_CONF for VRAM optimization
#   - Sets CUDA_VISIBLE_DEVICES for single GPU
#   - Adds variables to ~/.bashrc for persistence
#   - Prints active configuration
#
# Environment Variables:
#   PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
#     - Allows dynamic VRAM allocation
#     - Reduces fragmentation for large models
#     - Optimizes memory usage for SDXL (6-8GB base + KV cache)
#
#   CUDA_VISIBLE_DEVICES=0
#     - Use first GPU (RTX 5090)
#     - Single GPU optimization
#
# Requirements:
#   - PyTorch 2.8.0+cu128 installed
#   - CUDA 12.8/13.0 configured
#   - RTX 5090 detected
#
# Usage: ./7_env_export.sh
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuring Environment Variables for Image Generation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Define environment variables
ENV_VARS=(
    "export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True"
    "export CUDA_VISIBLE_DEVICES=0"
)

# Add to ~/.bashrc if not present
echo "[BASHRC] Adding environment variables to ~/.bashrc..."
for VAR in "${ENV_VARS[@]}"; do
    if ! grep -qF "$VAR" ~/.bashrc; then
        echo "$VAR" >> ~/.bashrc
        echo "   Added: $VAR"
    else
        echo "   Already present: $VAR"
    fi
done
echo "[OK] Environment variables configured in ~/.bashrc"
echo ""

# Export for current shell
echo "[EXPORT] Setting variables for current session..."
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
export CUDA_VISIBLE_DEVICES=0
echo "[OK] Variables exported"
echo ""

# Verify CUDA paths are set
echo "[CHECK] Verifying CUDA configuration..."
if [[ ":$PATH:" != *":/usr/local/cuda/bin:"* ]]; then
    echo "[INFO] CUDA bin not in PATH, adding to ~/.bashrc..."
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    export PATH=/usr/local/cuda/bin:$PATH
fi

if [[ ":$LD_LIBRARY_PATH:" != *":/usr/local/cuda/lib64:"* ]]; then
    echo "[INFO] CUDA lib64 not in LD_LIBRARY_PATH, adding to ~/.bashrc..."
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}
fi
echo "[OK] CUDA paths verified"
echo ""

# Print active configuration
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Active Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PYTORCH_CUDA_ALLOC_CONF: ${PYTORCH_CUDA_ALLOC_CONF:-not set}"
echo "CUDA_VISIBLE_DEVICES: ${CUDA_VISIBLE_DEVICES:-not set}"
echo "CUDA bin path: $(which nvcc 2>/dev/null || echo 'not found')"
echo ""

# Verify PyTorch can see CUDA
if [ -f ~/.venvs/imggen/bin/activate ]; then
    source ~/.venvs/imggen/bin/activate
    echo "[VERIFY] Checking PyTorch + CUDA integration..."
    python - <<'PY'
import torch
import sys

print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")

if torch.cuda.is_available():
    print(f"CUDA version: {torch.version.cuda}")
    print(f"GPU count: {torch.cuda.device_count()}")
    print(f"GPU 0: {torch.cuda.get_device_name(0)}")
    
    vram_gb = torch.cuda.get_device_properties(0).total_memory / (1024**3)
    print(f"VRAM: {vram_gb:.1f} GB")
    
    capability = torch.cuda.get_device_capability(0)
    print(f"Compute capability: {capability[0]}.{capability[1]}")
else:
    print("[ERROR] CUDA not available!")
    sys.exit(1)
PY
    echo "[OK] PyTorch + CUDA verified"
else
    echo "[SKIP] Virtual environment not found, skipping PyTorch check"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[OK] Environment configuration complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Setup complete! Next steps:"
echo "  1. Restart shell or run: source ~/.bashrc"
echo "  2. Place models in: $(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/models/"
echo "  3. Start ComfyUI: ../serve_comfyui.sh"
