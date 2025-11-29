#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Install PyTorch for Image Generation
################################################################################
# Purpose: Install PyTorch 2.8.0 with CUDA 12.8 (RTX 5090 Blackwell sm_120)
#
# What it does:
#   - Checks if PyTorch is already installed with correct CUDA version
#   - Skips installation if PyTorch cu128 is already present (idempotent)
#   - Installs/upgrades PyTorch 2.8.0 with CUDA 12.8 if needed
#   - Verifies CUDA availability and RTX 5090 support
#
# Requirements:
#   - Virtual environment created (4_create_venv.sh)
#   - NVIDIA GPU with CUDA 12.8+ drivers
#   - RTX 5090 (32GB VRAM, Blackwell architecture sm_120)
#   - ~5GB disk space for PyTorch packages
#
# Note: Uses same PyTorch version as vllm for consistency
#       PyTorch 2.8.0+cu128 is required for RTX 5090 Blackwell support
#
# Idempotent: Yes - safe to run multiple times
# Usage: ./4_install_torch.sh
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing PyTorch for Image Generation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Target: PyTorch 2.8.0 with CUDA 12.8 (RTX 5090 Blackwell sm_120)"
echo ""

# Activate the venv
echo "[VENV] Activating virtual environment..."
if [ ! -f ~/.venvs/imggen/bin/activate ]; then
    echo "[ERROR] Virtual environment not found at ~/.venvs/imggen/"
    echo "   Please run: ./3_create_venv.sh first"
    exit 1
fi

source ~/.venvs/imggen/bin/activate || {
    echo "[ERROR] Failed to activate virtual environment"
    echo "   Check if ~/.venvs/imggen/bin/activate exists and is readable"
    exit 1
}
echo "[OK] Virtual environment activated"
echo ""

# Check if PyTorch is already installed with correct version
echo "[CHECK] Checking for existing PyTorch installation..."
set +e  # Temporarily disable exit on error for version check
TORCH_CHECK=$(python -c "
import sys
try:
    import torch
    cuda_version = torch.version.cuda if hasattr(torch.version, 'cuda') else None
    torch_version = torch.__version__
    
    needs_upgrade = False
    if cuda_version:
        cuda_major, cuda_minor = map(int, cuda_version.split('.')[:2])
        # Parse torch version more carefully (handle 2.8.0+cu128 format)
        torch_parts = torch_version.split('+')[0].split('.')
        torch_major, torch_minor = int(torch_parts[0]), int(torch_parts[1])
        
        # Need PyTorch 2.8.0 with CUDA 12.8 for RTX 5090 sm_120
        if torch_major != 2 or torch_minor != 8:
            needs_upgrade = True
            print(f'UPGRADE_NEEDED|Current: torch {torch_version} cu{cuda_major}.{cuda_minor}, need torch 2.8.0 cu12.8')
        elif cuda_major < 12 or (cuda_major == 12 and cuda_minor < 8):
            needs_upgrade = True
            print(f'UPGRADE_NEEDED|Current: torch {torch_version} cu{cuda_major}.{cuda_minor}, need cu12.8')
        else:
            print(f'OK|torch {torch_version} cu{cuda_major}.{cuda_minor}')
    else:
        needs_upgrade = True
        print(f'UPGRADE_NEEDED|torch {torch_version} has no CUDA support')
    
    sys.exit(1 if needs_upgrade else 0)
except ImportError:
    print('NOT_INSTALLED|torch not found')
    sys.exit(1)
" 2>&1)

TORCH_STATUS=$?
set -e  # Re-enable exit on error
echo "$TORCH_CHECK"

if [ $TORCH_STATUS -eq 0 ]; then
    echo "[OK] PyTorch 2.8.0 with CUDA 12.8 already installed"
    echo "[SKIP] No reinstallation needed"
    echo ""
    echo "Next step:"
    echo "  Run: ./5_install_comfyui.sh"
    exit 0
fi

echo "[INFO] PyTorch needs installation or upgrade to 2.8.0"
echo ""

# Upgrade pip
echo "[UPGRADE] Upgrading pip, wheel, setuptools..."
pip install --upgrade pip wheel setuptools
echo "[OK] pip, wheel, setuptools upgraded"
echo ""

# Install PyTorch 2.8.0 with CUDA 12.8 (RTX 5090 Blackwell sm_120 support)
echo "[INSTALL] Installing PyTorch 2.8.0 with CUDA 12.8..."
echo "   This will download ~2.5GB of packages..."
echo "   CUDA 12.8 required for RTX 5090 Blackwell architecture (sm_120)"
echo "   Using PyTorch 2.8.0 (same version as vllm for consistency)"
echo "   Force reinstalling to ensure cu128 versions are installed"
pip uninstall -y torch torchvision torchaudio || true
pip install torch==2.8.0 torchvision torchaudio \
  --index-url https://download.pytorch.org/whl/cu128
echo "[OK] PyTorch 2.8.0 installed"
echo ""

# Verify CUDA is available
echo "[VERIFY] Checking CUDA availability and RTX 5090 support..."
python - <<'PY'
import torch, sys
print(f"PyTorch version: {torch.__version__}")
print(f"CUDA version: {torch.version.cuda}")
print(f"CUDA available: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    device_name = torch.cuda.get_device_name(0)
    print(f"GPU detected: {device_name}")
    
    # Check for RTX 5090
    if "5090" in device_name:
        print("[OK] RTX 5090 detected!")
        
        # Check compute capability (Blackwell sm_120 = compute 8.9)
        capability = torch.cuda.get_device_capability(0)
        compute_version = f"{capability[0]}.{capability[1]}"
        print(f"Compute capability: {compute_version} (sm_{capability[0]}{capability[1]})")
        
        if capability[0] >= 8 and capability[1] >= 9:
            print("[OK] Blackwell architecture (sm_120) fully supported!")
        else:
            print("[WARN] Unexpected compute capability for RTX 5090")
    else:
        print(f"[INFO] GPU: {device_name}")
    
    vram_gb = torch.cuda.get_device_properties(0).total_memory / (1024**3)
    print(f"VRAM: {vram_gb:.1f} GB")
else:
    print("[ERROR] CUDA not available! Check your GPU drivers and CUDA installation.")
    sys.exit(1)
PY

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[OK] PyTorch 2.8.0 with CUDA 12.8 installed and verified!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next step:"
echo "  Run: ./5_install_comfyui.sh"
