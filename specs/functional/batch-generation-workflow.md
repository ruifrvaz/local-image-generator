---
id: FUN-BATCH-GEN
status: draft
created: 2026-02-01
prompt_version: initial
---

# Batch Generation Workflow

## References

### Foundation Reference

- [FUN-GEN-REQUEST](./generation-request-flow.md) — Extends single generation flow for multiple variations

### Implements

- [BUS-FRONTEND-UI-021](../business/uc6-frontend-ui.md) — User can initiate batch generation
- [BUS-FRONTEND-UI-022](../business/uc6-frontend-ui.md) — User sees batch progress with thumbnails
- [BUS-FRONTEND-UI-023](../business/uc6-frontend-ui.md) — User can compare variations side-by-side

## Scope

### Included

- Batch count specification (2-20 range)
- Sequential generation with single prompt
- Seed randomization for variations
- Real-time thumbnail preview during generation
- Side-by-side comparison view
- Batch-specific progress tracking

### Excluded

- Sequence generation with different prompts (separate spec)
- Single image generation (covered in FUN-GEN-REQUEST)
- Parallel generation (remains sequential)
- Batch editing or regeneration

## User Flow

### Overview

User enters a single prompt and requests multiple variations. System generates images sequentially with randomized seeds, displaying progress and thumbnails. User views all variations in comparison mode.

### Steps

1. User selects "Batch Generate" option from generation type selector
2. Frontend displays batch generation form
3. User enters prompt text
4. User specifies batch count via number input (default: 5, range: 2-20)
5. User optionally enables seed randomization (default: enabled)
6. User optionally adjusts base parameters (model, steps, CFG)
7. User clicks "Generate Batch" button
8. Frontend validates prompt and batch count
9. Frontend queues N generation requests with incremented/randomized seeds
10. Frontend displays batch progress indicator (image N of M)
11. Frontend generates each image using base generation flow
12. Frontend displays thumbnail preview as each image completes
13. Frontend updates progress indicator after each completion
14. Frontend displays completion message after all images generated
15. Frontend automatically switches to comparison view
16. User views all variations in grid or side-by-side layout
17. User selects favorites, downloads, or regenerates

### Error Handling

| Condition | Behavior |
|-----------|----------|
| Batch count <2 | Display validation error: "Minimum 2 images required for batch" |
| Batch count >20 | Display validation error: "Maximum 20 images allowed per batch" |
| Prompt empty | Display validation error: "Prompt cannot be empty" |
| Individual image fails | Mark as failed, continue with remaining images, show failed count |
| Backend unavailable | Display error: "Cannot connect to server" + Retry button |
| User cancels mid-batch | Stop generation, save completed images, display partial batch |
| All images fail | Display error: "Batch generation failed" + details |

## Data Model

### BatchRequest

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| prompt | text | Single prompt for all images | Required, 1-500 characters |
| batchCount | number | Number of variations | Required, range 2-20 |
| seedMode | enum | Seed generation strategy | Required, one of: random, incremental |
| baseSeed | number | Starting seed for incremental | Optional, used if seedMode=incremental |
| model | text | Model for all images | Required |
| baseParameters | object | Steps, CFG, resolution | Optional |

### BatchProgress

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| batchId | text | Unique identifier | Required |
| totalImages | number | Total in batch | Required |
| completedImages | number | Successfully generated | Required, 0 to totalImages |
| failedImages | array | Image numbers that failed | Optional |
| currentImage | number | Currently generating | Optional, 1 to totalImages |
| status | enum | Overall batch state | Required, one of: queued, generating, complete, failed, cancelled |
| thumbnails | array | Paths to completed thumbnails | Required |

### CompletedBatch

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| batchId | text | Unique identifier | Required |
| prompt | text | Original prompt | Required |
| images | array | Array of GeneratedImage IDs | Required, ordered |
| parameters | object | Shared parameters | Required |
| createdAt | datetime | Batch creation time | Required |
| completedAt | datetime | Batch completion time | Optional |

### Relationships

| From | To | Type | Description |
|------|-----|------|-------------|
| BatchRequest | BatchProgress | one-to-one | Request tracked by progress |
| BatchProgress | CompletedBatch | one-to-one | Progress results in completed batch |
| CompletedBatch | GeneratedImage | one-to-many | Batch contains multiple images |

## API Contract

### startBatchGeneration

**Purpose:** Queue multiple generation requests with single prompt

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| batchRequest | BatchRequest | Yes | Batch configuration |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| batchId | text | Unique identifier |
| queuedImages | number | Number of requests queued |
| estimatedTime | number | Estimated seconds to complete |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Invalid batch count | HTTP 400 | Count outside 2-20 range |
| Empty prompt | HTTP 400 | Prompt required |
| Backend unavailable | HTTP 503 | ComfyUI not responding |

### getBatchProgress

**Purpose:** Poll current status of batch generation

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| batchId | text | Yes | Batch identifier |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| progress | BatchProgress | Current state |
| thumbnails | array | Paths to completed image thumbnails |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Invalid batch ID | HTTP 404 | Batch not found |

### cancelBatch

**Purpose:** Stop batch generation, preserve completed images

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| batchId | text | Yes | Batch to cancel |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| cancelled | boolean | Always true |
| completedImages | number | Images saved before cancellation |

## State Transitions

### States

| State | Description | Entry Condition |
|-------|-------------|-----------------|
| BatchEntry | User configuring batch | "Batch Generate" selected |
| ValidationPending | Checking inputs | "Generate Batch" clicked |
| QueuedForGeneration | Awaiting generation start | Validation passed |
| GeneratingImage | Creating specific image | Image generation initiated |
| ImageComplete | Single image finished | Image generation succeeded |
| BatchComplete | All images finished | Last image completed |
| BatchFailed | All images failed | No successful generations |
| BatchCancelled | User stopped generation | User cancel action |

### Transitions

```
BatchEntry → [Generate Click] → ValidationPending
ValidationPending → [Valid Input] → QueuedForGeneration
ValidationPending → [Invalid Input] → BatchEntry (show error)
QueuedForGeneration → [Begin Image 1] → GeneratingImage
GeneratingImage → [Image Success] → ImageComplete
ImageComplete → [More Images] → GeneratingImage (next image)
ImageComplete → [Last Image] → BatchComplete
GeneratingImage → [Image Failure] → ImageComplete (mark failed, continue)
GeneratingImage → [User Cancel] → BatchCancelled
```

| From | Event | To | Guard Condition |
|------|-------|-----|-----------------|
| BatchEntry | Generate Click | ValidationPending | Form filled |
| ValidationPending | Valid Input | QueuedForGeneration | 2-20 count, valid prompt |
| ValidationPending | Invalid Input | BatchEntry | Constraints violated |
| QueuedForGeneration | Start Generation | GeneratingImage | First image queued |
| GeneratingImage | Image Complete | ImageComplete | Image generated |
| ImageComplete | Next Image | GeneratingImage | More images remain |
| ImageComplete | All Done | BatchComplete | Last image completed |
| GeneratingImage | Image Error | ImageComplete | Mark failed, continue |
| GeneratingImage | User Cancel | BatchCancelled | User initiated cancel |

## Acceptance Criteria

Requirements use format: `FUN-BATCH-GEN-[NNN]`

- [ ] FUN-BATCH-GEN-001: Frontend displays batch generation form when user selects "Batch Generate"
- [ ] FUN-BATCH-GEN-002: Form includes numeric input for batch count with validation (2-20)
- [ ] FUN-BATCH-GEN-003: Form includes checkbox for seed randomization (default: enabled)
- [ ] FUN-BATCH-GEN-004: Frontend validates batch count is within 2-20 range before submission
- [ ] FUN-BATCH-GEN-005: Frontend validates prompt is not empty
- [ ] FUN-BATCH-GEN-006: Frontend generates random seeds for each image when randomization enabled
- [ ] FUN-BATCH-GEN-007: Frontend uses incremental seeds (base+N) when randomization disabled
- [ ] FUN-BATCH-GEN-008: Frontend queues N generation requests sequentially
- [ ] FUN-BATCH-GEN-009: Frontend displays batch progress indicator showing "Image N of M"
- [ ] FUN-BATCH-GEN-010: Frontend reuses base generation flow (FUN-GEN-REQUEST) for each image
- [ ] FUN-BATCH-GEN-011: Frontend displays thumbnail preview of each completed image during generation
- [ ] FUN-BATCH-GEN-012: Frontend arranges thumbnails in horizontal row as they complete
- [ ] FUN-BATCH-GEN-013: Frontend updates progress indicator after each image completes
- [ ] FUN-BATCH-GEN-014: Frontend polls batch progress via API every 500ms
- [ ] FUN-BATCH-GEN-015: Frontend provides "Cancel" button during generation
- [ ] FUN-BATCH-GEN-016: Frontend stops generation and preserves completed images when user cancels
- [ ] FUN-BATCH-GEN-017: Frontend marks failed images in progress indicator but continues with remaining
- [ ] FUN-BATCH-GEN-018: Frontend displays completion summary showing successful/failed image counts
- [ ] FUN-BATCH-GEN-019: Frontend automatically switches to comparison view after batch completes
- [ ] FUN-BATCH-GEN-020: Comparison view displays all images in grid layout (2-4 columns based on count)
- [ ] FUN-BATCH-GEN-021: Comparison view includes side-by-side mode for 2 selected images
- [ ] FUN-BATCH-GEN-022: User can select multiple images for download via checkboxes
- [ ] FUN-BATCH-GEN-023: User can download selected images as ZIP archive
- [ ] FUN-BATCH-GEN-024: User can regenerate batch with same prompt and different seeds
- [ ] FUN-BATCH-GEN-025: Frontend calculates estimated completion time based on count * average generation time
- [ ] FUN-BATCH-GEN-026: Frontend displays estimated time remaining during generation
- [ ] FUN-BATCH-GEN-027: Frontend saves all batch images to batch-specific folder (e.g., `~/images/outputs/batches/{batchId}/`)
- [ ] FUN-BATCH-GEN-028: Frontend creates metadata file for batch including prompt and seed list
- [ ] FUN-BATCH-GEN-029: Frontend handles partial batch failures gracefully (some succeed, some fail)
- [ ] FUN-BATCH-GEN-030: Frontend stores batch metadata for gallery integration

---

*Generated with smaqit v0.6.2-beta*
