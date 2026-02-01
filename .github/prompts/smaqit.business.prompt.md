---
name: smaqit.business
description: Create business layer specifications from stakeholder requirements
agent: smaqit.business
---

# Business Prompt

This prompt captures business requirements for your project. These requirements will be used to generate business specifications.

## Requirements

### Actors

**Creative User** - Individual creator (artist, designer, content creator) who generates images locally for personal or professional projects. Goals: Privacy-focused generation, artistic control, fast iteration, reproducible results.

**System Administrator** - Technical user managing the ComfyUI server infrastructure. Goals: Reliable server uptime, GPU resource monitoring, efficient power consumption, minimal manual intervention.

**Model Curator** - User who organizes and manages SDXL checkpoint and LoRA model files. Goals: Easy model discovery, organized storage, flexible model selection, no naming constraints.

**Performance Optimizer** - User concerned with generation speed and resource efficiency. Goals: Fast generation times (2-5 seconds), power efficiency (<500W), predictable VRAM usage, consistent quality.

**Sequence Creator** - User generating multi-frame image sequences (storyboards, animations, visual narratives). Goals: Visual consistency across frames, narrative pacing control, batch efficiency.

### Use Cases

**UC1: Single Image Generation** - User provides prompt text file, selects model, generates single image with specified parameters (steps, CFG, seed, resolution). System produces PNG with metadata.

**UC2: Batch Image Generation** - User generates multiple variations from single prompt using different seeds. System produces numbered sequence with consistent parameters except seed.

**UC3: Sequence Generation** - User provides folder of numbered prompt files with optional shared prefix/suffix, generates multi-frame sequence with visual consistency (same model, LoRA, negative prompt).

**UC4: Server Management** - User starts ComfyUI server with GPU optimization, monitors status, stops gracefully with resource cleanup. Server accessible via web UI and API.

**UC5: Model Management** - User copies .safetensors files to organized subfolders, system auto-detects models without restart, user selects models by relative path.

**UC6: Generation Monitoring** - User tracks real-time GPU utilization, VRAM usage, power consumption, temperature, and queue status during generation.

### Success Metrics

- **Generation Speed**: 2-5 seconds per 1024x1024 image at 20 steps (RTX 5090)
- **Power Efficiency**: 420-450W typical consumption, <500W peak
- **Reproducibility**: Identical outputs for same model/prompt/seed combination
- **Uptime**: Server runs continuously without manual intervention
- **Model Discovery**: All .safetensors files detected within 60 seconds of placement
- **Privacy**: Zero external network requests during generation
- **Usability**: Single command generates image from latest prompt file
- **Visual Consistency**: Sequence frames maintain character/setting/style coherence

### Business Goals

**Privacy-First Operation** - All processing happens locally on user hardware with no cloud dependencies, ensuring complete control over creative content and prompts.

**Zero-Cost Generation** - No API fees, subscription costs, or per-image charges. One-time hardware investment supports unlimited generation.

**Artistic Control** - Users select exact models, LoRA weights, sampling parameters, and seeds for precise creative direction and reproducibility.

**Local Infrastructure Ownership** - Users own and control the complete generation pipeline (models, workflows, server) without vendor lock-in.

**Rapid Iteration** - Fast generation times (2-5 seconds) enable quick experimentation with prompts, parameters, and styles.

**Organized Workflow** - Prompt files stored separately from code, timestamped outputs, metadata preservation enable long-term project management.

### Constraints

- **Hardware Dependency**: Requires RTX 3090/4090/5090 GPU (24GB+ VRAM) for SDXL generation
- **WSL2 Memory**: 48GB RAM allocation required for PyTorch compilation dependencies
- **Local Storage**: 200GB+ free space for models, outputs, and dependencies
- **Platform**: WSL2 (Ubuntu 22.04+) on Windows 11 only
- **No Cloud Fallback**: System must work entirely offline after initial setup
- **Model Licensing**: Users responsible for compliance with model licenses
- **Power Budget**: Target <500W to avoid circuit overload in typical home office
- **Technical Skill**: Requires command-line proficiency and bash script execution
