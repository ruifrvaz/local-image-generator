# SDXL Image Generation with ComfyUI

Local SDXL image generation with LoRA support using ComfyUI on RTX 5090.

## Overview

This repository provides a complete setup for running Stable Diffusion XL (SDXL) image generation locally via ComfyUI. All processing happens on your RTX 5090 GPU with no cloud dependencies - your prompts and images stay private.

### Key Features

- **Local Generation**: All processing on RTX 5090 (32GB VRAM)
- **Prompt File System**: Store prompts in text files, auto-loads latest
- **Multiple Workflows**: Basic, LoRA, img2img, upscale presets
- **CLI & Web UI**: Bash script API wrapper + browser interface
- **Power Optimized**: Default 18 steps (~420-450W, 2-5 seconds per image)
- **Real-time Monitoring**: GPU utilization, VRAM, power draw, temperature
- **Model Flexibility**: Drop any .safetensors files in `models/` directory

### Hardware Requirements

- **GPU**: NVIDIA RTX 5090 (32GB VRAM) or RTX 3090/4090 (24GB+)
- **RAM**: 64GB total, 48GB allocated to WSL2
- **Storage**: 200GB+ free space for models and outputs
- **OS**: Windows 11 + WSL2 (Ubuntu 22.04+)

### Software Stack

- **ComfyUI**: Node-based Stable Diffusion interface
- **PyTorch**: 2.8.0+cu128 (RTX 5090 Blackwell support)
- **CUDA**: 12.8 runtime / 13.0 toolkit
- **Python**: 3.12.3 in isolated virtual environment

## Quick Start

See [QUICKSTART.md](QUICKSTART.md) for setup and first generation in 10 minutes.

## Repository Structure

```
image-gen/
├── README.md                  # This file
├── QUICKSTART.md              # Setup and first generation guide
├── serve_comfyui.sh           # Start ComfyUI server (port 8188)
├── stop_comfyui.sh            # Stop server gracefully
├── setup/                     # One-time installation scripts (0-7)
├── scripts/
│   └── generate.sh            # CLI generation wrapper
├── prompts/                   # Prompt text files (auto-loaded)
├── workflows/presets/         # ComfyUI workflow JSONs
├── models/                    # Your .safetensors files
├── outputs/                   # Generated images (timestamped)
├── logs/                      # Server logs
├── monitoring/
│   └── monitor_comfyui.sh     # GPU, VRAM, power, queue monitor
├── docs/history/              # Session history files
└── tasks/                     # Task tracking
```

## Daily Usage

### Start Server
```bash
./serve_comfyui.sh
```
Access web UI at http://localhost:8188

### Create Prompt
```bash
echo "astronaut on mars, detailed, photorealistic, 8k" > prompts/001_mars.txt
```

### Generate Image
```bash
./scripts/generate.sh --model "your_model.safetensors"
```

Images saved to `outputs/YYYYMMDD_HHMMSS/image.png` with metadata.

### Monitor GPU (Separate Terminal)
```bash
./monitoring/monitor_comfyui.sh
```
Displays real-time: GPU%, VRAM, power (W), temperature, queue status, generation count.
Press Ctrl+C for session summary (peak power, peak VRAM, total generations).

### Stop Server
```bash
./stop_comfyui.sh
```

## Generation Options

### Basic Generation (Auto-loads Latest Prompt)
```bash
# Base model
./scripts/generate.sh --model "base/sd_xl_base_1.0.safetensors"

# Merged model
./scripts/generate.sh --model "merged/jibMixRealisticXL_v160Aphrodite.safetensors"
```

### Inline Prompt Override
```bash
./scripts/generate.sh \
  --model "merged/jibMixRealisticXL_v160Aphrodite.safetensors" \
  --prompt "cyberpunk city, neon lights, rainy night, cinematic"
```

### Advanced Parameters
```bash
./scripts/generate.sh \
  --model "merged/your_model.safetensors" \
  --prompt "your prompt here" \
  --negative "blurry, low quality, distorted" \
  --steps 20 \
  --cfg 7.0 \
  --seed 42 \
  --width 1024 \
  --height 1024 \
  --workflow workflows/presets/txt2img_basic.json
```

### Using LoRA
```bash
./scripts/generate.sh \
  --model "base/sd_xl_base_1.0.safetensors" \
  --lora "loras/sdxl/style_lora.safetensors" \
  --workflow workflows/presets/txt2img_lora.json
```

## Workflow Presets

- **txt2img_basic.json** - Basic SDXL generation
- **txt2img_lora.json** - SDXL with LoRA enhancement
- **img2img.json** - Transform existing images
- **upscale.json** - Upscale low-resolution images

## Managing Models

### Model Directory Structure
Organize models by type for easy tracking:
```
models/
├── base/                                 # Official base models (6-8GB)
│   ├── sd_xl_base_1.0.safetensors
│   └── Illustrious-XL-v0.1.safetensors
├── merged/                               # Community merges/baked models (6-8GB)
│   └── [your merged models here]
└── loras/                                # LoRA adapters (<2GB)
    ├── illustrious/                      # Illustrious-compatible LoRAs
    ├── pony/                             # Pony Diffusion LoRAs
    └── sdxl/                             # Generic SDXL LoRAs
```

### Add New Models
1. Download .safetensors from [HuggingFace](https://huggingface.co)
2. Place in appropriate subfolder:
   ```bash
   # Base model (6-8GB official)
   cp ~/Downloads/base_model.safetensors ~/image-gen/models/base/
   
   # Merged/community model (6-8GB)
   cp ~/Downloads/merged_model.safetensors ~/image-gen/models/merged/
   
   # LoRA adapter (<2GB)
   cp ~/Downloads/lora.safetensors ~/image-gen/models/loras/sdxl/
   ```
3. ComfyUI auto-detects on next generation (no restart needed)

### Model Types
- **Base Models** (`base/`): Official SDXL checkpoints (6-8GB)
- **Merged Models** (`merged/`): Community fine-tuned/baked models (6-8GB)
- **LoRA Adapters** (`loras/`): Style/concept modifications (<2GB, requires base model)

See `models/README.md` for detailed organization guide.

## Performance

### RTX 5090 (32GB VRAM)
- **Generation Time**: 2-5 seconds (1024x1024, 18 steps)
- **Power Draw**: ~420-450W typical (18 steps), ~500W+ at 24+ steps
- **VRAM Usage**: ~10-14GB (base + LoRA + processing)
- **Batch Size**: 1 (optimal for single-user)
- **Monitoring**: Use `./monitoring/monitor_comfyui.sh` to track power in real-time

### LoRA Impact
- **Additional Time**: +0.5-1 second
- **Additional VRAM**: +200-500MB per LoRA

## Parameters Explained

### Core Parameters
- `--model` (required): SDXL checkpoint filename in `models/`
- `--prompt`: Text description of desired image
- `--negative`: Elements to avoid in generation

### Quality Control
- `--steps` (default: 20): Sampling iterations (higher = slower, more refined)
- `--cfg` (default: 7.0): Classifier-Free Guidance scale
  - Lower (1-5): More creative, looser interpretation
  - Higher (10-20): Stricter adherence, potential artifacts
  - Sweet spot: 7-8

### Technical
- `--seed`: Reproducible generations (same seed + prompt = same image)
- `--width/height`: Output resolution (default: 1024x1024)
- `--workflow`: Custom workflow JSON path

## Troubleshooting

### Server Not Responding
```bash
# Check status
curl http://localhost:8188/system_stats

# View logs
tail -f logs/server_*.log

# Restart
./stop_comfyui.sh
./serve_comfyui.sh
```

### Model Not Found
```bash
# List detected models
curl http://localhost:8188/object_info | jq '.CheckpointLoaderSimple.input.required.ckpt_name'

# Check files exist
ls -lh models/
```

### Out of Memory
- Reduce resolution: `--width 768 --height 768`
- Close other GPU applications
- Check VRAM: `nvidia-smi`

### Generation Failed
- Verify ComfyUI server is running
- Check `logs/server_*.log` for errors
- Ensure model file exists in `models/`

## ComfyUI API Endpoints

- `/system_stats` - GPU info, VRAM, system status
- `/prompt` - Submit generation (POST workflow JSON)
- `/queue` - Current queue status
- `/history/{id}` - Generation status
- `/view?filename={name}` - Download image
- `/object_info` - Available nodes and models

## Environment Details

### Virtual Environment
- **Location**: `~/.venvs/imggen`
- **Activation**: `source ~/.venvs/imggen/bin/activate`
- **Isolated from**: System Python and other venvs

### ComfyUI Installation
- **Location**: `~/ComfyUI`
- **Model Symlinks**: 
  - `~/ComfyUI/models/checkpoints/user_models` → `image-gen/models/`
  - `~/ComfyUI/models/loras/user_models` → `image-gen/models/`

### Configuration
- **Port**: 8188 (web UI and API)
- **CUDA**: 12.8 runtime, 13.0 toolkit
- **WSL2 RAM**: 48GB (required for dependency compilation)

## Recommended Models

### Base Models (SDXL)
- **Juggernaut XL** - Photorealistic generations
- **DreamShaper XL** - Artistic/creative style
- **RealVisXL** - Ultra-realistic photography
- **SD XL Base 1.0** - Official SDXL base (~6.9GB)

### LoRA Models
- **Style LoRAs**: Artistic style adjustment (anime, painting, photography)
- **Concept LoRAs**: Specific subjects/objects/characters
- **Fine-tuned LoRAs**: Personal style transfer

## Acknowledgments

Built with:
- [ComfyUI](https://github.com/comfyanonymous/ComfyUI) - Node-based Stable Diffusion UI
- [PyTorch](https://pytorch.org/) - Deep learning framework
- [Stable Diffusion XL](https://github.com/Stability-AI/generative-models) - Base model architecture