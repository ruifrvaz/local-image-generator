# SDXL Image Generation with ComfyUI

## Hardware Specifications

**GPU:** NVIDIA RTX 5090 (Blackwell)
- VRAM: 32GB total
- Compute Capability: sm_120 (8.9)
- Requires PyTorch 2.8.0+ with CUDA 12.8+ for full support
- Optimized for SDXL base models (6-8GB VRAM) + LoRA

**System Memory:**
- Total RAM: 64GB DDR5
- WSL2 allocation: 48GB (REQUIRED for dependency compilation)
- Configured in `C:\Users\<username>\.wslconfig`:
  ```ini
  [wsl2]
  memory=48GB
  processors=12
  ```

**Software Environment:**
- OS: Windows 11 + WSL2 (Ubuntu 22.04)
- CUDA: 12.8 (runtime) / 13.0 (toolkit)
- Python: 3.12.3
- PyTorch: 2.8.0+cu128 (RTX 5090 Blackwell sm_120 support)
- Virtual Environment: ~/.venvs/imggen
- ComfyUI: ~/ComfyUI (cloned from GitHub)

## Primary Use Case

**Local SDXL image generation** with LoRA support via ComfyUI:
- User places .safetensors models in `models/` directory
- ComfyUI server runs on port 8188 with web UI
- Bash scripts for command-line generation via API
- Workflow presets for common tasks (txt2img, img2img, upscale)
- No cloud dependencies, privacy-focused

**Features:**
- Setup scripts for one-time installation (0-7 sequence)
- ComfyUI server with GPU-only optimization
- Workflow presets (basic, LoRA, img2img, upscale)
- API-based generation via bash scripts
- Health checks for validation
- Real-time monitoring (GPU, VRAM, queue status)

## Starting or resuming chats

To ensure continuity across chat sessions, **When user starts new chat with "analyze" or "recap":**
- **Always start by read all readme files available** in the directory structure
- **Always read the latest history file first** (`history/` sorted by date)
- **Always scan the tasks folder to see if there are any open tasks**
- Use all this content to understand recent changes and decisions then proceed with standard analysis and suggestions


## Finalizing chats

**When user says "wrap up" or "summarize":**
- **Create history file if session qualifies as significant** (see Documentation Philosophy)
- Filename: `docs/history/YYYY-MM-DD_description.md`
- Include: Actions taken, problems solved, decisions made, files modified, next steps
- Focus on **what** and **why**, not implementation details
- Update this history file as the session reference for next chat
- **Do NOT create** separate RESUME or TODO files (history file serves this purpose)


## Task Management

**When user types "create task - [title]":**
- Create new task file in `tasks/` directory
- Filename: `tasks/NNN_task_title.md` (NNN = next available number, zero-padded to 3 digits)
- Include: Title, priority (1-5, where 1=highest), description, acceptance criteria
- Tasks are numbered sequentially starting at 005 (001-004 reserved for main scifi-llm project)

**When user types "what's next" or asks about tasks:**
- Read all task files in `tasks/` directory
- Show as many tasks as the user asks sorted by priority (1 first) then by number
- Display: number, title, priority
- Limit to top 5-10 tasks unless user requests more

**Task file format:**
```markdown
# [Task Title]

**Priority:** [1-5]  
**Status:** Not Started | In Progress | Completed | Blocked  
**Created:** YYYY-MM-DD

## Description
[Clear description of what needs to be done]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Notes
[Optional additional context]
```

## Documentation Philosophy

**Update core documentation to reflect current state:**
- **Always update** markdown guides when making changes
- Show how things work NOW (not historical evolution)
- Update file structure diagrams to include new folders
- Update script docstrings for consistency

**Documentation file placement rules:**
- ✅ **All guide/reference documentation** → `docs/` directory only
- ✅ **Component-specific setup guides** → `docs/IMAGE_GEN_SETUP.md`
- ✅ **Component README files** → `docs/README.md`

## Virtual Environment

**~/.venvs/imggen (ComfyUI + PyTorch):**
- PyTorch: 2.8.0+cu128 (same as scifi-llm/vllm for consistency)
- ComfyUI: Latest from GitHub
- Dependencies: torchvision, Pillow, safetensors, accelerate, einops, kornia
- Purpose: Run ComfyUI server for SDXL + LoRA generation

**Isolation from main project:**
- Separate from `~/.venvs/{llm, rag, finetune}` in scifi-llm project
- Shared PyTorch version for consistency (2.8.0+cu128)
- Same CUDA toolkit (13.0) and runtime (12.8)

## Setup Script Organization

**ComfyUI setup (`setup/`):**
```
0_check_gpu.sh         → Verify RTX 5090 (copied from scifi-llm)
1_cuda_install.sh      → CUDA 13.0 toolkit (copied from scifi-llm)
2_sys_pkgs.sh          → System packages (build tools + ffmpeg, libgl1)
3_create_venv.sh       → Create ~/.venvs/imggen
4_install_torch.sh     → PyTorch 2.8.0+cu128
5_install_comfyui.sh   → Clone ComfyUI + dependencies + symlinks
6_env_export.sh        → Environment variables (PYTORCH_CUDA_ALLOC_CONF)
```

**Before modifying ANY setup script:**
1. **Script numbering convention** - Setup scripts are numbered 0-7 in sequence order
2. **Check for conflicts** - Don't create duplicate numbers
3. **Virtual environment isolation** - `~/.venvs/imggen` has specific dependencies
4. **Dependency alignment** - PyTorch version MUST match scifi-llm for consistency

**Script Numbering Rules (NEVER VIOLATE):**
```
0-6:     Setup workflow (run ONCE in SEQUENCE)
9-10:    Health checks (run as needed)
Other:   Descriptive names (server, stop, monitor, generate)
```

## Setup Script Troubleshooting Philosophy

**When dependency or installation issues arise:**
- ❌ **DO NOT** propose installing packages manually via `pip install`
- ❌ **DO NOT** suggest one-off fixes outside the setup workflow
- ✅ **DO** identify the root cause in the setup script
- ✅ **DO** fix the issue directly in the appropriate setup script
- ✅ **DO** update script documentation to reflect the fix
- ✅ **DO** verify the complete setup sequence still works (0→7)

**Rationale:**
- Setup scripts are the source of truth
- Manual fixes don't persist across environments
- Future users hit the same issues
- Reproducibility requires complete, working setup sequence

## Architecture

```
Local Machine (WSL2)
       ↓
ComfyUI Server (Port 8188)
  - Web UI: http://localhost:8188
  - API: http://localhost:8188/prompt
       ↓
RTX 5090 GPU (32GB VRAM)
  - SDXL Base Models (~6-8GB)
  - LoRA Models (<2GB)
  - KV Cache & Processing
       ↓
Generated Images
  - outputs/YYYYMMDD_HHMMSS/
  - PNG files + prompt.txt metadata
```

## Core Components

- `serve_comfyui.sh` - Server launcher (port 8188, GPU-only mode)
- `stop_comfyui.sh` - Graceful shutdown with resource cleanup
- `monitoring/monitor_comfyui.sh` - Real-time GPU/VRAM/power/temperature/queue monitor
- `scripts/generate.sh` - Bash API wrapper for CLI generation (reads prompts from files)
- `prompts/` - Text files with generation prompts (latest file auto-detected)
- `workflows/presets/` - ComfyUI workflow JSONs (txt2img_basic, txt2img_lora, img2img, upscale)
- `setup/` - One-time installation scripts (0-7 numbered sequence)
- `monitoring/` - GPU and performance monitoring scripts
- `health_checks/` - Validation tools (9-10, TODO)
- `models/` - User's .safetensors files (base + LoRA, no naming convention)
- `outputs/` - Generated images organized by timestamp

**Key Technical Constraints:**
- RTX 5090 requires PyTorch 2.8.0+ with CUDA 12.8+ (sm_120 support)
- WSL2 needs 48GB RAM allocation for dependency compilation
- ComfyUI auto-detects models in `models/` directory via symlinks
- Workflow JSONs use node-based structure (modify with jq before API POST)

**Environment:**
- Virtual env: `~/.venvs/imggen`
- Always activate before operations: `source ~/.venvs/imggen/bin/activate`
- ComfyUI location: `~/ComfyUI`
- Model directory: `image-gen/models/` (symlinked to ComfyUI)

## Essential Workflows

### Daily Startup (Image Generation)
```bash
cd ~/image-gen

# Start ComfyUI server
./serve_comfyui.sh

# (Optional) Monitor GPU in separate terminal
./monitoring/monitor_comfyui.sh

# Create prompt file (latest file auto-detected)
echo "your prompt text here" > prompts/002_my_prompt.txt

# Generate image (reads latest prompt file automatically)
./scripts/generate.sh --model "base_sdxl.safetensors"

# Or override with inline prompt
./scripts/generate.sh \
  --model "base_sdxl.safetensors" \
  --prompt "astronaut on mars, detailed, 8k" \
  --workflow workflows/presets/txt2img_basic.json

# Stop server
./stop_comfyui.sh
```

### Adding New Models
```bash
# Copy .safetensors files to models directory
cp ~/Downloads/*.safetensors ~/image-gen/models/

# ComfyUI will auto-detect on next startup
# No restart needed if server already running (rescans periodically)
```

### Using Different Workflows
```bash
# Basic generation
--workflow workflows/presets/txt2img_basic.json

# With LoRA
--workflow workflows/presets/txt2img_lora.json
--lora "style_lora.safetensors"

# Image-to-image
--workflow workflows/presets/img2img.json
--input "original.png"

# Upscaling
--workflow workflows/presets/upscale.json
--input "low_res.png"
```

## Critical Patterns

### Model Organization
**User dumps all .safetensors in `models/` directory:**
- Base models: SDXL checkpoints (usually >2GB)
- LoRA models: Fine-tuned styles/concepts (usually <200MB-2GB)
- No naming convention enforced
- ComfyUI scans and categorizes automatically

### Workflow Parameter Injection
**generate.sh workflow:**
1. Load prompt from latest `.txt` file in `prompts/` (or use `--prompt` flag)
2. Load workflow JSON from presets or custom path
3. Use `jq` to substitute parameters:
   - `.["1"].inputs.ckpt_name = $MODEL` (with "user_models/" prefix)
   - `.["2"].inputs.text = $PROMPT`
   - `.["5"].inputs.seed = $SEED`
   - `.["5"].inputs.steps = $STEPS` (default: 20)
   - `.["5"].inputs.cfg = $CFG` (default: 7.0)
4. POST modified JSON to `/prompt` endpoint
5. Poll `/history/{prompt_id}` for completion
6. Download from `/view?filename=` to `outputs/YYYYMMDD_HHMMSS/`
   - `.["5"].inputs.steps = $STEPS`
   - `.["5"].inputs.cfg = $CFG`
3. POST modified JSON to `/prompt` endpoint
4. Poll `/history/{prompt_id}` for completion
5. Download from `/view?filename=`

### API Endpoints
- `/system_stats` - GPU info, VRAM, system status
- `/prompt` - Submit generation job (POST with workflow JSON)
- `/queue` - Get current queue status
- `/history/{prompt_id}` - Check generation status
- `/view?filename={name}` - Download generated image
- `/object_info` - List available nodes and models

## Project Conventions

**Script numbering:**
- 0-6: Setup workflow (run once in sequence)
- 9-10: Health checks and validation
- Server launchers not numbered (kept at root for quick access)
- Monitoring scripts in `monitoring/` directory
- Utilities use descriptive names (generate.sh, monitor_comfyui.sh)

**Error handling:**
- All bash scripts use `set -euo pipefail`
- Scripts echo progress with prefixes: `[CHECK]`, `[OK]`, `[ERROR]`, `[WARN]`
- Non-zero exits on failures

**Documentation style:**
- Direct commands over explanations
- Specific numbers (not ranges)
- No "Let me explain", emojis or motivational language
- Focus on what and why, not how

**Output organization:**
- Timestamped directories: `outputs/YYYYMMDD_HHMMSS/`
- Each generation includes: `image.png` + `prompt.txt` metadata
- Server logs: `logs/server_YYYYMMDD_HHMMSS.log`

## File Organization

```
image-gen/
├── SESSION_SUMMARY.md                # Progress tracking (update each session)
├── serve_comfyui.sh                  # Server launcher
├── stop_comfyui.sh                   # Graceful shutdown
├── .github/
│   └── copilot-instructions.md       # This file
├── setup/                            # Installation scripts (run once)
│   ├── 0_check_gpu.sh
│   ├── 1_cuda_install.sh
│   ├── 2_sys_pkgs.sh
│   ├── 3_create_venv.sh
│   ├── 4_install_torch.sh
│   ├── 5_install_comfyui.sh
│   └── 6_env_export.sh
├── scripts/                          # Utilities
│   └── generate.sh                   # CLI generation wrapper
├── prompts/                          # Text files with prompts
│   └── NNN_description.txt           # Latest file auto-loaded
├── workflows/                        # ComfyUI workflow JSONs
│   └── presets/
│       ├── txt2img_basic.json
│       ├── txt2img_lora.json
│       ├── img2img.json
│       └── upscale.json
├── monitoring/                       # GPU and performance monitoring
│   └── monitor_comfyui.sh            # Real-time GPU/VRAM/power/queue monitor
├── health_checks/                    # Testing & validation (TODO)
│   ├── 9_health.sh
│   └── 10_generation_test.sh
├── models/                           # User's .safetensors files
├── outputs/                          # Generated images (auto-organized)
├── logs/                             # Server logs (auto-generated)
├── benchmarks/                       # Performance testing (future)
├── tasks/                            # Task tracking
└── docs/                             # Documentation (TODO)
    ├── README.md
    ├── IMAGE_GEN_SETUP.md
    ├── QUICK_START.md
    └── COMFYUI_API_REFERENCE.md
```

## Documentation

### Setup Guides (TODO)
- **docs/IMAGE_GEN_SETUP.md** - Complete installation walkthrough
- **docs/QUICK_START.md** - First generation in 5 minutes
- **docs/README.md** - Daily usage and model management

### Reference Documentation (TODO)
- **docs/COMFYUI_API_REFERENCE.md** - API endpoints and workflow structure
- **SESSION_SUMMARY.md** - Current progress and next steps (CREATED ✅)

## Recommended Models

### SDXL Base Models (Place in models/)
- **SD XL Base 1.0** - Official SDXL base model (~6.9GB)
- **Juggernaut XL** - Photorealistic generations
- **DreamShaper XL** - Artistic/creative style
- **RealVisXL** - Ultra-realistic photography

### LoRA Models (Place in models/)
- Style LoRAs: Adjust artistic style (anime, painting, photography)
- Concept LoRAs: Add specific subjects/objects/characters
- Fine-tuned LoRAs: Personal style transfer

## Performance

**Hardware: RTX 5090, 32GB VRAM, 64GB RAM (48GB WSL2)**

- **SDXL Base Generation**: 2-5 seconds (1024x1024, 18 steps)
- **With LoRA**: +0.5-1 second overhead
- **Batch Size 1**: Optimal for RTX 5090 single-user
- **Power Consumption**:
  - 18 steps: ~420-450W (optimized default, stays under 500W)
  - 24 steps: ~500-550W
  - 30 steps: ~560W peak at 96% utilization
  - WSL2 limitation: Cannot use nvidia-smi -pl for power limiting
- **VRAM Usage**: 
  - Base model: ~6-8GB
  - LoRA: +200-500MB per model
  - Processing: ~2-4GB
  - Total: ~10-14GB typical
- **Monitoring**: `./monitoring/monitor_comfyui.sh` tracks GPU%, VRAM, power, temp, queue in real-time

**Context Window Impact:**
- Resolution affects VRAM linearly (1024² = baseline)
- 2048x2048: ~4x VRAM usage
- 512x512: ~0.25x VRAM usage

## Use Cases

### Digital Art Creation
- Concept art for stories/games
- Character design iterations
- Environment/scene generation
- Style exploration with LoRAs

### Photography Enhancement
- Image upscaling (4x with RealESRGAN)
- Style transfer with img2img
- Photo-realistic rendering

### Rapid Prototyping
- Quick visual mockups
- Design iteration with seed control
- Batch generation with prompt variations

## Troubleshooting

### Server Not Responding

```bash
# Check ComfyUI server
curl http://localhost:8188/system_stats

# View logs
tail -f logs/server_*.log

# Restart server
./stop_comfyui.sh
./serve_comfyui.sh
```

### Out of Memory

- Use smaller resolution (768x768 instead of 1024x1024)
- Reduce batch size to 1
- Close other GPU applications
- Check VRAM: `nvidia-smi`

### Model Not Found

```bash
# List models detected by ComfyUI
curl http://localhost:8188/object_info | jq '.CheckpointLoaderSimple.input.required.ckpt_name'

# Verify symlinks
ls -la ~/ComfyUI/models/checkpoints/user_models/
ls -la ~/ComfyUI/models/loras/user_models/

# Check models directory
ls -lh ~/image-gen/models/
```

## Content Guidelines

When generating example prompts, documentation, or suggestions:
- Focus on general-purpose, creative, and artistic use cases
- Provide examples suitable for professional and educational contexts

## Related Projects

This repository can share infrastructure with other PyTorch projects:
- Same PyTorch version (2.8.0+cu128)
- Same CUDA toolkit (13.0)
- Same WSL2 RAM allocation (48GB)
- Separate virtual environments for isolation

## Contributing

When adding features:
- Scripts use `set -euo pipefail` for error handling
- Follow existing naming conventions (numbered setup scripts 0-7)
- Update documentation to reflect current state
- Test complete workflow after changes