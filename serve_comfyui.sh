#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Serve ComfyUI - Start SDXL Image Generation Server
################################################################################
# Purpose: Start ComfyUI server for SDXL + LoRA image generation
#
# What it does:
#   - Activates virtual environment
#   - Kills existing ComfyUI processes
#   - Starts ComfyUI server on port 8188
#   - Logs output to timestamped file
#
# Server Configuration:
#   Port: 8188
#   Listen: 0.0.0.0 (accessible from network)
#   GPU: RTX 5090 (32GB VRAM)
#   Mode: GPU-only optimization
#
# Usage: ./serve_comfyui.sh
#
# Access:
#   Web UI: http://localhost:8188
#   API: http://localhost:8188/prompt
################################################################################

PORT=8188
COMFYUI_DIR="$HOME/ComfyUI"
LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logs"
LOG_FILE="$LOG_DIR/server_$(date +%Y%m%d_%H%M%S).log"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[START] Starting ComfyUI Server for SDXL Generation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Port: $PORT"
echo "ComfyUI: $COMFYUI_DIR"
echo "GPU: RTX 5090 (32GB VRAM)"
echo "Log: $LOG_FILE"
echo ""

# Check if ComfyUI is installed
if [ ! -d "$COMFYUI_DIR" ]; then
    echo "[ERROR] ComfyUI not found at $COMFYUI_DIR"
    echo "   Please run: cd setup && ./6_install_comfyui.sh"
    exit 1
fi

# Activate virtual environment
echo "[VENV] Activating virtual environment..."
if [ ! -f ~/.venvs/imggen/bin/activate ]; then
    echo "[ERROR] Virtual environment not found at ~/.venvs/imggen/"
    echo "   Please run: cd setup && ./4_create_venv.sh"
    exit 1
fi

source ~/.venvs/imggen/bin/activate || {
    echo "[ERROR] Failed to activate virtual environment"
    exit 1
}
echo "[OK] Virtual environment activated"
echo ""

# Kill existing ComfyUI processes
echo "[CLEANUP] Checking for existing ComfyUI processes..."
EXISTING_PIDS=$(pgrep -f "python.*ComfyUI/main.py" || true)
if [ -n "$EXISTING_PIDS" ]; then
    echo "[WARN] Found existing ComfyUI processes: $EXISTING_PIDS"
    echo "   Killing..."
    pkill -f "python.*ComfyUI/main.py" || true
    sleep 2
    echo "[OK] Existing processes killed"
else
    echo "[OK] No existing processes found"
fi
echo ""

# Create log directory
mkdir -p "$LOG_DIR"

# Get GPU info
if command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits)
    GPU_NAME=$(echo "$GPU_INFO" | cut -d',' -f1 | xargs)
    GPU_VRAM=$(echo "$GPU_INFO" | cut -d',' -f2 | xargs)
    echo "[GPU] Detected: $GPU_NAME (${GPU_VRAM}MB VRAM)"
else
    echo "[WARN] nvidia-smi not available"
fi
echo ""

# Show models directory
MODELS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/models"
echo "[MODELS] Models directory: $MODELS_DIR"
MODEL_COUNT=$(find "$MODELS_DIR" -name "*.safetensors" 2>/dev/null | wc -l)
echo "[MODELS] Found $MODEL_COUNT .safetensors files"
echo ""

# Start ComfyUI server
echo "[START] Starting ComfyUI server..."
echo "   Access Web UI: http://localhost:$PORT"
echo "   API endpoint: http://localhost:$PORT/prompt"
echo "   Output will be logged to: $LOG_FILE"
echo ""
echo "Press Ctrl+C to stop the server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start server with logging
cd "$COMFYUI_DIR"
exec python main.py \
  --listen 0.0.0.0 \
  --port $PORT \
  --gpu-only \
  2>&1 | tee "$LOG_FILE"
