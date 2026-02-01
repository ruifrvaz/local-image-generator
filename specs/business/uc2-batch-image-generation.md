---
id: BUS-BATCH-IMG
status: implemented
created: 2026-02-01
prompt_version: retroactive
implemented: 2025-12-03
---

# UC2-BATCH-IMG: Batch Image Generation

## Scope

### Included

- Generating multiple image variations from single prompt
- Sequential seed incrementation for variation diversity
- Numbered output file naming (001, 002, 003...)
- Per-image metadata preservation
- Progress tracking for multi-image batches

### Excluded

- Multiple distinct prompts (covered in UC3: Sequence Generation)
- Parallel generation (ComfyUI processes sequentially)
- Custom seed sequences (only linear increment)
- Batch resumption after interruption

## Actors

| Actor | Description | Goals |
|-------|-------------|-------|
| Creative User | Artist exploring prompt variations | Generate multiple interpretations of single concept to select best result |
| Performance Optimizer | User monitoring batch efficiency | Complete batch generation without manual intervention, predictable time estimates |
| System | ComfyUI server processing queue | Process batch requests sequentially, preserve individual metadata per image |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Batch Throughput | 2-5 seconds per image | Total time / image count (20 steps, 1024x1024) |
| Success Rate | 100% | Images generated / images requested |
| Progress Visibility | Real-time | User sees N/TOTAL counter during generation |
| Metadata Accuracy | 100% | Each metadata file contains correct seed for corresponding image |

## Use Case

### Preconditions

- ComfyUI server running on localhost:8188
- At least one .safetensors model file in `models/` directory
- Prompt text file available (or inline prompt specified)
- Virtual environment activated
- Sufficient disk space for multiple outputs (each ~2-5MB)

### Main Flow

1. User specifies `--count N` parameter (N > 1) in generation command
2. User provides model, prompt, and other generation parameters
3. System validates preconditions (model exists, server responsive, prompt available)
4. System determines base seed (user-specified or random)
5. System creates single timestamped output directory for entire batch
6. System begins iteration loop for count N
7. For each iteration, system calculates current seed (base + iteration - 1)
8. System displays progress indicator "[N/TOTAL] Generating with seed S..."
9. System injects current seed into workflow JSON
10. System submits generation request to ComfyUI API
11. System polls for completion
12. System downloads image as `image_NNN.png` (zero-padded 3 digits)
13. System saves metadata as `prompt_NNN.txt` with iteration-specific seed
14. System increments iteration counter
15. System repeats steps 7-14 until all images generated
16. System displays summary with total count and output directory

### Alternative Flows

#### A1: Fixed Seed Mode

**Trigger:** User specifies both `--seed` and `--count` flags

1. System uses base seed + increment for each iteration (seed diversity)
2. Rejoin main flow at step 6

#### A2: Generation Failure Mid-Batch

**Trigger:** Any iteration fails (timeout, server error, disk full) during step 10-13

1. System displays error message with failed iteration number
2. System exits without completing remaining iterations
3. System preserves successfully generated images
4. User must restart batch from beginning (no resume)

#### A3: Single Image Count

**Trigger:** User specifies `--count 1` (step 1)

1. System generates single image using UC1 (Single Image Generation) flow
2. System uses non-numbered filenames (`image.png`, `prompt.txt`)
3. End

### Postconditions

- N PNG image files saved to single timestamped output directory
- N metadata .txt files saved with corresponding seeds
- All images share parameters except seed values
- User can identify best result and reproduce using its metadata

## Acceptance Criteria

Requirements use format: `BUS-BATCH-IMG-[NNN]`

- [ ] BUS-BATCH-IMG-001: User generates multiple images with single `--count N` parameter
- [ ] BUS-BATCH-IMG-002: System creates single output directory for entire batch (YYYYMMDD_HHMMSS)
- [ ] BUS-BATCH-IMG-003: System saves images as `image_NNN.png` with zero-padded numbers (001, 002, ...)
- [ ] BUS-BATCH-IMG-004: System saves metadata as `prompt_NNN.txt` matching image numbers
- [ ] BUS-BATCH-IMG-005: System increments seed sequentially (base, base+1, base+2, ...)
- [ ] BUS-BATCH-IMG-006: System displays progress counter "[N/TOTAL]" for each image
- [ ] BUS-BATCH-IMG-007: Each metadata file contains correct seed used for that specific image
- [ ] BUS-BATCH-IMG-008: System maintains 2-5 second generation time per image in batch
- [ ] BUS-BATCH-IMG-009: User specifies base seed with `--seed` flag for reproducible batch
- [ ] BUS-BATCH-IMG-010: System uses random base seed when no `--seed` specified
- [ ] BUS-BATCH-IMG-011: All images in batch share model, prompt, steps, CFG, resolution
- [ ] BUS-BATCH-IMG-012: System displays summary with total count after batch completion
- [ ] BUS-BATCH-IMG-013: System exits with error on mid-batch failure (no partial completion)
- [ ] BUS-BATCH-IMG-014: Count parameter accepts range 1-999 (limited by filename padding)
- [ ] BUS-BATCH-IMG-015: System uses non-numbered filenames when `--count 1` specified

---

*Generated with smaqit v0.6.2-beta*
