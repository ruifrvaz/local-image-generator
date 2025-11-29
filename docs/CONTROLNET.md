# ControlNet Guide

**ControlNet** is a neural network extension that gives you **precise control over image generation** by using reference images to guide the structure/composition.

## Core Concept

**Standard SDXL:** "astronaut on mars" → AI decides everything (pose, angle, composition)

**With ControlNet:** "astronaut on mars" + **reference image** → AI follows the reference's structure while applying your prompt's style/content

## Common ControlNet Types

### Canny Edge Detection
- **Input:** Edge-detected outline of a photo
- **Output:** New image following those edges
- **Use:** Preserve composition, change everything else

### Depth Map
- **Input:** Depth information (near/far)
- **Output:** Image matching spatial depth
- **Use:** 3D-consistent transformations

### OpenPose
- **Input:** Stick figure skeleton of human pose
- **Output:** Character in that exact pose
- **Use:** Character posing, animation reference

### Scribble/Sketch
- **Input:** Rough hand-drawn lines
- **Output:** Rendered image following sketch
- **Use:** Quick concept to polished image

### Normal Map
- **Input:** Surface normal information
- **Output:** Image with matching surface details
- **Use:** Texture/lighting consistency

### Segmentation
- **Input:** Colored mask (sky=blue, ground=green, etc.)
- **Output:** Image respecting those regions
- **Use:** Layout control

## Example Workflow

```
1. Take photo of person in specific pose
2. Run through OpenPose preprocessor → stick figure
3. Generate with prompt: "medieval knight in armor"
4. Result: Knight in EXACT pose from original photo
```

## Why You'd Use It

**Problem:** "Generate an astronaut waving" → AI might:
- Not wave at all
- Wave wrong hand
- Wrong angle/perspective

**Solution with ControlNet:**
1. Find/take photo of person waving how you want
2. Extract pose with OpenPose
3. Generate → Astronaut in exact waving pose

## Technical Details

- **Trained separately** from base SDXL model
- **Adds conditioning** to diffusion process (not just prompt conditioning)
- **Multiple ControlNets** can stack (pose + depth + edges simultaneously)
- **Strength adjustable** (0.0 = ignore, 1.0 = strict adherence)
- **File size:** ~700MB-2.5GB per ControlNet model

## ComfyUI Integration

ControlNet workflows require additional nodes:

```
Load ControlNet Model → Apply ControlNet → Sampler
                     ↑
              Preprocessor (Canny/Pose/Depth)
                     ↑
              Input Image
```

**Current Status:**
- Your `txt2img_basic.json` workflow does NOT include ControlNet nodes
- You'd need a separate `txt2img_controlnet.json` workflow to use reference images
- ControlNet models must be downloaded separately and placed in `models/` directory

## Real-World Use Cases

### Consistent Character Poses
Generate multiple images with the same character pose across different styles/scenes.

### Architecture Visualization
Transform rough sketches into photorealistic architectural renders.

### Product Mockups
Create product images following specific reference layouts.

### Animation Frames
Generate animation sequences with consistent character positioning frame-to-frame.

### Photo Transformation
Apply dramatic style changes while preserving original composition and structure.

## Getting Started with ControlNet

### 1. Download ControlNet Models
```bash
cd ~/image-gen/models
# Example: Download OpenPose ControlNet
wget https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth
```

### 2. Create ControlNet Workflow
Create `workflows/presets/txt2img_controlnet.json` with appropriate nodes (see ComfyUI documentation).

### 3. Prepare Reference Image
Use preprocessor or provide pre-processed control image:
- Canny: Edge detection on photo
- OpenPose: Extract skeleton from photo
- Depth: Generate depth map from photo

### 4. Generate with Control
```bash
./scripts/generate.sh \
  --model "base_sdxl.safetensors" \
  --prompt "medieval knight in armor" \
  --workflow workflows/presets/txt2img_controlnet.json \
  --control-image reference_pose.png \
  --controlnet control_v11p_sd15_openpose.pth
```

**Note:** Current `generate.sh` does not yet support ControlNet parameters. This would require workflow modifications and script enhancements.

## ControlNet vs Other Methods

### ControlNet
- **Pros:** Precise structural control, multiple stacking, flexible strength
- **Cons:** Requires separate models, more VRAM, additional preprocessing step
- **Best for:** Exact pose/composition matching

### img2img
- **Pros:** Simple, no extra models, works with any base model
- **Cons:** Less precise control, can drift from reference
- **Best for:** Style transfer, variations on existing images

### Inpainting
- **Pros:** Surgical edits, preserve most of image
- **Cons:** Only for modifications, not full generation
- **Best for:** Fixing/changing specific regions

### LoRA
- **Pros:** Style/concept injection, small file size
- **Cons:** No structural control, trained for specific styles
- **Best for:** Consistent artistic style or character appearance

## Summary

ControlNet is essentially **"here's the structure, now apply this style/content"** instead of letting the AI decide everything from scratch. It bridges the gap between full AI creativity and precise human control.

**When to use:**
- You know exactly what pose/composition you want
- Generating consistent sequences (animation, product shots)
- Transforming sketches to renders
- Maintaining spatial relationships while changing style

**When NOT to use:**
- Purely creative exploration (let AI decide)
- Simple style transfer (use img2img instead)
- You have a good LoRA that already captures your intent
