---
name: smaqit.functional
description: Create functional layer specifications from user experience requirements
agent: smaqit.functional
---

# Functional Prompt

This prompt captures functional requirements for your project. These requirements will be used to generate functional specifications.

## Requirements

### User Experience

**Homepage Experience:**
- User opens frontend at localhost URL and immediately sees prompt input form
- Gallery preview displays recent images below prompt form
- Interface loads within 2 seconds
- All form controls provide <100ms feedback on interaction

**Generation Experience:**
- User enters prompt (500 char capacity) and clicks Generate
- Real-time progress indicator shows generation status (queued → processing → complete)
- Generated image displays within 2 seconds of backend completion
- Image metadata (prompt, model, seed, parameters) visible on hover/click

**Gallery Experience:**
- Grid layout displays 50 thumbnails with <2 second load time
- Filter controls: date range picker, keyword search input
- Click thumbnail to view full-size image with complete metadata
- Download button and delete button (with confirmation) on each image

**Sequence Experience:**
- User enters story description (100-1000 chars) and frame count (3-50)
- System generates and displays frame prompts for review/editing
- User approves prompts and sees sequence progress (frame N of M)
- Completed sequence viewable as slideshow or frame grid

**Batch Experience:**
- User enters single prompt and variation count (2-20)
- Batch progress shows thumbnails as each image completes
- Side-by-side comparison view for all variations

### Behaviors

**Configuration Management:**
- System loads environment-specific configuration at startup (URLs, ports, paths)
- System validates all required configuration values are present
- System fails with clear error if configuration missing or invalid
- Configuration values replace all hardcoded constants in source code
- Different deployment environments use different configuration sources

**Generation Request Processing:**
- Parse user input: prompt, generation type, model, parameters
- Validate inputs: prompt length, parameter ranges, model existence
- Submit request to ComfyUI backend API
- Poll backend for status updates every 500ms
- Download completed image from backend
- Save image to gallery storage
- Update gallery view with new image

**Gallery Management:**
- Load images from storage directory on page load
- Sort by timestamp (most recent first)
- Apply user-specified filters (date range, keywords)
- Generate thumbnails for grid display
- Track total image count and storage usage

**Error Handling:**
- Detect generation failures from backend
- Display user-friendly error messages
- Suggest corrective actions based on error type
- Maintain UI in usable state (no crashes)
- Log errors for troubleshooting

**Sequence Generation:**
- Accept story description from user
- Call sequence scene producer agent API
- Display generated prompts in editable list
- Queue each frame for generation sequentially
- Track sequence progress state
- Organize completed frames in sequence folder

**Model Discovery:**
- Query ComfyUI backend for available models
- Categorize models: base, LoRA, merged
- Display in dropdown with categories
- Update list when new models added

### Interactions

**User → Frontend:**
- Text input: prompt, story description
- Dropdown selection: model, generation type
- Number input: steps, CFG, seed, resolution, batch count, frame count
- Button clicks: Generate, Download, Delete, Save Prompt, Load Template
- Gallery interactions: thumbnail click, filter apply, search

**Frontend → ComfyUI Backend:**
- HTTP POST: Submit generation request with workflow JSON
- HTTP GET: Query available models, check generation status, download image
- WebSocket (optional): Real-time status updates

**Frontend → Filesystem:**
- Read: Load gallery images, thumbnails, metadata files
- Write: Save downloaded images, metadata, prompt templates
- Delete: Remove images from gallery

**Frontend → Scene Producer Agent:**
- HTTP POST: Send story description, frame count, preferences
- Receive: Array of frame prompts with metadata

### Data Models

**GenerationRequest:**
- prompt: text (1-500 characters)
- generationType: enum (single, batch, sequence)
- model: text (filename from available models)
- steps: number (1-150, default 20)
- cfg: number (1.0-30.0, default 7.0)
- seed: number (optional, -1 for random)
- resolution: object { width, height } (512-2048)
- batchCount: number (2-20, only for batch type)
- frameCount: number (3-50, only for sequence type)

**GeneratedImage:**
- id: unique identifier
- filepath: absolute path to image file
- thumbnail: path to thumbnail
- prompt: text (generation prompt)
- model: text (model used)
- seed: number
- parameters: object { steps, cfg, resolution }
- timestamp: datetime (creation time)
- metadata: object (additional ComfyUI metadata)

**SequenceFrame:**
- sequenceId: identifier linking frames
- frameNumber: number (1-N)
- prompt: text
- imageId: reference to GeneratedImage
- timestamp: datetime

**PromptTemplate:**
- id: unique identifier
- name: text (user-defined)
- prompt: text
- defaultParameters: object { steps, cfg, model, etc }
- createdAt: datetime

**GalleryFilter:**
- dateRange: object { start, end } (optional)
- keywords: array of text (optional)
- model: text (optional)
- sortBy: enum (timestamp, model, prompt)
- sortOrder: enum (asc, desc)

**Configuration:**
- backendUrl: URL (where backend API is accessible)
- frontendOrigin: URL (where frontend is served)
- comfyuiUrl: URL (ComfyUI server address)
- galleryStoragePath: filesystem path (persistent image storage)
- requiredKeys: array of text (keys that must be present)

**GenerationStatus:**
- requestId: unique identifier
- state: enum (queued, processing, complete, failed)
- progress: number (0-100)
- currentFrame: number (for sequences)
- totalFrames: number (for sequences)
- errorMessage: text (if failed)

### State Transitions

**Single Generation Flow:**
```
Idle → PromptEntry → ValidationPending → RequestSubmitted → 
Queued → Processing → ImageReady → DisplayImage → Idle
```

**Error Path:**
```
Processing → GenerationFailed → ErrorDisplayed → Idle
```

**Sequence Generation Flow:**
```
Idle → StoryEntry → PromptGeneration → PromptsReview → 
PromptsApproved → QueueFrames → ProcessingFrame[1..N] → 
SequenceComplete → DisplaySequence → Idle
```

**Gallery View Flow:**
```
GalleryLoad → DisplayGrid → FilterApplied → UpdatedGrid → 
ThumbnailClick → FullImageView → ReturnToGrid
```

### API Contracts

**Backend Generation API (ComfyUI):**

`POST /prompt`
- Request: { prompt: workflow_json_object }
- Response: { prompt_id: string, number: number }

`GET /history/{prompt_id}`
- Response: { [prompt_id]: { status: object, outputs: object } }

`GET /view?filename={filename}`
- Response: binary image data

`GET /object_info`
- Response: { CheckpointLoaderSimple: { input: { required: { ckpt_name: [array] } } } }

**Scene Producer Agent API:**

`POST /generate-sequence`
- Request: { story: string, frames: number, arc?: string, model: string }
- Response: { prompts: [{ frame: number, prompt: string, description: string }], metadata: object }

**Frontend Internal API:**

`loadGallery(filters?: GalleryFilter) → Promise<GeneratedImage[]>`
- Load images matching filters from storage

`submitGeneration(request: GenerationRequest) → Promise<string>`
- Submit generation request, return request ID

`pollStatus(requestId: string) → Promise<GenerationStatus>`
- Check generation status

`downloadImage(imageUrl: string) → Promise<GeneratedImage>`
- Download and save completed image

`deleteImage(imageId: string) → Promise<void>`
- Remove image from gallery and storage

`savePromptTemplate(template: PromptTemplate) → Promise<string>`
- Save prompt for reuse

`loadPromptTemplates() → Promise<PromptTemplate[]>`
- Load saved prompt templates
