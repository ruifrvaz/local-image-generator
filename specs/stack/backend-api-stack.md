---
id: STK-BACKEND
status: implemented
created: 2026-02-01
implemented: 2026-02-02T21:15:00Z
prompt_version: initial
---

# Backend API Technology Stack

## References

### Foundation Reference

- [STK-BASE-PYTHON](./base-python-stack.md) — Shared Python environment and dependencies

### Enables

- [FUN-GEN-REQUEST](../functional/generation-request-flow.md) — FastAPI provides REST endpoints for generation requests
- [FUN-GALLERY-VIEW](../functional/gallery-view-management.md) — FastAPI serves gallery data and file operations
- [FUN-SEQUENCE-GEN](../functional/sequence-generation-workflow.md) — FastAPI orchestrates sequence generation workflow
- [FUN-BATCH-GEN](../functional/batch-generation-workflow.md) — FastAPI manages batch generation queue
- [FUN-MODEL-SELECT](../functional/model-selection-interface.md) — FastAPI proxies ComfyUI model discovery

## Scope

### Included

- Backend web framework selection
- REST API implementation framework
- CORS middleware for browser requests
- HTTP client for ComfyUI API integration
- Image processing library for thumbnails
- Async file operations support
- JSON request/response handling

### Excluded

- Frontend framework (separate spec)
- Database or ORM (using filesystem)
- Authentication/authorization (single-user local)
- Containerization (bare-metal deployment)
- Testing framework (coverage layer)
- Deployment configuration (infrastructure layer)

## Technology Stack

### Languages

| Language | Version |
|----------|---------|
| Python | 3.12+ |

### Frameworks

| Framework | Version |
|-----------|---------|
| FastAPI | 0.109+ |
| Uvicorn | 0.27+ (ASGI server) |

### Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| requests | 2.31+ | HTTP client for ComfyUI API calls |
| Pillow | 10.2+ | Thumbnail generation from images |
| aiofiles | 23.2+ | Async file I/O operations |
| python-multipart | 0.0.9+ | File upload support (if needed) |
| pydantic | 2.5+ | Request/response validation (included with FastAPI) |

### Build Tools

| Tool | Version | Purpose |
|------|---------|---------|
| pip | 23.0+ | Package manager |
| requirements.txt | N/A | Dependency specification |

## Constraints

| Constraint | Description | Impact |
|------------|-------------|--------|
| Python 3.12+ consistency | Match existing ComfyUI environment | Reuse ~/.venvs/imggen or create separate venv |
| WSL2 Ubuntu 22.04+ | Backend runs on WSL2 | Standard Python deployment, no Windows-specific code |
| Coexist with ComfyUI | Backend cannot use port 8188 | Chose port 8000 for backend API |
| Integrate with ComfyUI | Must call ComfyUI HTTP API | Used requests library for synchronous calls |
| Single-user local | No auth, no multi-tenancy | Simplified security, no JWT or session management |
| Filesystem storage | No database server | Direct file operations via aiofiles |
| Pillow for thumbnails | Same library as ComfyUI | Reuse existing dependency |
| Async support | Non-blocking I/O for gallery operations | FastAPI with async endpoints |
| Minimal dependencies | Avoid heavy frameworks | FastAPI over Django, requests over aiohttp |
| Easy start/stop | Single command like serve_comfyui.sh | Uvicorn command-line server |

## Acceptance Criteria

Requirements use format: `STK-BACKEND-[NNN]`

- [x] STK-BACKEND-001: Project uses Python 3.12 or higher
- [x] STK-BACKEND-002: Project uses FastAPI 0.109+ as web framework
- [x] STK-BACKEND-003: Project uses Uvicorn 0.27+ as ASGI server
- [x] STK-BACKEND-004: Project uses requests 2.31+ for ComfyUI API calls
- [x] STK-BACKEND-005: Project uses Pillow 10.2+ for thumbnail generation
- [x] STK-BACKEND-006: Project uses aiofiles 23.2+ for async file operations
- [x] STK-BACKEND-007: Backend API runs on port 8000 (not 8188)
- [x] STK-BACKEND-008: Backend accessible from frontend at http://localhost:8000
- [x] STK-BACKEND-009: FastAPI CORS middleware configured to allow frontend origin (localhost:5173)
- [x] STK-BACKEND-010: FastAPI automatic OpenAPI docs available at /docs endpoint
- [x] STK-BACKEND-011: All API routes use /api prefix (e.g., /api/generate, /api/gallery)
- [x] STK-BACKEND-012: Pydantic models defined for all request/response schemas
- [x] STK-BACKEND-013: Async endpoints used for file I/O operations (gallery loading, thumbnail generation)
- [x] STK-BACKEND-014: Synchronous requests library used for ComfyUI HTTP calls (simple proxy)
- [x] STK-BACKEND-015: Backend integrates with ComfyUI at http://localhost:8188
- [x] STK-BACKEND-016: Backend creates thumbnails at 300px max dimension
- [x] STK-BACKEND-017: Backend stores thumbnails in .thumbnails/ subdirectory alongside images
- [x] STK-BACKEND-018: Backend uses aiofiles for reading/writing metadata JSON files
- [x] STK-BACKEND-019: Backend returns JSON responses for all API endpoints
- [x] STK-BACKEND-020: Backend handles exceptions with appropriate HTTP status codes
- [x] STK-BACKEND-021: Backend logs errors to stdout (compatible with systemd/logging)
- [x] STK-BACKEND-022: Backend starts with command: uvicorn main:app --host 0.0.0.0 --port 8000
- [x] STK-BACKEND-023: Backend supports hot reload during development: uvicorn main:app --reload
- [x] STK-BACKEND-024: No authentication middleware (single-user local deployment)
- [x] STK-BACKEND-025: No database connection or ORM (filesystem-based storage)
- [x] STK-BACKEND-026: Backend Python code follows PEP 8 style guidelines
- [x] STK-BACKEND-027: Backend dependencies specified in requirements.txt
- [x] STK-BACKEND-028: Backend runs in virtual environment (isolated from system Python)
- [x] STK-BACKEND-029: Backend gracefully handles ComfyUI server unavailable (returns 503)
- [x] STK-BACKEND-030: Backend provides health check endpoint: GET /api/health

---

*Generated with smaqit v0.6.2-beta*
