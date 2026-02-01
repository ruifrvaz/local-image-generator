---
id: BUS-MODEL-MGMT
status: implemented
created: 2026-02-01
prompt_version: retroactive
implemented: 2025-11-27
---

# UC5-MODEL-MGMT: Model Management

## Scope

### Included

- Organizing models in subfolder structure (base, merged, loras)
- Automatic model detection and discovery
- Model selection by relative path from models/ directory
- Listing available models when selection fails
- No-restart model addition during server operation
- Support for .safetensors format

### Excluded

- Model downloading or acquisition from remote sources
- Model validation or integrity checking
- Model format conversion (e.g., .ckpt to .safetensors)
- Model merging or combination
- Model metadata editing
- Storage quota management

## Actors

| Actor | Description | Goals |
|-------|-------------|-------|
| Model Curator | User organizing SDXL and LoRA model collection | Flexible folder organization, easy model discovery, no naming constraints |
| Creative User | User selecting models for generation | Quick model selection by partial path, clear error messages when model not found |
| System | ComfyUI model detection system | Auto-discover models in subfolders, update catalog without restart, support relative paths |
| System Administrator | User managing disk storage | Track model count, organize by type/style, remove unused models |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Discovery Time | <60 seconds | Time from file placement to model availability |
| Path Flexibility | 100% | All subfolder depths supported (base/, loras/pony/, etc.) |
| Model Listing Accuracy | 100% | Listed models match filesystem exactly |
| Organization Freedom | Unlimited | Users create any subfolder structure without configuration |
| Error Clarity | 100% | Model-not-found errors show available alternatives |

## Use Case

### Preconditions

- Project models/ directory exists at ~/image-gen/models/
- ComfyUI models directory symlinked to project models/ (user_models)
- User has .safetensors model files from external sources
- Sufficient disk space for model storage (typically 200GB+ for collection)

### Main Flow (Add Model)

1. User downloads or copies .safetensors file to local storage
2. User determines appropriate subfolder (base/, merged/, loras/illustrious/, etc.)
3. User creates subfolder if needed (no restrictions on depth or naming)
4. User copies .safetensors file to chosen subfolder
5. ComfyUI server detects new file within 60 seconds (periodic scan)
6. System updates internal model catalog
7. Model becomes available for selection by relative path
8. User references model as "subfolder/filename.safetensors" in generation command

### Main Flow (Select Model)

1. User specifies model with `--model "path/to/model.safetensors"` flag
2. System resolves path relative to models/ directory
3. System checks if model file exists
4. If found, system proceeds with generation using specified model
5. If not found, system displays error with full path attempted
6. System lists all available models with relative paths
7. User corrects model path and retries

### Main Flow (Remove Model)

1. User identifies unused or unwanted model
2. User deletes .safetensors file from models/ directory
3. ComfyUI server detects removal on next catalog scan
4. Model no longer appears in available models list
5. System displays error if user attempts to use removed model

### Alternative Flows

#### A1: Model Added While Server Running

**Trigger:** User adds model file during active server session (step 4)

1. ComfyUI scans models/ directory periodically (every 60 seconds)
2. New model detected automatically without restart
3. Rejoin main flow at step 7

#### A2: Flat Organization (No Subfolders)

**Trigger:** User places all models directly in models/ root (step 2)

1. User skips subfolder organization (step 3)
2. User references models by filename only
3. Rejoin main flow at step 5

#### A3: Deep Subfolder Nesting

**Trigger:** User creates multi-level folder structure (e.g., loras/illustrious/characters/)

1. System supports unlimited nesting depth
2. User references as "loras/illustrious/characters/model.safetensors"
3. Rejoin main flow at step 5

#### A4: Model Path Ambiguity

**Trigger:** User specifies partial filename matching multiple models (step 1)

1. System attempts exact match first
2. If multiple matches exist, system displays error
3. System lists all matching candidates
4. User provides more specific path

#### A5: Models Directory Empty

**Trigger:** No models exist during model selection (step 3)

1. System displays error: model not found
2. System shows "(none found)" in available models list
3. System suggests downloading models
4. User must add at least one model before generation

### Postconditions

- Model files organized in user-defined subfolder structure
- All .safetensors files discoverable by ComfyUI
- Models selectable by relative path from models/ root
- Model catalog reflects current filesystem state

## Acceptance Criteria

Requirements use format: `BUS-MODEL-MGMT-[NNN]`

- [ ] BUS-MODEL-MGMT-001: User places .safetensors files in models/ directory
- [ ] BUS-MODEL-MGMT-002: User organizes models in arbitrary subfolder structure
- [ ] BUS-MODEL-MGMT-003: System discovers models in all subfolders (unlimited depth)
- [ ] BUS-MODEL-MGMT-004: System detects new models within 60 seconds of placement
- [ ] BUS-MODEL-MGMT-005: User selects models by relative path (subfolder/filename.safetensors)
- [ ] BUS-MODEL-MGMT-006: User places models directly in root without subfolder
- [ ] BUS-MODEL-MGMT-007: System displays error when specified model not found
- [ ] BUS-MODEL-MGMT-008: System lists all available models on selection error
- [ ] BUS-MODEL-MGMT-009: Model list shows relative paths sorted alphabetically
- [ ] BUS-MODEL-MGMT-010: User removes models by deleting .safetensors files
- [ ] BUS-MODEL-MGMT-011: System detects model removal on next catalog scan
- [ ] BUS-MODEL-MGMT-012: System supports base models in base/ subfolder
- [ ] BUS-MODEL-MGMT-013: System supports merged models in merged/ subfolder
- [ ] BUS-MODEL-MGMT-014: System supports LoRA models in loras/ subfolder with nesting
- [ ] BUS-MODEL-MGMT-015: System supports .safetensors format exclusively
- [ ] BUS-MODEL-MGMT-016: User creates subfolders without configuration or registration
- [ ] BUS-MODEL-MGMT-017: System adds new models without server restart
- [ ] BUS-MODEL-MGMT-018: User references models with same syntax for LoRA and checkpoints
- [ ] BUS-MODEL-MGMT-019: System displays model count during server startup
- [ ] BUS-MODEL-MGMT-020: System provides helpful error when models/ directory empty

---

*Generated with smaqit v0.6.2-beta*
