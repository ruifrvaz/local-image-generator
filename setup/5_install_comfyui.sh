#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Install ComfyUI and Dependencies
################################################################################
# Purpose: Install ComfyUI for SDXL image generation with LoRA support
#
# What it does:
#   - Clones ComfyUI repository to ~/ComfyUI
#   - Installs all required dependencies (torchvision, Pillow, etc.)
#   - Creates symlinks from image-gen/models to ComfyUI directories
#   - Verifies installation
#
# Requirements:
#   - Virtual environment created (4_create_venv.sh)
#   - PyTorch 2.8.0+cu128 installed (5_install_torch.sh)
#   - ~5GB disk space for ComfyUI + dependencies
#   - RTX 5090 with 32GB VRAM
#
# Model Organization:
#   image-gen/models/ → ComfyUI will auto-detect:
#     - Base models (SDXL checkpoints, >2GB)
#     - LoRA models (<2GB)
#   ComfyUI organizes by scanning file structure
#
# Usage: ./5_install_comfyui.sh
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing ComfyUI for SDXL Image Generation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
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
    exit 1
}
echo "[OK] Virtual environment activated"
echo ""

# Verify PyTorch is installed
echo "[CHECK] Verifying PyTorch installation..."
python -c "import torch; assert torch.cuda.is_available()" || {
    echo "[ERROR] PyTorch with CUDA not found!"
    echo "   Please run: ./4_install_torch.sh first"
    exit 1
}
echo "[OK] PyTorch with CUDA found"
echo ""

# Clone ComfyUI if not exists
COMFYUI_DIR="$HOME/ComfyUI"
if [ -d "$COMFYUI_DIR" ]; then
    echo "[INFO] ComfyUI directory exists at $COMFYUI_DIR"
    echo "   Pulling latest changes..."
    cd "$COMFYUI_DIR"
    git pull || echo "[WARN] Could not pull updates (may have local changes)"
    cd - > /dev/null
else
    echo "[CLONE] Cloning ComfyUI repository..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFYUI_DIR"
    echo "[OK] ComfyUI cloned to $COMFYUI_DIR"
fi
echo ""

# Install ComfyUI dependencies
echo "[INSTALL] Installing ComfyUI dependencies..."
echo "   This may take 5-10 minutes..."
pip install -r "$COMFYUI_DIR/requirements.txt"
echo "[OK] ComfyUI dependencies installed"
echo ""

# Install additional useful packages
echo "[INSTALL] Installing additional image processing packages..."
pip install \
  safetensors==0.4.5 \
  accelerate \
  einops \
  kornia \
  spandrel \
  scipy
echo "[OK] Additional packages installed"
echo ""

# Create symlinks for model directories
echo "[SYMLINK] Setting up model directory links..."

# Get absolute path to image-gen models directory
IMAGE_GEN_MODELS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/models"

# Create ComfyUI model directories if they don't exist
mkdir -p "$COMFYUI_DIR/models/checkpoints"
mkdir -p "$COMFYUI_DIR/models/loras"
mkdir -p "$COMFYUI_DIR/models/vae"
mkdir -p "$COMFYUI_DIR/models/embeddings"

# Remove existing symlinks if present
[ -L "$COMFYUI_DIR/models/checkpoints/user_models" ] && rm "$COMFYUI_DIR/models/checkpoints/user_models"
[ -L "$COMFYUI_DIR/models/loras/user_models" ] && rm "$COMFYUI_DIR/models/loras/user_models"

# Create symlinks to user's model directory
echo "   Creating symlink: $COMFYUI_DIR/models/checkpoints/user_models -> $IMAGE_GEN_MODELS"
ln -s "$IMAGE_GEN_MODELS" "$COMFYUI_DIR/models/checkpoints/user_models"
echo "   Creating symlink: $COMFYUI_DIR/models/loras/user_models -> $IMAGE_GEN_MODELS"
ln -s "$IMAGE_GEN_MODELS" "$COMFYUI_DIR/models/loras/user_models"

echo "[OK] Model directory symlinks created"
echo "   ComfyUI will scan: $IMAGE_GEN_MODELS"
echo "   Place all .safetensors files (base models + LoRAs) in: $IMAGE_GEN_MODELS"
echo ""

# Print installation summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ComfyUI Location: $COMFYUI_DIR"
echo "Models Directory: $IMAGE_GEN_MODELS"
echo "Virtual Environment: ~/.venvs/imggen"
echo ""

# Verify key packages
python - <<'PY'
import importlib.metadata as m
packages = ["torch", "torchvision", "PIL", "safetensors", "accelerate"]
print("Installed Packages:")
for p in packages:
    try:
        if p == "PIL":
            import PIL
            print(f"  Pillow: {PIL.__version__}")
        else:
            print(f"  {p}: {m.version(p)}")
    except:
        print(f"  {p}: not installed")
PY

echo ""
echo "[OK] ComfyUI installation complete!"
echo ""
echo "Next steps:"
echo "  1. Run: ./6_env_export.sh"
echo "  2. Place model files in: $IMAGE_GEN_MODELS"
echo "  3. Start server: ../serve_comfyui.sh"
