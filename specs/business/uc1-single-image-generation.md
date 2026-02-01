---
id: BUS-SINGLE-IMG
status: implemented
created: 2026-02-01
prompt_version: retroactive
implemented: 2025-12-03
---

# UC1-SINGLE-IMG: Single Image Generation

## Scope

### Included

- Loading prompts from text files
- Single image generation with user-specified parameters
- Model selection from local collection
- Metadata preservation with generated images
- Reproducible generation via seed control
- Output organization in timestamped directories

### Excluded

- Multiple image variations (covered in UC2: Batch Image Generation)
- Multi-frame sequences (covered in UC3: Sequence Generation)
- Real-time prompt editing via web UI
- Model downloading or acquisition
- Image editing or post-processing

## Actors

| Actor | Description | Goals |
|-------|-------------|-------|
| Creative User | Individual creator generating single images | Quickly generate high-quality images from text prompts with full parameter control |
| System | ComfyUI server and generation pipeline | Process generation requests efficiently, produce consistent outputs, preserve metadata |
| Performance Optimizer | User monitoring resource efficiency | Achieve 2-5 second generation times while maintaining power consumption <500W |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Generation Time | 2-5 seconds | Time from command execution to image saved (1024x1024, 20 steps) |
| Reproducibility Rate | 100% | Identical outputs for same model/prompt/seed |
| Power Consumption | <500W peak | GPU power draw during generation (nvidia-smi) |
| Metadata Preservation | 100% | All generation parameters saved in accompanying .txt file |
| Prompt Discovery | <2 seconds | Time to locate and load latest prompt file |

## Use Case

### Preconditions

- ComfyUI server running on localhost:8188
- At least one .safetensors model file in `models/` directory
- At least one prompt text file in `~/images/prompts/` directory
- Virtual environment activated
- GPU available with sufficient VRAM (10-14GB free)

### Main Flow

1. User creates or selects prompt text file containing desired image description
2. User executes generation command specifying model and optional parameters
3. System locates latest prompt file or uses specified file path
4. System parses prompt file for positive and negative prompts
5. System validates model exists and server is responsive
6. System loads workflow JSON and injects parameters (model, prompt, steps, CFG, seed, resolution)
7. System submits generation request to ComfyUI API
8. System polls for completion (2-second intervals, 5-minute timeout)
9. System downloads generated image to timestamped output directory
10. System saves metadata file with all generation parameters
11. System reports success with output location

### Alternative Flows

#### A1: Inline Prompt Override

**Trigger:** User provides `--prompt` flag instead of using prompt file

1. System uses inline prompt text instead of loading from file
2. Rejoin main flow at step 5

#### A2: Model Not Found

**Trigger:** Specified model does not exist in `models/` directory (step 5)

1. System displays error message with model path
2. System lists all available models with relative paths
3. System exits with non-zero status

#### A3: Server Not Responding

**Trigger:** ComfyUI server fails health check (step 5)

1. System displays connection error with server URL
2. System suggests starting server with `./serve_comfyui.sh`
3. System exits with non-zero status

#### A4: Generation Timeout

**Trigger:** Generation exceeds 5-minute timeout (step 8)

1. System displays timeout error with elapsed time
2. System exits with non-zero status
3. User must check server logs for failure cause

#### A5: No Prompt Files Found

**Trigger:** No .txt files exist in prompts directory (step 3)

1. System displays error with expected directory path
2. System provides example prompt file format
3. System exits with non-zero status

### Postconditions

- One PNG image file saved to timestamped output directory
- One metadata .txt file saved alongside image
- All generation parameters preserved in metadata
- User can reproduce image using saved seed and parameters

## Acceptance Criteria

Requirements use format: `BUS-SINGLE-IMG-[NNN]`

- [ ] BUS-SINGLE-IMG-001: User generates image in 2-5 seconds (1024x1024, 20 steps, RTX 5090)
- [ ] BUS-SINGLE-IMG-002: User specifies model by relative path from `models/` directory
- [ ] BUS-SINGLE-IMG-003: System auto-loads latest prompt file when no `--prompt-file` specified
- [ ] BUS-SINGLE-IMG-004: User overrides prompt file with `--prompt` flag inline text
- [ ] BUS-SINGLE-IMG-005: System parses structured prompt format (positive: / negative: lines)
- [ ] BUS-SINGLE-IMG-006: System supports legacy format (entire file as positive prompt)
- [ ] BUS-SINGLE-IMG-007: User controls sampling steps (default: 20, range: 1-100)
- [ ] BUS-SINGLE-IMG-008: User controls CFG scale (default: 7.0, range: 1.0-20.0)
- [ ] BUS-SINGLE-IMG-009: User specifies seed for reproducible generation
- [ ] BUS-SINGLE-IMG-010: System uses random seed when no seed specified
- [ ] BUS-SINGLE-IMG-011: User sets custom resolution (width and height independently)
- [ ] BUS-SINGLE-IMG-012: System creates timestamped output directory (YYYYMMDD_HHMMSS)
- [ ] BUS-SINGLE-IMG-013: System saves metadata file with all generation parameters
- [ ] BUS-SINGLE-IMG-014: System displays error when model file not found
- [ ] BUS-SINGLE-IMG-015: System displays error when ComfyUI server not responding
- [ ] BUS-SINGLE-IMG-016: System displays error when no prompt files exist
- [ ] BUS-SINGLE-IMG-017: System validates jq and curl installed before execution
- [ ] BUS-SINGLE-IMG-018: User reproduces identical image using saved metadata seed
- [ ] BUS-SINGLE-IMG-019: System maintains power consumption <500W during generation
- [ ] BUS-SINGLE-IMG-020: System saves image with filename `image.png` (single generation)

---

*Generated with smaqit v0.6.2-beta*
