#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Install CUDA 13.0 Toolkit
################################################################################
# Purpose: Install NVIDIA CUDA 13.0 toolkit for PyTorch compilation
#
# What it does:
#   - Verifies nvidia-smi is available (GPU passthrough)
#   - Checks if cuda-toolkit-13-0 is already installed
#   - Installs CUDA 13.0 toolkit if not present
#   - Adds CUDA paths to ~/.bashrc (if not present)
#   - Verifies nvcc is available
#
# Requirements:
#   - WSL2 with GPU passthrough enabled
#   - NVIDIA drivers installed on Windows host
#   - sudo access
#
# Idempotent: Yes - safe to run multiple times
# Usage: ./1_cuda_install.sh
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing CUDA 13.0 Toolkit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Fail early if GPU passthrough is not working.
echo "[CHECK] Verifying GPU passthrough..."
command -v nvidia-smi >/dev/null || { 
    echo "[ERROR] GPU not visible in WSL. Fix Windows NVIDIA driver."
    exit 1
}
nvidia-smi --query-gpu=name --format=csv,noheader
echo "[OK] GPU passthrough working"
echo ""

# Check if any CUDA toolkit is already installed
echo "[CHECK] Checking for existing CUDA installation..."
CUDA_INSTALLED=false

# Check for any cuda-toolkit package
if dpkg -l | grep -q '^ii.*cuda-toolkit'; then
    CUDA_VERSION=$(dpkg -l | grep '^ii.*cuda-toolkit' | awk '{print $2}' | head -1)
    echo "[OK] CUDA already installed: $CUDA_VERSION"
    CUDA_INSTALLED=true
fi

# Also check if nvcc is available
if command -v nvcc >/dev/null 2>&1; then
    NVCC_VERSION=$(nvcc --version | grep "release" | awk '{print $5}' | sed 's/,//')
    echo "[OK] nvcc found: version $NVCC_VERSION"
    CUDA_INSTALLED=true
fi

if [ "$CUDA_INSTALLED" = true ]; then
    echo "[SKIP] CUDA toolkit already present, no installation needed"
else
    echo "[INFO] No CUDA toolkit found, installing CUDA 13.0..."
    echo ""
    
    # Refresh package lists
    echo "[UPDATE] Refreshing package lists..."
    sudo apt-get update -y
    echo ""
    
    # Install NVIDIA's CUDA 13.0 toolkit
    echo "[INSTALL] Downloading CUDA keyring..."
    wget -qO /tmp/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i /tmp/cuda-keyring.deb
    echo "[OK] CUDA keyring installed"
    echo ""
    
    echo "[UPDATE] Updating package lists with CUDA repository..."
    sudo apt-get update -y
    echo ""
    
    echo "[INSTALL] Installing cuda-toolkit-13-0 (this may take 5-10 minutes)..."
    sudo apt-get install -y cuda-toolkit-13-0
    echo "[OK] CUDA toolkit installed"
fi
echo ""

echo ""

# Add CUDA binaries and libraries to shell environment
echo "[BASHRC] Configuring CUDA paths in ~/.bashrc..."
if grep -q '/usr/local/cuda/bin' ~/.bashrc; then
    echo "   Already present: CUDA bin in PATH"
else
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    echo "   Added: CUDA bin to PATH"
fi

if grep -q '/usr/local/cuda/lib64' ~/.bashrc; then
    echo "   Already present: CUDA lib64 in LD_LIBRARY_PATH"
else
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    echo "   Added: CUDA lib64 to LD_LIBRARY_PATH"
fi
echo "[OK] CUDA paths configured"
echo ""

echo ""

# Load the updated environment in the current shell
echo "[EXPORT] Loading CUDA paths for current session..."
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}
echo "[OK] Paths loaded"
echo ""

# Confirm nvcc is available
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
nvcc --version
echo ""
echo "[OK] CUDA 13.0 toolkit installation complete!"
echo ""
echo "Next step:"
echo "  Run: ./2_sys_pkgs.sh"