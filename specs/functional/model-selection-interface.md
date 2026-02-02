---
id: FUN-MODEL-SELECT
status: implemented
created: 2026-02-01
implemented: 2026-02-02T21:15:00Z
prompt_version: initial
---

# Model Selection Interface

## References

### Enables

- [BUS-FRONTEND-UI-004](../business/uc6-frontend-ui.md) — User can select model from dropdown
- [BUS-MODEL-MGMT](../business/uc5-model-management.md) — Model management use case

## Scope

### Included

- Model discovery from ComfyUI backend
- Categorized model display (base, LoRA, merged)
- Model selection dropdown interface
- Model-specific parameter recommendations
- Real-time model list updates

### Excluded

- Model downloading or acquisition
- Model organization or file management
- LoRA weight adjustment
- Multiple LoRA selection (future enhancement)

## User Flow

### Overview

User clicks model selection dropdown to view available models organized by category. System queries ComfyUI backend, displays categorized list, and updates form when user selects model.

### Steps

1. User clicks model selection dropdown in generation form
2. Frontend queries ComfyUI backend for available models
3. Backend scans model directories and returns model list
4. Frontend categorizes models: base, LoRA, merged
5. Frontend displays dropdown with category headers
6. User selects model from categorized list
7. Frontend updates generation form with selected model
8. Frontend optionally displays model-specific parameter recommendations
9. User proceeds with generation using selected model

### Error Handling

| Condition | Behavior |
|-----------|----------|
| Backend unreachable | Display error: "Cannot load models. Check ComfyUI server." |
| No models found | Display warning: "No models available. Add .safetensors files to models directory." |
| Model query timeout | Display error: "Model discovery timed out. Retry?" |
| Invalid model selection | Reset dropdown to default, display error: "Selected model no longer available" |

## Data Model

### ModelInfo

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| filename | text | Model file name | Required, unique |
| displayName | text | User-friendly name | Required, derived from filename |
| category | enum | Model type | Required, one of: base, lora, merged |
| path | text | Relative path from ComfyUI models directory | Required |
| filesize | number | Size in bytes | Optional |
| lastModified | datetime | File modification time | Optional |

### ModelList

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| base | array | Base SDXL models | Array of ModelInfo |
| lora | array | LoRA models | Array of ModelInfo |
| merged | array | Merged models | Array of ModelInfo |
| totalCount | number | Total models across categories | Required, ≥0 |

### ModelSelection

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| selectedModel | text | Chosen model filename | Required |
| category | enum | Model category | Required |
| recommendedParams | object | Suggested steps, CFG | Optional |

### Relationships

| From | To | Type | Description |
|------|-----|------|-------------|
| ModelList | ModelInfo | one-to-many | List contains multiple models |
| ModelSelection | ModelInfo | one-to-one | Selection references specific model |

## API Contract

### loadAvailableModels

**Purpose:** Query ComfyUI backend for all available models

#### Request

No parameters required.

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| models | ModelList | Categorized model information |

**ComfyUI API mapping:**
- Endpoint: `GET /object_info`
- Extract: `CheckpointLoaderSimple.input.required.ckpt_name` for base models
- Extract: `LoraLoader.input.required.lora_name` for LoRA models

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Backend unavailable | HTTP 503 | ComfyUI server not responding |
| Invalid response format | HTTP 500 | Cannot parse model list |

### categorizeModels

**Purpose:** Organize raw model filenames into categories

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| rawModelList | array | Yes | Filenames from backend |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| categorized | ModelList | Organized by type |

**Categorization rules:**
- Path contains `user_models/`: extract category from parent directory
- Filename pattern: `.safetensors` extension required
- Base: models in `base/` directory
- LoRA: models in `loras/` directory
- Merged: models in `merged/` directory

### selectModel

**Purpose:** Update generation form with chosen model

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| modelFilename | text | Yes | Selected model filename |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| selection | ModelSelection | Model and recommended params |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Model not in list | HTTP 404 | Model no longer available |

## State Transitions

### States

| State | Description | Entry Condition |
|-------|-------------|-----------------|
| Idle | Dropdown closed, default shown | Initial state |
| Loading | Fetching models from backend | Dropdown clicked |
| DisplayList | Showing categorized models | Models loaded |
| ModelSelected | User chose model | Item clicked |
| Error | Failed to load models | Backend error |

### Transitions

```
Idle → [Dropdown Click] → Loading
Loading → [Backend Success] → DisplayList
Loading → [Backend Failure] → Error → Idle
DisplayList → [Model Click] → ModelSelected → Idle
DisplayList → [Click Outside] → Idle
```

| From | Event | To | Guard Condition |
|------|-------|-----|-----------------|
| Idle | Dropdown Open | Loading | User clicked dropdown |
| Loading | Load Success | DisplayList | Models retrieved |
| Loading | Load Failure | Error | Backend error |
| DisplayList | Select Model | ModelSelected | Valid model clicked |
| DisplayList | Close Dropdown | Idle | User clicked outside |
| ModelSelected | Selection Confirmed | Idle | Model saved to form |
| Error | Retry Click | Loading | User retry |
| Error | Dismiss | Idle | User acknowledged |

## Acceptance Criteria

Requirements use format: `FUN-MODEL-SELECT-[NNN]`

- [x] FUN-MODEL-SELECT-001: Frontend queries ComfyUI `/object_info` endpoint on dropdown click
- [x] FUN-MODEL-SELECT-002: Frontend extracts model filenames from `CheckpointLoaderSimple.input.required.ckpt_name`
- [x] FUN-MODEL-SELECT-003: Frontend extracts LoRA filenames from `LoraLoader.input.required.lora_name`
- [x] FUN-MODEL-SELECT-004: Frontend categorizes models based on directory path (base, lora, merged)
- [x] FUN-MODEL-SELECT-005: Frontend removes "user_models/" prefix from display names
- [x] FUN-MODEL-SELECT-006: Frontend removes ".safetensors" extension from display names
- [x] FUN-MODEL-SELECT-007: Frontend displays dropdown with three category sections
- [x] FUN-MODEL-SELECT-008: Each category section has header: "Base Models", "LoRA Models", "Merged Models"
- [x] FUN-MODEL-SELECT-009: Frontend sorts models alphabetically within each category
- [x] FUN-MODEL-SELECT-010: Frontend displays model count in category headers (e.g., "Base Models (3)")
- [x] FUN-MODEL-SELECT-011: Frontend hides empty categories from dropdown
- [x] FUN-MODEL-SELECT-012: Frontend updates selected value when user clicks model
- [x] FUN-MODEL-SELECT-013: Frontend closes dropdown after model selection
- [x] FUN-MODEL-SELECT-014: Frontend stores full filename with path for backend submission
- [x] FUN-MODEL-SELECT-015: Frontend displays user-friendly name in dropdown button
- [x] FUN-MODEL-SELECT-016: Frontend provides default model selection on page load (first available)
- [x] FUN-MODEL-SELECT-017: Frontend displays loading spinner while fetching models
- [!] FUN-MODEL-SELECT-018: Frontend caches model list for 60 seconds to reduce backend queries
- [!] FUN-MODEL-SELECT-019: Frontend provides "Refresh Models" button to force reload
- [x] FUN-MODEL-SELECT-020: Frontend displays error message if no models available
- [x] FUN-MODEL-SELECT-021: Error message includes instruction: "Add .safetensors files to models directory"
- [!] FUN-MODEL-SELECT-022: Frontend handles backend timeout (5 second limit)
- [!] FUN-MODEL-SELECT-023: Frontend validates selected model still exists before submission
- [!] FUN-MODEL-SELECT-024: Frontend displays warning if selected model removed during session
- [!] FUN-MODEL-SELECT-025: Frontend re-queries models after warning to update list

### Untestable Criteria

- [x] FUN-MODEL-SELECT-026: Dropdown displays models with intuitive categorization *(untestable)*
  - **Reason:** "Intuitive" is subjective user experience assessment
  - **Proposal:** Validate categorization logic matches directory structure (testable) + user feedback
  - **Resolution:** Manual user testing with category naming validation

---

*Generated with smaqit v0.6.2-beta*
