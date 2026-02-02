---
id: FUN-GALLERY-VIEW
status: implemented
created: 2026-02-01
implemented: 2026-02-02T21:15:00Z
prompt_version: initial
---

# Gallery View and Management

## References

### Implements

- [BUS-FRONTEND-UI-011](../business/uc6-frontend-ui.md) — User can view gallery in grid layout
- [BUS-FRONTEND-UI-012](../business/uc6-frontend-ui.md) — User can filter gallery by date range
- [BUS-FRONTEND-UI-013](../business/uc6-frontend-ui.md) — User can search gallery by keywords
- [BUS-FRONTEND-UI-014](../business/uc6-frontend-ui.md) — User can view full-size image with metadata
- [BUS-FRONTEND-UI-026](../business/uc6-frontend-ui.md) — User can delete images with confirmation
- [BUS-FRONTEND-UI-030](../business/uc6-frontend-ui.md) — Gallery displays image count and storage usage

## Scope

### Included

- Grid display of generated images as thumbnails
- Filtering by date range and keyword search
- Full-size image viewing with metadata
- Image deletion with confirmation
- Storage statistics display
- Thumbnail generation and caching

### Excluded

- Image generation workflows (separate spec)
- Image editing or post-processing
- Batch comparison views (separate spec)
- Sequence-specific gallery views (separate spec)

## User Flow

### Overview

User browses previously generated images in a grid layout, applies filters to find specific images, views full details, and manages gallery contents.

### Steps

1. User navigates to Gallery section
2. Frontend loads all images from storage directory
3. Frontend generates thumbnails for images without cached thumbnails
4. Frontend displays grid of thumbnails (most recent first)
5. Frontend calculates and displays total count and storage usage
6. User optionally enters search keywords in search input
7. User optionally selects date range using date picker controls
8. Frontend filters displayed images based on active filters
9. User clicks thumbnail to view full-size image
10. Frontend displays full-size image with complete metadata panel
11. User views/downloads/deletes image or returns to grid
12. Frontend updates grid if image was deleted

### Error Handling

| Condition | Behavior |
|-----------|----------|
| Storage directory not found | Display error: "Gallery directory not found. No images generated yet." |
| Image file corrupt | Skip image, log warning, display remaining images |
| Thumbnail generation fails | Display placeholder thumbnail, log error |
| Date range invalid | Display validation error: "End date must be after start date" |
| No images match filters | Display message: "No images match your filters. Try adjusting your criteria." |
| Delete operation fails | Display error: "Failed to delete image. Check file permissions." + Retry button |

## Data Model

### GalleryImage

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| id | text | Unique identifier | Required, generated from timestamp |
| filepath | text | Absolute path to image file | Required |
| thumbnail | text | Path to thumbnail | Required |
| prompt | text | Generation prompt | Required |
| model | text | Model used | Required |
| seed | number | Seed used | Required |
| parameters | object | Steps, CFG, resolution | Required |
| timestamp | datetime | Creation time | Required |
| filesize | number | Image size in bytes | Required |
| metadata | object | Additional metadata | Optional |

### GalleryFilter

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| keywords | array | Search terms | Optional, applied to prompt text |
| dateStart | datetime | Filter start date | Optional |
| dateEnd | datetime | Filter end date | Optional, must be >= dateStart |
| model | text | Filter by specific model | Optional |
| sortBy | enum | Sort field | Optional, one of: timestamp, model, prompt |
| sortOrder | enum | Sort direction | Optional, one of: asc, desc, default: desc |

### GalleryStatistics

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| totalImages | number | Count of all images | Required, ≥0 |
| filteredImages | number | Count matching filters | Required, ≥0 |
| totalStorage | number | Total size in bytes | Required, ≥0 |
| filteredStorage | number | Size of filtered images | Required, ≥0 |

### Relationships

| From | To | Type | Description |
|------|-----|------|-------------|
| GalleryFilter | GalleryImage | one-to-many | Filter matches multiple images |
| GalleryImage | GalleryStatistics | many-to-one | Images aggregate to statistics |

## API Contract

### loadGallery

**Purpose:** Load images from storage directory with optional filters

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| filters | GalleryFilter | No | Optional filtering criteria |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| images | array | Array of GalleryImage objects |
| statistics | GalleryStatistics | Count and storage totals |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Storage directory missing | Empty array + warning | No images available |
| Permission denied | Error | Cannot read storage directory |

### generateThumbnail

**Purpose:** Create thumbnail for image if not cached

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| imagePath | text | Yes | Path to original image |
| thumbnailPath | text | Yes | Destination for thumbnail |
| maxSize | number | No | Maximum dimension (default: 300px) |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| thumbnailPath | text | Path to generated thumbnail |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Image not found | Error | Original image doesn't exist |
| Image corrupt | Error | Cannot decode image |
| Write permission denied | Error | Cannot write thumbnail |

### deleteImage

**Purpose:** Remove image and associated files from storage

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| imageId | text | Yes | Unique identifier of image to delete |
| confirmationToken | text | Yes | User confirmation token |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| deleted | boolean | Always true on success |
| deletedFiles | array | List of deleted file paths |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Image not found | HTTP 404 | Image ID doesn't exist |
| Missing confirmation | HTTP 400 | Confirmation required for safety |
| Permission denied | HTTP 403 | Cannot delete file |

### getImageMetadata

**Purpose:** Retrieve full metadata for specific image

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| imageId | text | Yes | Unique identifier |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| image | GalleryImage | Complete image data |

**Errors:**

| Condition | Response | Description |
|-----------|----------|-------------|
| Image not found | HTTP 404 | Image ID doesn't exist |

### calculateStatistics

**Purpose:** Compute gallery statistics for current filter state

#### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| images | array | Yes | Array of GalleryImage objects |

#### Response

**Success:**

| Field | Type | Description |
|-------|------|-------------|
| statistics | GalleryStatistics | Computed totals |

## State Transitions

### States

| State | Description | Entry Condition |
|-------|-------------|-----------------|
| Loading | Fetching images from storage | User navigates to gallery |
| DisplayGrid | Showing thumbnail grid | Images loaded successfully |
| FilterApplied | Showing filtered subset | User applied filters |
| ViewingImage | Full-size image display | User clicked thumbnail |
| ConfirmDelete | Awaiting deletion confirmation | User clicked delete button |
| Deleting | Removing image from storage | User confirmed deletion |
| Error | Displaying error message | Load or operation failed |

### Transitions

```
Loading → [Load Success] → DisplayGrid
Loading → [Load Failure] → Error → DisplayGrid (empty)
DisplayGrid → [Apply Filter] → FilterApplied → DisplayGrid
DisplayGrid → [Click Thumbnail] → ViewingImage
ViewingImage → [Back to Grid] → DisplayGrid
ViewingImage → [Delete Click] → ConfirmDelete
ConfirmDelete → [Confirm] → Deleting → DisplayGrid
ConfirmDelete → [Cancel] → ViewingImage
```

| From | Event | To | Guard Condition |
|------|-------|-----|-----------------|
| Loading | Load Success | DisplayGrid | Images loaded |
| Loading | Load Failure | Error | Storage read failed |
| DisplayGrid | Apply Filter | FilterApplied | Valid filter criteria |
| FilterApplied | Filter Change | FilterApplied | New filter criteria |
| FilterApplied | Clear Filter | DisplayGrid | Filter removed |
| DisplayGrid | Thumbnail Click | ViewingImage | Valid image ID |
| ViewingImage | Back Button | DisplayGrid | User navigation |
| ViewingImage | Delete Button | ConfirmDelete | Image deletable |
| ConfirmDelete | Confirm Button | Deleting | User confirmed |
| ConfirmDelete | Cancel Button | ViewingImage | User cancelled |
| Deleting | Delete Success | DisplayGrid | File removed |
| Deleting | Delete Failure | Error | Delete failed |
| Error | Retry Button | Loading | User retry |

## Acceptance Criteria

Requirements use format: `FUN-GALLERY-VIEW-[NNN]`

- [x] FUN-GALLERY-VIEW-001: Frontend loads all images from `~/images/outputs/` directory on gallery page load
- [x] FUN-GALLERY-VIEW-002: Frontend parses metadata from accompanying `.txt` files for each image
- [!] FUN-GALLERY-VIEW-003: Frontend generates 300px thumbnails for images without cached thumbnails
- [!] FUN-GALLERY-VIEW-004: Frontend caches thumbnails in `.thumbnails/` subdirectory
- [x] FUN-GALLERY-VIEW-005: Frontend displays images in grid layout with 4 columns (desktop)
- [x] FUN-GALLERY-VIEW-006: Frontend sorts images by timestamp descending (most recent first) by default
- [x] FUN-GALLERY-VIEW-007: Frontend displays complete gallery (<50 images) within 2 seconds
- [!] FUN-GALLERY-VIEW-008: Frontend implements lazy loading for galleries >50 images
- [x] FUN-GALLERY-VIEW-009: Frontend calculates total image count from loaded images
- [x] FUN-GALLERY-VIEW-010: Frontend calculates total storage size by summing file sizes
- [x] FUN-GALLERY-VIEW-011: Frontend displays statistics in gallery header (e.g., "42 images, 1.2 GB")
- [x] FUN-GALLERY-VIEW-012: Frontend provides keyword search input field
- [x] FUN-GALLERY-VIEW-013: Frontend filters images where prompt contains search keywords (case-insensitive)
- [x] FUN-GALLERY-VIEW-014: Frontend updates grid display within 100ms of filter application
- [x] FUN-GALLERY-VIEW-015: Frontend provides date range picker with start and end date inputs
- [x] FUN-GALLERY-VIEW-016: Frontend filters images where timestamp falls within selected date range
- [x] FUN-GALLERY-VIEW-017: Frontend validates end date is not before start date
- [x] FUN-GALLERY-VIEW-018: Frontend displays "No images match filters" message when filter results empty
- [x] FUN-GALLERY-VIEW-019: Frontend shows filtered count vs total count (e.g., "12 of 42 images")
- [x] FUN-GALLERY-VIEW-020: Frontend expands clicked thumbnail to full-size image view
- [x] FUN-GALLERY-VIEW-021: Frontend displays metadata panel alongside full-size image
- [x] FUN-GALLERY-VIEW-022: Metadata panel includes: prompt, model, seed, steps, CFG, resolution, timestamp
- [x] FUN-GALLERY-VIEW-023: Frontend provides download button that triggers browser download
- [x] FUN-GALLERY-VIEW-024: Frontend provides delete button with warning icon
- [x] FUN-GALLERY-VIEW-025: Frontend displays confirmation dialog when delete button clicked
- [x] FUN-GALLERY-VIEW-026: Confirmation dialog shows image thumbnail and "Are you sure?" message
- [x] FUN-GALLERY-VIEW-027: Frontend deletes image file and metadata file when user confirms
- [x] FUN-GALLERY-VIEW-028: Frontend removes image from gallery grid after successful deletion
- [x] FUN-GALLERY-VIEW-029: Frontend updates statistics after deletion
- [x] FUN-GALLERY-VIEW-030: Frontend provides "Back to Grid" button in full-size view
- [x] FUN-GALLERY-VIEW-031: Frontend handles corrupt images gracefully (skip and log)
- [x] FUN-GALLERY-VIEW-032: Frontend displays placeholder for images with missing thumbnails
- [x] FUN-GALLERY-VIEW-033: Frontend provides "Clear Filters" button when filters active
- [x] FUN-GALLERY-VIEW-034: Frontend resets to full gallery view when filters cleared
- [!] FUN-GALLERY-VIEW-035: Frontend maintains scroll position when returning from full-size view

---

*Generated with smaqit v0.6.2-beta*
