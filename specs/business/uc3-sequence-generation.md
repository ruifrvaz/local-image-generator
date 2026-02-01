---
id: BUS-SEQUENCE
status: implemented
created: 2026-02-01
prompt_version: retroactive
implemented: 2025-12-03
---

# UC3-SEQUENCE: Sequence Generation

## Scope

### Included

- Multi-frame image generation from ordered prompt files
- Visual consistency controls (shared prefix, suffix, LoRA, negative prompt)
- Alphabetical frame ordering via filename convention
- Sequence-specific output organization
- Dry-run preview mode for prompt validation
- Both named sequences and custom folder paths

### Excluded

- Video compilation from frames
- Frame interpolation or tweening
- Real-time sequence editing
- Parallel frame generation
- Automatic character/setting extraction from story text

## Actors

| Actor | Description | Goals |
|-------|-------------|-------|
| Sequence Creator | User creating visual narratives, storyboards, or animations | Generate cohesive multi-frame sequences with consistent visual elements across frames |
| Creative User | Artist exploring story concepts | Preview prompt sequences before generation, iterate on narrative pacing |
| System | Generation pipeline processing frame queue | Maintain consistency parameters across frames, process sequentially, preserve frame order |
| Performance Optimizer | User monitoring batch efficiency | Complete sequences efficiently without manual frame-by-frame intervention |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Visual Consistency | >80% perceived similarity | Same character/setting recognizable across frames *(untestable - subjective)* |
| Frame Throughput | 2-5 seconds per frame | Total time / frame count (20 steps, 1024x1024) |
| Frame Order Accuracy | 100% | Output frame N corresponds to input prompt N |
| Prefix Application | 100% | All frames include shared prefix text |
| Sequence Completion | 100% | All frames generated or none (atomic batch) |

## Use Case

### Preconditions

- ComfyUI server running on localhost:8188
- At least one .safetensors model in `models/` directory
- Directory containing numbered prompt files (NNN_*.txt format)
- Each prompt file contains frame-specific description
- Virtual environment activated

### Main Flow

1. User creates sequence directory with numbered prompt files (001_*.txt, 002_*.txt, ...)
2. User executes sequence generation command with `--sequence NAME` or `--folder PATH`
3. User specifies model and optional consistency parameters (prefix, suffix, LoRA, negative, seed)
4. System locates sequence directory and lists all .txt files
5. System sorts files alphabetically to establish frame order
6. System displays sequence preview (file count, consistency parameters)
7. User confirms generation (or exits if using `--dry-run`)
8. System creates sequence-specific output directory
9. System iterates through prompt files in sorted order
10. For each file, system parses positive/negative prompts
11. System concatenates prefix + prompt + suffix
12. System overrides file-based negative with shared negative if specified
13. System calculates frame seed (base seed + frame number, or fixed seed)
14. System generates image using composed parameters
15. System saves image as frame_NNN.png
16. System saves metadata preserving all parameters including prefix/suffix
17. System displays progress "[N/TOTAL] frame_NNN.png"
18. System repeats steps 10-17 until all frames complete
19. System displays completion summary with output directory

### Alternative Flows

#### A1: Dry Run Preview

**Trigger:** User specifies `--dry-run` flag (step 3)

1. System displays sequence frame list with composed prompts
2. System shows consistency parameters (prefix, suffix, LoRA, negative)
3. System shows estimated generation time (frame count × 3 seconds)
4. System exits without generating images

#### A2: Fixed Seed Mode

**Trigger:** User specifies both `--seed` and `--fixed-seed` flags (step 3)

1. System uses identical seed for all frames (maximum consistency)
2. Rejoin main flow at step 9

#### A3: Empty Sequence Directory

**Trigger:** No .txt files found in sequence directory (step 4)

1. System displays error with directory path
2. System provides example prompt file naming convention
3. System exits with non-zero status

#### A4: Missing Sequence Directory

**Trigger:** Named sequence not found in ~/images/prompts/sequences/ (step 4)

1. System displays error with expected path
2. System lists available sequence names
3. System exits with non-zero status

#### A5: Frame Generation Failure

**Trigger:** Any frame fails during generation (step 14)

1. System displays error with failed frame number
2. System exits without completing remaining frames
3. System preserves successfully generated frames
4. User must fix issue and restart sequence

### Postconditions

- N PNG frame files saved to sequence output directory
- N metadata files preserving frame-specific parameters
- Frame order matches input prompt file order
- All frames share consistency parameters (prefix, suffix, LoRA, negative)
- User can review sequence for narrative coherence

## Acceptance Criteria

Requirements use format: `BUS-SEQUENCE-[NNN]`

- [ ] BUS-SEQUENCE-001: User generates multi-frame sequence from ordered prompt files
- [ ] BUS-SEQUENCE-002: User specifies named sequence with `--sequence NAME` (searches ~/images/prompts/sequences/)
- [ ] BUS-SEQUENCE-003: User specifies custom folder with `--folder PATH`
- [ ] BUS-SEQUENCE-004: System processes prompt files in alphabetical order
- [ ] BUS-SEQUENCE-005: User applies shared prefix text to all frame prompts
- [ ] BUS-SEQUENCE-006: User applies shared suffix text to all frame prompts
- [ ] BUS-SEQUENCE-007: User applies shared negative prompt overriding file-based negatives
- [ ] BUS-SEQUENCE-008: User applies shared LoRA to all frames for style consistency
- [ ] BUS-SEQUENCE-009: System increments seed per frame (base + frame number)
- [ ] BUS-SEQUENCE-010: User forces identical seed across all frames with `--fixed-seed`
- [ ] BUS-SEQUENCE-011: System saves frames as `frame_NNN.png` with zero-padded numbers
- [ ] BUS-SEQUENCE-012: System displays progress "[N/TOTAL] frame_NNN.png" per frame
- [ ] BUS-SEQUENCE-013: System creates sequence-specific output directory
- [ ] BUS-SEQUENCE-014: User previews sequence without generation using `--dry-run`
- [ ] BUS-SEQUENCE-015: Dry-run displays frame count, prompts, consistency parameters
- [ ] BUS-SEQUENCE-016: System maintains 2-5 second generation per frame
- [ ] BUS-SEQUENCE-017: System exits with error if sequence directory empty
- [ ] BUS-SEQUENCE-018: System exits with error if named sequence not found
- [ ] BUS-SEQUENCE-019: System preserves prefix and suffix in metadata files
- [ ] BUS-SEQUENCE-020: Each frame metadata contains frame-specific seed value

### Untestable Criteria

- [ ] BUS-SEQUENCE-021: Generated frames maintain visual consistency (characters, setting, style) *(untestable)*
  - **Reason**: Visual consistency is subjective and requires human perception (character recognition, setting similarity)
  - **Proposal**: User validates consistency by reviewing generated frames
  - **Resolution**: Manual review as part of creative workflow; exclude from automated coverage

---

*Generated with smaqit v0.6.2-beta*
