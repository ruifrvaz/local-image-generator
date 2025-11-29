#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Create Image Generation Virtual Environment
################################################################################
# Purpose: Create isolated Python environment for SDXL image generation
#
# What it does:
#   - Creates venv at ~/.venvs/imggen
#   - Upgrades pip, setuptools, wheel
#   - Prints Python/pip versions
#
# Requirements:
#   - Python 3.12+ installed
#   - Sufficient disk space (~20GB for packages + models)
#   - WSL2 with 48GB RAM allocation (required for dependency compilation)
#     Configure in C:\Users\<username>\.wslconfig:
#       [wsl2]
#       memory=48GB
#       processors=12
#     Restart WSL: wsl --shutdown (PowerShell)
#
# Hardware Target:
#   - NVIDIA RTX 5090 (32GB VRAM, Blackwell sm_120)
#   - CUDA 12.8/13.0
#   - PyTorch 2.8.0+cu128
#
# Usage: ./3_create_venv.sh
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Creating Image Generation Virtual Environment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Location: ~/.venvs/imggen"
echo ""

# Create venv (idempotent - won't fail if exists)
echo "[CREATE] Creating virtual environment..."
python3 -m venv ~/.venvs/imggen
echo "[OK] Virtual environment created"
echo ""

# Activate the venv
echo "[ACTIVATE] Activating virtual environment..."
source ~/.venvs/imggen/bin/activate
echo "[OK] Activated"
echo ""

# Upgrade packaging tools
echo "[UPGRADE] Upgrading pip, setuptools, wheel..."
python -m pip install -U pip setuptools wheel
echo "[OK] Tools upgraded"
echo ""

# Print versions for verification
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Environment Information"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python -V
pip -V
echo ""
echo "[OK] Image generation virtual environment ready!"
echo ""
echo "Next steps:"
echo "  1. Run: ./4_install_torch.sh"
echo "  2. Run: ./5_install_comfyui.sh"
