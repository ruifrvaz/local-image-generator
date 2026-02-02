---
id: FUN-SEQUENCE-GEN
status: draft
created: 2026-02-01
prompt_version: initial
---

# Sequence Generation Workflow

## References

### Foundation Reference

- [FUN-GEN-REQUEST](./generation-request-flow.md) — Extends single generation flow for multi-frame sequences

### Implements

- [BUS-FRONTEND-UI-015](../business/uc6-frontend-ui.md) — User can create story sequence
- [BUS-FRONTEND-UI-016](../business/uc6-frontend-ui.md) — User can specify frame count
- [BUS-FRONTEND-UI-017](../business/uc6-frontend-ui.md) — User can review and edit prompts
- [BUS-FRONTEND-UI-018](../business/uc6-frontend-ui.md) — User sees sequence progress indicator
- [BUS-FRONTEND-UI-019](../business/uc6-frontend-ui.md) — User can view as slideshow
- [BUS-FRONTEND-UI-020](../business/uc6-frontend-ui.md) — User can view as frame grid

## Scope

### Included

- Story description input and validation
- Frame count specification (3-50 range)
- Scene producer agent integration
- Generated prompt review and editing interface
- Sequential frame generation with progress tracking
- Sequence-specific gallery organization
- Slideshow and grid viewing modes

### Excluded

- Single image generation (covered in FUN-GEN-REQUEST)
- Batch variations with same prompt (separate spec)
- Video compilation from sequences
- Frame interpolation or animation

## User Flow

### Overview

User provides a story description and desired frame count. System generates prompts for each frame via scene producer agent, allows user to review/edit, then generates images sequentially with progress tracking.

### Steps

1. User selects "Create Story Sequence" option from generation type selector
2. Frontend displays sequence creation form
3. User enters story description (100-1000 characters)
4. User specifies frame count via number input (default: 7, range: 3-50)
5. User optionally specifies narrative arc (e.g., "rise-fall", "hero's journey")
6. User optionally specifies model and base parameters
7. User clicks "Generate Prompts" button
8. Frontend validates story description length and frame count range
9. Frontend sends request to scene producer agent API
10. Frontend displays loading indicator while agent processes
11. Agent returns array of frame prompts with descriptions
12. Frontend displays prompt review interface (editable list)
13. User reviews prompts, optionally editing individual frames
14. User clicks "Start Generation" button
15. Frontend queues all frames for sequential generation
16. Frontend displays sequence progress (frame N of M)
17. Frontend generates each frame using base generation flow
18. Frontend updates progress indicator after each frame completes
19. Frontend organizes completed images in sequence folder
20. Frontend displays completion message with "View Sequence" button
21. User views sequence in slideshow or grid mode

### Error Handling

| Condition | Behavior |
|-----------|----------|
| Story description empty | Display validation error: "Story description required" |
| Story description <100 chars | Display validation error: "Story too brief. Minimum 100 characters." |
| Story description >1000 chars | Display validation error: "Story too long. Maximum 1000 characters." |
| Frame count <3 | Display validation error: "Minimum 3 frames required" |
| Frame count >50 | Display validation error: "Maximum 50 frames allowed" |
| Agent API unavailable | Display error: "Cannot reach scene producer. Check agent service." |
| Agent returns error | Display agent error message + "Try again" button |
| Frame generation fails | Mark frame as failed, continue with remaining frames, show summary |
| User cancels mid-sequence | Stop generation, save completed frames, display partial sequence |

## Data Model

### SequenceRequest

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| storyDescription | text | User's narrative outline | Required, 100-1000 characters |
| frameCount | number | Number of frames to generate | Required, range 3-50 |
| narrativeArc | text | Optional story structure hint | Optional |
| model | text | Base model for all frames | Required |
| baseParameters | object | Default steps, CFG for frames | Optional |

### SequencePrompts

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| sequenceId | text | Unique identifier for sequence | Required, generated |
| prompts | array | Frame prompt objects | Required, length = frameCount |
| metadata | object | Consistency elements, arc info | Required |

### FramePrompt

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| frameNumber | number | Position in sequence (1-N) | Required |
| prompt | text | Generated prompt text | Required |
| description | text | Human-readable frame summary | Required |
| shotType | text | Camera angle/framing | Optional |
| editable | boolean | Whether user can modify | Default: true |

### SequenceProgress

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| sequenceId | text | Links to SequencePrompts | Required |
| totalFrames | number | Total frames in sequence | Required |
| completedFrames | number | Frames successfully generated | Required, 0 to totalFrames |
| failedFrames | array | Frame numbers that failed | Optional |
| currentFrame | number | Frame currently generating | Optional, 1 to totalFrames |
| status | enum | Overall sequence state | Required, one of: prompting, reviewing, generating, complete, failed, cancelled |

### CompletedSequence

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| sequenceId | text | Unique identifier | Required |
| storyDescription | text | Original story input | Required |
| frames | array | Array of GeneratedImage IDs | Required, ordered |
| createdAt | datetime | Sequence creation time | Required |
| completedAt | datetime | Sequence completion time | Optional |
| folderPath | text | Storage directory path | Required |

### Relationships

| From | To | Type | Description |
|------|-----|------|-------------|
| SequenceRequest | SequencePrompts | one-to-one | Request produces prompts |
| SequencePrompts | FramePrompt | one-to-many | Sequence contains multiple frames |
| SequencePrompts | SequenceProgress | one-to-one | Prompts tracked by progress |
| SequenceProgress | CompletedSequence | one-to-one | Progress results in completed sequence |

## API Contract

### generateSequencePrompts

**Purpose:** Generate frame prompts from story description via scene producer agent

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| story | text | Yes | Story description (100-1000 chars) |
| frames | number | Yes | Number of frames (3-50) |
| arc | text | No | Narrative structure hint |
| model | text | Yes | Model type for syntax (illustrious, sdxl, photorealistic) |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| sequenceId | text | Unique identifier |
| prompts | array | Array of FramePrompt objects |
| metadata | object | Consistency elements (characters, setting, atmosphere) |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Agent unavailable | HTTP 503 | Scene producer service not responding |
| Invalid story length | HTTP 400 | Story outside 100-1000 character range |
| Invalid frame count | HTTP 400 | Frame count outside 3-50 range |

### startSequenceGeneration

**Purpose:** Begin sequential generation of all frames

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| sequenceId | text | Yes | Links to approved prompts |
| prompts | array | Yes | Frame prompts (possibly edited) |
| parameters | object | No | Override generation parameters |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| sequenceId | text | Confirms sequence ID |
| status | text | "Generation started" |
| estimatedTime | number | Estimated seconds to complete all frames |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Invalid sequence ID | HTTP 404 | Sequence not found |
| Empty prompts array | HTTP 400 | No frames to generate |
| Backend unavailable | HTTP 503 | ComfyUI not responding |

### getSequenceProgress

**Purpose:** Poll current status of sequence generation

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| sequenceId | text | Yes | Sequence identifier |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| progress | SequenceProgress | Current state |
| completedFrames | array | Image IDs for completed frames |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Invalid sequence ID | HTTP 404 | Sequence not found |

### cancelSequence

**Purpose:** Stop sequence generation, preserve completed frames

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| sequenceId | text | Yes | Sequence to cancel |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| cancelled | boolean | Always true |
| completedFrames | number | Frames saved before cancellation |

## State Transitions

### States

| State | Description | Entry Condition |
|-------|-------------|-----------------|
| StoryEntry | User entering story description | "Create Sequence" selected |
| ValidationPending | Checking story and frame count | "Generate Prompts" clicked |
| PromptGeneration | Agent creating frame prompts | Validation passed |
| PromptsReview | User reviewing/editing prompts | Agent returned prompts |
| QueuedForGeneration | Awaiting generation start | User approved prompts |
| GeneratingFrame | Creating specific frame image | Frame generation initiated |
| FrameComplete | Single frame finished | Frame generation succeeded |
| SequenceComplete | All frames finished | Last frame completed |
| SequenceFailed | Critical error occurred | Generation failed |
| SequenceCancelled | User stopped generation | User cancel action |

### Transitions

```
StoryEntry → [Generate Prompts Click] → ValidationPending
ValidationPending → [Valid Input] → PromptGeneration
ValidationPending → [Invalid Input] → StoryEntry (show error)
PromptGeneration → [Agent Success] → PromptsReview
PromptGeneration → [Agent Failure] → StoryEntry (show error)
PromptsReview → [Start Generation] → QueuedForGeneration
QueuedForGeneration → [Begin Frame 1] → GeneratingFrame
GeneratingFrame → [Frame Success] → FrameComplete
FrameComplete → [More Frames] → GeneratingFrame (next frame)
FrameComplete → [Last Frame] → SequenceComplete
GeneratingFrame → [Frame Failure] → FrameComplete (mark failed, continue)
GeneratingFrame → [User Cancel] → SequenceCancelled
```

| From | Event | To | Guard Condition |
|------|-------|-----|-----------------|
| StoryEntry | Generate Prompts | ValidationPending | Form filled |
| ValidationPending | Valid Input | PromptGeneration | 100-1000 chars, 3-50 frames |
| ValidationPending | Invalid Input | StoryEntry | Constraints violated |
| PromptGeneration | Agent Success | PromptsReview | Prompts received |
| PromptGeneration | Agent Error | StoryEntry | Agent failed |
| PromptsReview | User Approval | QueuedForGeneration | Prompts confirmed |
| PromptsReview | Edit Prompt | PromptsReview | User modified prompt text |
| QueuedForGeneration | Start Generation | GeneratingFrame | First frame queued |
| GeneratingFrame | Frame Complete | FrameComplete | Image generated |
| FrameComplete | Next Frame | GeneratingFrame | More frames remain |
| FrameComplete | All Done | SequenceComplete | Last frame completed |
| GeneratingFrame | Frame Error | FrameComplete | Mark failed, continue |
| GeneratingFrame | User Cancel | SequenceCancelled | User initiated cancel |

## Acceptance Criteria

Requirements use format: `FUN-SEQUENCE-GEN-[NNN]`

- [ ] FUN-SEQUENCE-GEN-001: Frontend displays sequence creation form when user selects "Create Story Sequence"
- [ ] FUN-SEQUENCE-GEN-002: Form includes textarea for story description with character counter
- [ ] FUN-SEQUENCE-GEN-003: Form includes numeric input for frame count with range validation (3-50)
- [ ] FUN-SEQUENCE-GEN-004: Form includes optional narrative arc dropdown
- [ ] FUN-SEQUENCE-GEN-005: Frontend validates story description is 100-1000 characters before submission
- [ ] FUN-SEQUENCE-GEN-006: Frontend validates frame count is within 3-50 range
- [ ] FUN-SEQUENCE-GEN-007: Frontend sends POST request to scene producer agent API with story, frames, arc, model
- [ ] FUN-SEQUENCE-GEN-008: Frontend displays loading indicator during agent processing
- [ ] FUN-SEQUENCE-GEN-009: Frontend receives array of FramePrompt objects from agent
- [ ] FUN-SEQUENCE-GEN-010: Frontend displays prompt review interface with editable list of frames
- [ ] FUN-SEQUENCE-GEN-011: Each frame shows: frame number, prompt text, description, shot type
- [ ] FUN-SEQUENCE-GEN-012: User can edit prompt text for any frame via inline editing
- [ ] FUN-SEQUENCE-GEN-013: Frontend provides "Start Generation" button in review interface
- [ ] FUN-SEQUENCE-GEN-014: Frontend queues all frames sequentially when generation starts
- [ ] FUN-SEQUENCE-GEN-015: Frontend displays progress indicator showing "Frame N of M"
- [ ] FUN-SEQUENCE-GEN-016: Frontend reuses base generation flow (FUN-GEN-REQUEST) for each frame
- [ ] FUN-SEQUENCE-GEN-017: Frontend updates progress indicator after each frame completes
- [ ] FUN-SEQUENCE-GEN-018: Frontend saves completed images to sequence-specific folder (e.g., `~/images/outputs/sequences/{sequenceId}/`)
- [ ] FUN-SEQUENCE-GEN-019: Frontend creates metadata file for sequence including story description and frame order
- [ ] FUN-SEQUENCE-GEN-020: Frontend polls sequence progress via API every 500ms
- [ ] FUN-SEQUENCE-GEN-021: Frontend displays thumbnail preview of completed frames during generation
- [ ] FUN-SEQUENCE-GEN-022: Frontend provides "Cancel" button during generation
- [ ] FUN-SEQUENCE-GEN-023: Frontend stops generation and preserves completed frames when user cancels
- [ ] FUN-SEQUENCE-GEN-024: Frontend marks failed frames in progress indicator but continues with remaining frames
- [ ] FUN-SEQUENCE-GEN-025: Frontend displays completion summary showing successful/failed frame counts
- [ ] FUN-SEQUENCE-GEN-026: Frontend provides "View Sequence" button after completion
- [ ] FUN-SEQUENCE-GEN-027: Frontend displays sequence in slideshow mode with configurable frame duration
- [ ] FUN-SEQUENCE-GEN-028: Slideshow includes play/pause controls and frame navigation
- [ ] FUN-SEQUENCE-GEN-029: Frontend displays sequence in grid mode showing all frames simultaneously
- [ ] FUN-SEQUENCE-GEN-030: Grid mode shows frame numbers and descriptions below thumbnails
- [ ] FUN-SEQUENCE-GEN-031: Frontend calculates estimated completion time based on frames * average generation time
- [ ] FUN-SEQUENCE-GEN-032: Frontend displays estimated time remaining during generation
- [ ] FUN-SEQUENCE-GEN-033: Frontend handles agent API errors gracefully with retry option
- [ ] FUN-SEQUENCE-GEN-034: Frontend stores sequence metadata for gallery integration
- [ ] FUN-SEQUENCE-GEN-035: Frontend generates sequence thumbnail from first or middle frame

---

*Generated with smaqit v0.6.2-beta*
