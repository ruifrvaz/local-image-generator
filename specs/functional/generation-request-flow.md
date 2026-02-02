---
id: FUN-GEN-REQUEST
status: implemented
created: 2026-02-01
implemented: 2026-02-02T21:15:00Z
prompt_version: initial
---

# Generation Request Flow

## References

### Implements

- [BUS-FRONTEND-UI-006](../business/uc6-frontend-ui.md) — User can initiate generation by clicking Generate button
- [BUS-FRONTEND-UI-007](../business/uc6-frontend-ui.md) — User sees real-time progress indicator
- [BUS-FRONTEND-UI-008](../business/uc6-frontend-ui.md) — User sees generated image within 2 seconds
- [BUS-FRONTEND-UI-024](../business/uc6-frontend-ui.md) — User receives actionable error messages

## Scope

### Included

- User input validation for generation requests
- Request submission to ComfyUI backend
- Real-time status polling and progress display
- Completed image download and display
- Error detection and user notification

### Excluded

- Batch and sequence generation workflows (separate specs)
- Gallery storage and management (separate spec)
- Model selection interface (separate spec)
- Prompt template management (separate spec)

## User Flow

### Overview

User submits a single image generation request through the frontend UI. System validates input, submits to ComfyUI backend, polls for completion, downloads result, and displays image.

### Steps

1. User enters prompt text in input field (1-500 characters)
2. User selects model from dropdown
3. User optionally adjusts parameters: steps (1-150), CFG (1.0-30.0), seed, resolution
4. User clicks "Generate" button
5. Frontend validates all inputs against constraints
6. Frontend constructs workflow JSON with user parameters
7. Frontend POSTs workflow to ComfyUI `/prompt` endpoint
8. Backend returns `prompt_id`
9. Frontend displays progress indicator (state: queued)
10. Frontend polls `/history/{prompt_id}` every 500ms
11. When status = complete, frontend downloads image from `/view?filename=`
12. Frontend displays image with metadata
13. Frontend returns to idle state, ready for next request

### Error Handling

| Condition | Behavior |
|-----------|----------|
| Prompt empty | Display validation error: "Prompt cannot be empty" |
| Prompt >500 chars | Display validation error: "Prompt exceeds 500 character limit" |
| Steps out of range | Display validation error: "Steps must be between 1-150" |
| CFG out of range | Display validation error: "CFG must be between 1.0-30.0" |
| Model not selected | Display validation error: "Please select a model" |
| Backend unreachable | Display error: "Cannot connect to generation server. Ensure ComfyUI is running." |
| Generation failed | Display error from backend + "Retry" button |
| Timeout (>300s) | Display error: "Generation timed out. Check server logs." |

## Data Model

### GenerationRequest

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| prompt | text | User's text prompt | Required, 1-500 characters |
| model | text | Model filename | Required, must exist in backend |
| steps | number | Sampling steps | Optional, default 20, range 1-150 |
| cfg | number | Classifier-free guidance scale | Optional, default 7.0, range 1.0-30.0 |
| seed | number | Random seed for reproducibility | Optional, default -1 (random) |
| resolution | object | Image dimensions | Optional, default {width: 1024, height: 1024}, range 512-2048 |

### GenerationResponse

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| requestId | text | Unique identifier for request | Required, from backend `prompt_id` |
| status | enum | Current state | Required, one of: queued, processing, complete, failed |
| imageUrl | text | Download URL for completed image | Required when status=complete |
| errorMessage | text | Error description if failed | Required when status=failed |

### GeneratedImage

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| id | text | Unique identifier | Required, generated from timestamp |
| filepath | text | Absolute path to saved image | Required |
| thumbnail | text | Path to thumbnail | Required |
| prompt | text | Generation prompt | Required |
| model | text | Model used | Required |
| seed | number | Seed used | Required |
| parameters | object | Steps, CFG, resolution | Required |
| timestamp | datetime | Creation time | Required |
| metadata | object | Additional ComfyUI metadata | Optional |

### Relationships

| From | To | Type | Description |
|------|-----|------|-------------|
| GenerationRequest | GenerationResponse | one-to-one | Each request produces one response |
| GenerationResponse | GeneratedImage | one-to-one | Successful response produces one image |

## API Contract

### submitGeneration

**Purpose:** Submit generation request to ComfyUI backend

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| workflow | object | Yes | ComfyUI workflow JSON with user parameters injected |

**Workflow JSON structure:**
```json
{
  "1": { "inputs": { "ckpt_name": "user_models/{model}" } },
  "2": { "inputs": { "text": "{prompt}" } },
  "5": { "inputs": { "seed": {seed}, "steps": {steps}, "cfg": {cfg} } }
}
```

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| prompt_id | text | Unique identifier for tracking generation |
| number | number | Queue position number |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Invalid workflow | HTTP 400 | Malformed workflow JSON |
| Backend unavailable | HTTP 503 | ComfyUI server not responding |
| Model not found | HTTP 400 | Specified model doesn't exist |

### pollStatus

**Purpose:** Check generation progress

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| prompt_id | text | Yes | Request identifier from submitGeneration |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| status | object | Contains generation state and outputs |
| outputs | object | Contains image filenames when complete |

**Example response (complete):**
```json
{
  "{prompt_id}": {
    "status": { "completed": true },
    "outputs": {
      "9": { "images": [{ "filename": "ComfyUI_00001.png" }] }
    }
  }
}
```

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Invalid prompt_id | HTTP 404 | Request not found in history |
| Generation failed | status.error | Error message from backend |

### downloadImage

**Purpose:** Download completed image from backend

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| filename | text | Yes | Image filename from pollStatus outputs |

#### Response

**Success:**

Binary image data (PNG format)

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| File not found | HTTP 404 | Image file doesn't exist |

## State Transitions

### States

| State | Description | Entry Condition |
|-------|-------------|-----------------|
| Idle | Ready for user input | Initial state or after completion/error |
| ValidationPending | Checking user inputs | Generate button clicked |
| RequestSubmitted | Sending to backend | Validation passed |
| Queued | Waiting in generation queue | Backend accepted request |
| Processing | Image being generated | Backend started processing |
| ImageReady | Generation complete | Backend returned success |
| DisplayImage | Showing result to user | Image downloaded |
| GenerationFailed | Error occurred | Backend returned error or timeout |
| ErrorDisplayed | Showing error to user | Error message formatted |

### Transitions

```
Idle → [Generate Click] → ValidationPending
ValidationPending → [Valid Input] → RequestSubmitted → Queued
ValidationPending → [Invalid Input] → ErrorDisplayed → Idle
Queued → [Status Poll: Processing] → Processing
Processing → [Status Poll: Complete] → ImageReady → DisplayImage → Idle
Processing → [Status Poll: Failed] → GenerationFailed → ErrorDisplayed → Idle
Processing → [Timeout 300s] → GenerationFailed → ErrorDisplayed → Idle
```

| From | Event | To | Guard Condition |
|------|-------|-----|-----------------|
| Idle | Generate Click | ValidationPending | Form filled |
| ValidationPending | Valid Input | RequestSubmitted | All constraints satisfied |
| ValidationPending | Invalid Input | ErrorDisplayed | Any constraint violated |
| RequestSubmitted | Backend Accept | Queued | prompt_id received |
| Queued | Status Update | Processing | Backend status = processing |
| Processing | Status Update | ImageReady | Backend status = complete |
| Processing | Status Update | GenerationFailed | Backend status = error |
| Processing | Timeout | GenerationFailed | Elapsed time > 300 seconds |
| ImageReady | Image Downloaded | DisplayImage | Image saved locally |
| DisplayImage | Display Complete | Idle | Image rendered in UI |
| ErrorDisplayed | User Acknowledged | Idle | User clicks OK or retry |

## Acceptance Criteria

Requirements use format: `FUN-GEN-REQUEST-[NNN]`

- [x] FUN-GEN-REQUEST-001: Frontend validates prompt is not empty before submission
- [x] FUN-GEN-REQUEST-002: Frontend validates prompt length is ≤500 characters
- [x] FUN-GEN-REQUEST-003: Frontend validates steps value is between 1-150
- [x] FUN-GEN-REQUEST-004: Frontend validates CFG value is between 1.0-30.0
- [x] FUN-GEN-REQUEST-005: Frontend validates seed is integer or -1
- [x] FUN-GEN-REQUEST-006: Frontend validates resolution width/height are between 512-2048
- [x] FUN-GEN-REQUEST-007: Frontend constructs workflow JSON with user parameters injected into correct node IDs
- [x] FUN-GEN-REQUEST-008: Frontend sends HTTP POST to `/prompt` with workflow JSON body
- [x] FUN-GEN-REQUEST-009: Frontend extracts `prompt_id` from backend response
- [x] FUN-GEN-REQUEST-010: Frontend displays progress indicator showing "Queued" state immediately after submission
- [x] FUN-GEN-REQUEST-011: Frontend polls `/history/{prompt_id}` endpoint every 500ms
- [x] FUN-GEN-REQUEST-012: Frontend updates progress indicator to "Processing" when backend status changes
- [x] FUN-GEN-REQUEST-013: Frontend detects completion when response contains `status.completed = true`
- [x] FUN-GEN-REQUEST-014: Frontend extracts image filename from `outputs` object
- [x] FUN-GEN-REQUEST-015: Frontend downloads image via `/view?filename={filename}` endpoint
- [x] FUN-GEN-REQUEST-016: Frontend displays downloaded image within 2 seconds of completion detection
- [x] FUN-GEN-REQUEST-017: Frontend displays image metadata alongside image (prompt, model, seed, steps, CFG)
- [x] FUN-GEN-REQUEST-018: Frontend transitions to idle state after image display
- [x] FUN-GEN-REQUEST-019: Frontend detects timeout if polling exceeds 300 seconds
- [x] FUN-GEN-REQUEST-020: Frontend displays "Cannot connect to server" error if backend unreachable
- [x] FUN-GEN-REQUEST-021: Frontend displays backend error message if generation fails
- [x] FUN-GEN-REQUEST-022: Frontend provides "Retry" button on error display
- [x] FUN-GEN-REQUEST-023: Frontend logs all errors with timestamp and request details
- [x] FUN-GEN-REQUEST-024: Frontend remains responsive (other UI elements functional) during polling
- [x] FUN-GEN-REQUEST-025: Frontend cancels polling if user navigates away from page

---

*Generated with smaqit v0.6.2-beta*
