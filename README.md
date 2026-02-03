# SDXL Image Generation with ComfyUI

## Overview

This repository provides a complete setup for running Stable Diffusion XL (SDXL) image generation locally via ComfyUI. All processing happens on your GPU with no cloud dependencies.

### Key Features

- **Local Generation**: All processing on RTX 5090 (32GB VRAM)
- **Web Frontend UI**: Modern React interface for generation and gallery browsing
- **Prompt File System**: Store prompts in text files, auto-loads latest
- **Multiple Workflows**: Basic, LoRA, img2img, upscale presets
- **CLI & Web UI**: Bash script API wrapper + browser interface
- **Power Optimized**: Default 18 steps (~420-450W, 2-5 seconds per image)
- **Real-time Monitoring**: GPU utilization, VRAM, power draw, temperature
- **Model Flexibility**: Drop any .safetensors files in `models/` directory

## Requirements

- **GPU**: RTX 5090 (32GB) / RTX 3090/4090 (24GB+)
- **RAM**: 64GB total, 48GB allocated to WSL2
- **OS**: Windows 11 + WSL2 (Ubuntu 22.04+)
- **Storage**: 200GB+ free

## Setup (15 minutes)

### 1. Configure WSL2 Memory

Create `C:\Users\<YourUsername>\.wslconfig`:
```ini
[wsl2]
memory=48GB
processors=12
```
Restart WSL2: `wsl --shutdown` (PowerShell)

### 2. Run Setup Scripts

```bash
cd ~/image-gen/setup
./0_check_gpu.sh      # Verify GPU
./1_cuda_install.sh   # CUDA toolkit
./2_sys_pkgs.sh       # System packages
./3_create_venv.sh    # Virtual environment
./4_install_torch.sh  # PyTorch 2.8.0+cu128
./5_install_comfyui.sh # ComfyUI + dependencies
./6_env_export.sh     # Environment variables
```

### 3. Get a Model

```bash
cd ~/image-gen/models
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
```

### 4. Configure Environment

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

**Required Configuration:**

Edit `.env` and update the following values:

```bash
# Backend Configuration
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000

# Frontend CORS origins (comma-separated)
# Update WSL IP to match your system (run: hostname -I)
CORS_ORIGINS=http://localhost:5173,http://172.31.243.212:5173

# ComfyUI API URL
COMFYUI_API_URL=http://localhost:8188

# Gallery storage path for generated images
GALLERY_STORAGE_PATH=/home/user/images/outputs

# Frontend Configuration
# Must match one of the CORS_ORIGINS values
VITE_API_BASE_URL=http://172.31.243.212:8000
```

**Finding Your WSL IP Address:**

```bash
hostname -I  # First address is your WSL IP
```

Update all occurrences of `172.31.243.212` in `.env` with your actual WSL IP.

**Alternative (Port Forwarding):**

If you have WSL port forwarding configured, you can use localhost everywhere:

```bash
CORS_ORIGINS=http://localhost:5173
VITE_API_BASE_URL=http://localhost:8000
```

**Environment Variables Reference:**

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `BACKEND_HOST` | No | `0.0.0.0` | Backend server host |
| `BACKEND_PORT` | No | `8000` | Backend server port |
| `CORS_ORIGINS` | Yes | - | Comma-separated frontend URLs |
| `COMFYUI_API_URL` | Yes | - | ComfyUI server URL |
| `GALLERY_STORAGE_PATH` | Yes | - | Path to save images |
| `VITE_API_BASE_URL` | Yes | - | Backend URL for frontend |

## Daily Usage

### Web Frontend (Recommended)

```bash
cd ~/image-gen

# Terminal 1: Start ComfyUI server
./serve_comfyui.sh

# Terminal 2: Start backend API
./serve_backend.sh

# Terminal 3: Start frontend UI
./serve_frontend.sh
```

Open browser: http://localhost:5173

Features:
- Generate images with live preview
- Browse gallery with filters (date, keyword)
- View generation parameters
- Download and delete images
- Batch generation support

### Command Line

```bash
cd ~/image-gen

# Start server
./serve_comfyui.sh

## Monitor GPU (Separate Terminal)

./monitoring/monitor_comfyui.sh

## Create prompt
echo "astronaut on mars, photorealistic, 8k" > ~/images/prompts/001_mars.txt

## Generate (auto-loads latest prompt)
./scripts/generate.sh --model "sd_xl_base_1.0.safetensors"

## Stop server
./stop_comfyui.sh
```

Web UI: http://localhost:8188

## Generation Options

```bash
# Basic
./scripts/generate.sh --model "model.safetensors"

# With parameters
./scripts/generate.sh --model "model.safetensors" \
  --prompt "inline prompt" \
  --steps 20 --cfg 7.0 --seed 42

# With LoRA
./scripts/generate.sh --model "base.safetensors" \
  --lora "style.safetensors" \
  --workflow workflows/presets/txt2img_lora.json

# Multiple variations
./scripts/generate.sh --model "model.safetensors" --count 5
```

### Parameters

| Flag | Default | Description |
|------|---------|-------------|
| `--model` | required | Checkpoint in `models/` |
| `--prompt` | auto | Override prompt file |
| `--negative` | "blurry..." | Elements to avoid |
| `--steps` | 20 | Sampling iterations |
| `--cfg` | 7.0 | Guidance scale |
| `--seed` | random | Reproducible seed |
| `--count` | 1 | Number of variations |
| `--lora` | none | LoRA model |

## Project Structure

```
image-gen/
├── serve_comfyui.sh          # Start ComfyUI server (port 8188)
├── serve_backend.sh          # Start API server (port 8000)
├── serve_frontend.sh         # Start frontend UI (port 5173)
├── stop_comfyui.sh           # Stop server
├── frontend/                 # React web UI
│   ├── src/
│   │   ├── components/       # UI components
│   │   ├── pages/            # Route pages
│   │   └── App.jsx           # Main app
│   └── package.json
├── backend/                  # FastAPI backend
│   ├── app/
│   │   ├── api/              # REST endpoints
│   │   ├── models/           # Pydantic schemas
│   │   └── services/         # Business logic
│   ├── main.py               # FastAPI app
│   └── requirements.txt
├── setup/                    # Installation (0-6)
├── scripts/
│   ├── generate.sh           # CLI generation
│   └── generate_sequence.sh  # Multi-frame sequences
├── workflows/presets/        # Workflow JSONs
├── models/                   # .safetensors files
├── monitoring/               # GPU monitor
└── logs/                     # Server logs

~/images/                     # Content (outside project)
├── prompts/                  # Prompt text files
└── outputs/                  # Generated images
```

## Models

```
models/
├── base/       # Official SDXL (6-8GB)
├── merged/     # Community merges (6-8GB)
└── loras/      # Style adapters (<2GB)
```

Add models: copy `.safetensors` to appropriate folder. Auto-detected on next generation.

## Performance (RTX 5090)

- **Speed**: 2-5 seconds @ 1024x1024, 20 steps
- **Power**: ~420-450W typical
- **VRAM**: ~10-14GB (base + LoRA)

Monitor: `./monitoring/monitor_comfyui.sh`

## Troubleshooting

**Server not responding:**
```bash
curl http://localhost:8188/system_stats
tail -f logs/server_*.log
```

**Model not found:**
```bash
ls -lh models/
```

**Out of memory:**
- Reduce resolution: `--width 768 --height 768`
- Check VRAM: `nvidia-smi`

## Links

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [HuggingFace Models](https://huggingface.co)
