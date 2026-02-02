---
id: BUS-FRONTEND-UI
status: implemented
created: 2026-02-01
implemented: 2026-02-02T21:15:00Z
prompt_version: initial
---

# UC6-FRONTEND-UI: Frontend User Interface

## Scope

### Included

- Web-based interface for prompt input and management
- Image generation triggering from UI
- Story/sequence creation workflow
- Generated image viewing and browsing
- Real-time generation status feedback
- Output gallery organization

### Excluded

- Image editing or post-processing tools
- Advanced workflow customization (remains in ComfyUI web UI)
- Model downloading or external acquisition
- Automated prompt generation (remains with AI agents)
- Server management controls (start/stop remain CLI-based)
- GPU monitoring dashboards (remains with monitoring scripts)

## Actors

| Actor | Description | Goals |
|-------|-------------|-------|
| Creative User | Individual creator using image generation | Access all generation features through intuitive graphical interface without command-line knowledge |
| Story Creator | User creating multi-frame narrative sequences | Manage prompts for entire sequences, track generation progress, view results cohesively |
| Gallery Viewer | User reviewing previously generated content | Browse generated images and sequences, filter by prompt/date, access metadata |
| System | Backend generation pipeline and web server | Serve UI, process user requests, maintain real-time status updates |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Time to First Generation | <30 seconds | Time from UI launch to first image generated (new user) |
| Prompt Entry Speed | <15 seconds | Time to input prompt and start generation (experienced user) |
| Gallery Load Time | <2 seconds | Time to display 50 thumbnail images |
| Generation Status Update Latency | <1 second | Time from backend status change to UI update |
| UI Responsiveness | <100ms | Time for UI interaction feedback (button clicks, form inputs) |
| Zero CLI Dependency | 100% | Percentage of common workflows completable without terminal |

## Use Case

### Preconditions

- ComfyUI server running and accessible on port 8188
- User has web browser (Chrome, Firefox, Edge, Safari)
- At least one SDXL model available in models directory
- User has network access to localhost

### Main Flow

1. User opens web browser and navigates to frontend UI URL
2. System displays homepage with prompt input form and gallery preview
3. User enters text prompt into input field
4. User selects generation type (single image, batch, or story sequence)
5. User optionally adjusts parameters (model, steps, CFG, seed)
6. User clicks "Generate" button
7. System submits generation request to ComfyUI backend
8. System displays real-time progress indicator
9. System receives completed image from backend
10. System displays generated image with metadata
11. System adds image to gallery view
12. User views, downloads, or initiates additional generations

### Alternative Flows

#### AF1: Story Sequence Creation

**Trigger:** User selects "Create Story Sequence" option

1. System displays sequence creation form
2. User enters story description or narrative outline
3. User specifies number of frames (default: 5-10)
4. User optionally specifies narrative arc preference
5. System invokes sequence scene producer agent
6. System displays generated prompt list for review
7. User approves or edits individual frame prompts
8. System queues generation for all frames in sequence
9. System displays sequence-specific progress view (frame N of M)
10. System organizes completed images in sequence gallery view
11. User views sequence as slideshow or individual frames

#### AF2: Browse Existing Gallery

**Trigger:** User navigates to gallery section

1. System displays grid of generated images (most recent first)
2. User optionally applies filters (date range, model, prompt keywords)
3. System updates grid to show matching images
4. User clicks image thumbnail
5. System displays full-size image with complete metadata
6. User can download, delete, or regenerate with variations
7. User returns to gallery grid

#### AF3: Batch Generation from UI

**Trigger:** User selects "Batch Generate" option

1. System displays batch configuration form
2. User enters single prompt
3. User specifies number of variations (default: 5)
4. User optionally enables seed randomization
5. System queues batch generation
6. System displays batch progress (image N of M with thumbnails)
7. System completes batch and displays all variations in comparison view
8. User selects favorites for download or further iteration

#### AF4: Generation Failure

**Trigger:** Backend returns error during generation

1. System detects generation failure
2. System displays user-friendly error message
3. System suggests corrective actions based on error type
4. User can retry, modify parameters, or cancel
5. System logs error details for troubleshooting

#### AF5: Model Selection

**Trigger:** User clicks model selection dropdown

1. System queries backend for available models
2. System displays categorized model list (base, LoRA, merged)
3. User selects model from list
4. System updates generation form with model selection
5. System displays model-specific parameter recommendations (if available)

### Postconditions

**Success:**
- Generated images saved to output directory
- Images displayed in UI gallery
- Metadata preserved in database or filesystem
- Generation history recorded

**Failure:**
- Error message displayed to user
- No corrupt images saved
- System remains in usable state
- User can retry or modify request

## Acceptance Criteria

Requirements use format: `BUS-FRONTEND-UI-[NNN]`

- [x] BUS-FRONTEND-UI-001: User can access web-based UI at localhost URL without authentication
- [x] BUS-FRONTEND-UI-002: User can enter text prompt via input field with minimum 500 character capacity
- [x] BUS-FRONTEND-UI-003: User can select generation type (single, batch, sequence) via radio buttons or dropdown
- [x] BUS-FRONTEND-UI-004: User can select model from dropdown list populated from backend model directory
- [x] BUS-FRONTEND-UI-005: User can adjust generation parameters (steps, CFG, seed, resolution) via form controls
- [x] BUS-FRONTEND-UI-006: User can initiate generation by clicking "Generate" button
- [x] BUS-FRONTEND-UI-007: User sees real-time progress indicator showing generation status (queued, processing, complete)
- [x] BUS-FRONTEND-UI-008: User sees generated image displayed within 2 seconds of backend completion
- [x] BUS-FRONTEND-UI-009: User can view image metadata (prompt, model, seed, parameters) on click or hover
- [x] BUS-FRONTEND-UI-010: User can download generated image via download button or right-click
- [x] BUS-FRONTEND-UI-011: User can view gallery of all generated images in grid layout
- [x] BUS-FRONTEND-UI-012: User can filter gallery by date range via date picker controls
- [x] BUS-FRONTEND-UI-013: User can search gallery by prompt keywords via search input
- [x] BUS-FRONTEND-UI-014: User can view full-size image and metadata by clicking gallery thumbnail
- [!] BUS-FRONTEND-UI-015: User can create story sequence by entering narrative description (100-1000 characters)
- [!] BUS-FRONTEND-UI-016: User can specify sequence frame count via numeric input (range: 3-50)
- [!] BUS-FRONTEND-UI-017: User can review and edit generated frame prompts before committing to generation
- [!] BUS-FRONTEND-UI-018: User sees sequence progress indicator showing current frame (N of M) during generation
- [!] BUS-FRONTEND-UI-019: User can view completed sequence as slideshow with configurable frame duration
- [!] BUS-FRONTEND-UI-020: User can view completed sequence as individual frame grid
- [!] BUS-FRONTEND-UI-021: User can initiate batch generation with count specified via numeric input (range: 2-20)
- [!] BUS-FRONTEND-UI-022: User sees batch progress with thumbnail preview of completed images
- [!] BUS-FRONTEND-UI-023: User can compare batch variations in side-by-side view
- [x] BUS-FRONTEND-UI-024: User receives actionable error messages when generation fails (with retry option)
- [x] BUS-FRONTEND-UI-025: UI remains responsive (<100ms interaction feedback) during active generation
- [x] BUS-FRONTEND-UI-026: User can delete generated images from gallery via delete button with confirmation
- [!] BUS-FRONTEND-UI-027: User can regenerate image with modified parameters from gallery view
- [!] BUS-FRONTEND-UI-028: User can save prompts as templates for reuse via "Save Prompt" button
- [!] BUS-FRONTEND-UI-029: User can load saved prompt templates from dropdown or list
- [x] BUS-FRONTEND-UI-030: Gallery displays image count and total storage usage

### Untestable Criteria

- [x] BUS-FRONTEND-UI-031: UI design is intuitive and requires minimal learning curve *(untestable)*
  - **Reason:** "Intuitive" and "minimal learning curve" are subjective assessments
  - **Proposal:** Measure via user testing — time to first successful generation for new users (<30 seconds)
  - **Resolution:** Manual user testing with target metric validation, not automated testing

---

*Generated with smaqit v0.6.2-beta*
