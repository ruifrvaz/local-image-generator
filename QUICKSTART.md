# Quick Start Guide

Get ComfyUI running and generate your first image in 10 minutes.

## Prerequisites

- RTX 5090 (or RTX 3090/4090 with 24GB+ VRAM)
- Windows 11 + WSL2 (Ubuntu 22.04+)
- 64GB RAM with 48GB allocated to WSL2
- 200GB+ free disk space

## Step 1: Configure WSL2 Memory (5 minutes)

WSL2 needs 48GB RAM for dependency compilation.

### Windows Side

1. Open PowerShell as Administrator
2. Create/edit `C:\Users\<YourUsername>\.wslconfig`:
   ```ini
   [wsl2]
   memory=48GB
   processors=12
   ```
3. Restart WSL2:
   ```powershell
   wsl --shutdown
   ```
4. Wait 10 seconds, then reopen WSL2 terminal

### Verify in WSL2
```bash
free -h
# Should show ~48GB total memory
```

## Step 2: Clone Repository (1 minute)

```bash
cd ~
git clone <repository-url> image-gen
cd image-gen
```

## Step 3: Run Setup Scripts (10-15 minutes)

Scripts are numbered 0-7 and must run in sequence. Each script is idempotent (safe to re-run).

```bash
cd setup

# 0. Verify RTX 5090 detection
./0_check_gpu.sh

# 1. Install CUDA toolkit (if not present)
./1_cuda_install.sh

# 2. Install system packages
./2_sys_pkgs.sh

# 3. Create virtual environment
./3_create_venv.sh

# 4. Install PyTorch 2.8.0+cu128
./4_install_torch.sh

# 5. Install ComfyUI + dependencies
./5_install_comfyui.sh

# 6. Set environment variables
./6_env_export.sh
```

### Expected Output

Each script prints:
- `[CHECK]` - Verification step
- `[OK]` - Success
- `[WARN]` - Non-critical warning
- `[ERROR]` - Fatal error (stop and debug)

**Total time:** ~10-15 minutes (mostly downloading dependencies)

## Step 4: Get a Model (5 minutes)

ComfyUI needs at least one SDXL model to generate images.

### Download from HuggingFace

```bash
# Option 1: Place at root (simple)
cd ~/image-gen/models
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
```

### Verify Model
```bash
# List all models recursively
find ~/image-gen/models/ -name '*.safetensors' -type f
```

## Step 5: Start ComfyUI Server (30 seconds)

```bash
cd ~/image-gen
./serve_comfyui.sh
```

### Expected Output
```
Starting ComfyUI server...
[OK] ComfyUI server started (PID: 12345)
[OK] Server running on http://localhost:8188
[OK] Logs: ~/image-gen/logs/server_20251127_120000.log
```

### Verify Server
Open browser to http://localhost:8188 - you should see ComfyUI web interface.

Or check via API:
```bash
curl http://localhost:8188/system_stats
# Should return JSON with GPU info
```

## Step 6: Generate Your First Image (30 seconds)

### Create a Prompt File
```bash
cd ~/image-gen
echo "astronaut on mars, detailed landscape, red planet, photorealistic, 8k" > prompts/001_mars.txt
```

### Generate Image
```bash
# If model is at root of models/
./scripts/generate.sh --model "sd_xl_base_1.0.safetensors"

# If model is in a subfolder (e.g., illustrious/)
./scripts/generate.sh --model "illustrious/your_model.safetensors"
```

Replace with the actual path relative to `models/` directory.

### Expected Output
```
[INFO] Loaded prompt from: ~/image-gen/prompts/001_mars.txt
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ComfyUI Image Generation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Model:    user_models/your_model_filename.safetensors
Prompt:   astronaut on mars, detailed landscape...
Steps:    20
CFG:      7.0
Seed:     12345
Size:     1024x1024

[BUILD] Preparing workflow with parameters...
[OK] Workflow prepared

[SUBMIT] Posting generation request to ComfyUI...
[OK] Request submitted: abc123...

[WAIT] Generating image...
.[OK] Generation complete!

[DOWNLOAD] Retrieving generated image...
[OK] Image saved: ~/image-gen/outputs/20251127_120530/image.png
[OK] Metadata saved: ~/image-gen/outputs/20251127_120530/prompt.txt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SUCCESS] Image generation complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Output: ~/image-gen/outputs/20251127_120530
```

**Generation time:** 2-5 seconds on RTX 5090

## Step 7: View Your Image

### In WSL2
```bash
# Show file location
ls -lh ~/image-gen/outputs/*/image.png

# On Windows, outputs are at:
# \\wsl$\Ubuntu\home\<username>\image-gen\outputs\
```

### In Windows Explorer
1. Open File Explorer
2. Navigate to `\\wsl$\Ubuntu\home\<username>\image-gen\outputs\`
3. Open the timestamped folder
4. Double-click `image.png`

### In Browser (via ComfyUI)
1. Go to http://localhost:8188
2. Check the "View History" panel
3. Click your generated image

## Next Steps

### Generate More Images

Create new prompt files:
```bash
echo "cyberpunk city, neon lights, rainy night, cinematic" > prompts/002_city.txt
./scripts/generate.sh --model "your_model.safetensors"
```

The script automatically loads the **latest** prompt file.

### Try Different Parameters

```bash
# More steps (slower, more refined)
./scripts/generate.sh --model "your_model.safetensors" --steps 30

# Different CFG (how closely to follow prompt)
./scripts/generate.sh --model "your_model.safetensors" --cfg 8.5

# Fixed seed (reproducible results)
./scripts/generate.sh --model "your_model.safetensors" --seed 42

# Higher resolution
./scripts/generate.sh --model "your_model.safetensors" --width 1536 --height 1536
```

### Add More Models

Download additional .safetensors files and copy to `models/`:
```bash
cp ~/Downloads/*.safetensors ~/image-gen/models/
```

ComfyUI auto-detects new models (no restart needed).

### Try LoRA Models

1. Download LoRA .safetensors (usually <2GB)
2. Copy to `models/` directory
3. Generate with LoRA workflow:
   ```bash
   ./scripts/generate.sh \
     --model "base_model.safetensors" \
     --lora "style_lora.safetensors" \
     --workflow workflows/presets/txt2img_lora.json
   ```

### Stop Server When Done

```bash
./stop_comfyui.sh
```

Server stops gracefully and reports GPU memory status.

## Daily Workflow

```bash
cd ~/image-gen

# 1. Start server
./serve_comfyui.sh

# 2. (Optional) Monitor GPU in separate terminal
./monitoring/monitor_comfyui.sh

# 3. Create prompt
echo "your prompt here" > prompts/003_description.txt

# 4. Generate
./scripts/generate.sh --model "your_model.safetensors"

# 5. Stop server
./stop_comfyui.sh
```

## Troubleshooting

### "ComfyUI server not responding"
```bash
# Check if server is running
curl http://localhost:8188/system_stats

# If not, start it
./serve_comfyui.sh

# Check logs if it fails
tail -f logs/server_*.log
```

### "Model file not found"
```bash
# List models in directory
ls -lh models/

# Check what ComfyUI sees
curl http://localhost:8188/object_info | jq '.CheckpointLoaderSimple.input.required.ckpt_name'
```

### "Out of memory"
- Reduce resolution: `--width 768 --height 768`
- Reduce steps: `--steps 15`
- Close other GPU applications
- Check VRAM: `nvidia-smi`

### "No prompt files found"
```bash
# Create prompts directory if missing
mkdir -p prompts

# Create a prompt file
echo "test prompt" > prompts/001_test.txt
```

### Setup Script Fails

If any setup script fails:
1. Read the error message carefully
2. Check `[ERROR]` lines for specific issue
3. Scripts are idempotent - fix issue and re-run
4. Check logs in `logs/` directory

### WSL2 Memory Issues

If setup fails with "out of memory":
1. Verify `.wslconfig` has `memory=48GB`
2. Restart WSL2: `wsl --shutdown` (in PowerShell)
3. Check available memory: `free -h`

## Performance Tips

### Optimize for Speed
- Use 20 steps (default) for ~2-5 second generation
- Keep resolution at 1024x1024
- Use single LoRA at a time

### Optimize for Quality
- Increase steps to 30-40
- Use CFG 7-8
- Try different seeds for variation
- Use high-quality base models

### Optimize for Power
- Default 18 steps: ~420-450W
- More steps = more power (24 steps = ~500W+, 30 steps = ~560W)
- WSL2 limitation: Can't limit GPU power directly
- Monitor in real-time: `./monitoring/monitor_comfyui.sh` (shows power draw with warnings)
- Alternative: Use Windows tools (MSI Afterburner)

## Parameter Reference

| Flag | Default | Description |
|------|---------|-------------|
| `--model` | (required) | SDXL checkpoint filename |
| `--prompt` | (auto) | Inline prompt (overrides file) |
| `--prompt-file` | (auto) | Specific prompt file path |
| `--negative` | "blurry..." | Elements to avoid |
| `--steps` | 18 | Sampling iterations |
| `--cfg` | 7.0 | Guidance scale (1-20) |
| `--seed` | random | Reproducible seed |
| `--width` | 1024 | Output width |
| `--height` | 1024 | Output height |
| `--workflow` | txt2img_basic | Workflow JSON path |
| `--lora` | (none) | LoRA model filename |

## What You've Learned

✅ Configured WSL2 for GPU computing  
✅ Installed ComfyUI with CUDA support  
✅ Downloaded and organized SDXL models  
✅ Started ComfyUI server  
✅ Generated images via command line  
✅ Managed prompts with text files  

## Next Resources

- **README.md** - Full feature documentation
- **docs/history/** - Session change logs
- **workflows/presets/** - Available workflow JSONs
- [ComfyUI Documentation](https://github.com/comfyanonymous/ComfyUI)
- [SDXL Guide](https://stability.ai/stable-diffusion) - Model architecture
