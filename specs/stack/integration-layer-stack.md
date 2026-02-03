---
id: STK-INTEGRATION
status: implemented
created: 2026-02-01
implemented: 2026-02-02T21:15:00Z
updated: 2026-02-02
prompt_version: initial
---

# Integration Layer Stack

## References

### Foundation Reference

- [STK-FRONTEND](./frontend-stack.md) — Frontend technologies
- [STK-BACKEND](./backend-api-stack.md) — Backend technologies
- [STK-BASE-PYTHON](./base-python-stack.md) — Python runtime

### Enables

- [FUN-GEN-REQUEST](../functional/generation-request-flow.md) — Frontend-backend-ComfyUI integration for generation
- [FUN-GALLERY-VIEW](../functional/gallery-view-management.md) — Frontend-backend file system integration
- [FUN-SEQUENCE-GEN](../functional/sequence-generation-workflow.md) — Backend-agent integration for sequences
- [FUN-BATCH-GEN](../functional/batch-generation-workflow.md) — Backend queue management
- [FUN-MODEL-SELECT](../functional/model-selection-interface.md) — Backend-ComfyUI model discovery integration

## Scope

### Included

- Frontend-to-backend communication protocol
- Backend-to-ComfyUI integration approach
- Backend-to-scene-producer-agent integration
- File system access patterns
- CORS configuration
- Port allocation strategy
- Development workflow (concurrent frontend + backend)

### Excluded

- Specific API endpoint implementations (backend responsibility)
- React component implementations (frontend responsibility)
- ComfyUI server configuration (existing infrastructure)
- Production deployment (infrastructure layer)

## Technology Stack

### Languages

N/A (integration concerns, not language-specific)

### Frameworks

N/A (uses frameworks from STK-FRONTEND and STK-BACKEND)

### Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| Axios (Frontend) | 1.6+ | HTTP client for backend API calls |
| requests (Backend) | 2.31+ | HTTP client for ComfyUI API calls |
| fastapi.middleware.cors (Backend) | Built-in | CORS support for browser requests |

### Build Tools

| Tool | Version | Purpose |
|------|---------|---------|
| concurrently (optional) | 8.0+ | Run frontend + backend dev servers simultaneously |
| npm scripts | N/A | Orchestrate dev workflow |

## Constraints

| Constraint | Description | Impact |
|------------|-------------|--------|
| Port allocation | Frontend: 5173, Backend: 8000, ComfyUI: 8188 | Clear separation, no conflicts |
| WSL2 localhost forwarding | All ports accessible from Windows browser | Backend/frontend bind to 0.0.0.0; Windows forwards localhost:N → WSL:N automatically |
| Windows host browser | User accesses UI from Windows, not WSL terminal browser | All services (frontend 5173, backend 8000, ComfyUI 8188) bind to 0.0.0.0 for Windows accessibility |
| CORS requirement | Browser security requires CORS headers | Backend must configure CORS middleware |
| Existing ComfyUI API | Must use ComfyUI HTTP API as-is | Backend proxies requests, no modifications |
| Existing scene producer | Agent accessible as CLI tool | Backend invokes via subprocess or HTTP |
| Filesystem access | Backend accesses ~/images/outputs/ directly | No database, direct file operations |
| Development workflow | Developer needs both servers running | Use npm scripts or concurrently |

## Acceptance Criteria

Requirements use format: `STK-INTEGRATION-[NNN]`

**Port Configuration:**
- [x] STK-INTEGRATION-001: Frontend dev server runs on port 5173
- [x] STK-INTEGRATION-002: Backend API server runs on port 8000
- [x] STK-INTEGRATION-003: ComfyUI server runs on port 8188 (existing)
- [x] STK-INTEGRATION-004: All three servers can run concurrently without conflicts

**CORS Configuration:**
- [x] STK-INTEGRATION-005: Backend CORS middleware allows origin: http://localhost:5173
- [x] STK-INTEGRATION-006: Backend CORS allows methods: GET, POST, PUT, DELETE, OPTIONS
- [x] STK-INTEGRATION-007: Backend CORS allows headers: Content-Type, Authorization
- [x] STK-INTEGRATION-008: Backend CORS allows credentials: true

**Frontend-Backend Integration:**
- [x] STK-INTEGRATION-009: Frontend Axios base URL configured to http://localhost:8000
- [x] STK-INTEGRATION-010: Frontend sends JSON request bodies with Content-Type: application/json
- [x] STK-INTEGRATION-011: Frontend handles backend error responses (4xx, 5xx) gracefully
- [x] STK-INTEGRATION-012: Frontend polls backend endpoints at 500ms intervals during generation
- [x] STK-INTEGRATION-013: Frontend cancels polling on component unmount or navigation

**Backend-ComfyUI Integration:**
- [x] STK-INTEGRATION-014: Backend connects to ComfyUI at http://localhost:8188
- [x] STK-INTEGRATION-015: Backend proxies /prompt requests to ComfyUI with workflow JSON
- [x] STK-INTEGRATION-016: Backend polls ComfyUI /history/{prompt_id} for status
- [x] STK-INTEGRATION-017: Backend downloads images from ComfyUI /view?filename={name}
- [x] STK-INTEGRATION-018: Backend queries ComfyUI /object_info for model discovery
- [x] STK-INTEGRATION-019: Backend handles ComfyUI unavailable with HTTP 503 to frontend

**Backend-Agent Integration:**
- [x] STK-INTEGRATION-020: Backend invokes scene producer agent (subprocess or HTTP)
- [x] STK-INTEGRATION-021: Backend passes story description, frame count, model to agent
- [x] STK-INTEGRATION-022: Backend receives JSON array of prompts from agent
- [x] STK-INTEGRATION-023: Backend handles agent failure gracefully (error to frontend)

**File System Integration:**
- [x] STK-INTEGRATION-024: Backend reads images from ~/images/outputs/ directory
- [x] STK-INTEGRATION-025: Backend writes generated images to timestamped subdirectories
- [x] STK-INTEGRATION-026: Backend generates thumbnails in .thumbnails/ subdirectories
- [x] STK-INTEGRATION-027: Backend reads/writes metadata from .txt or .json files
- [x] STK-INTEGRATION-028: Backend uses async file operations (aiofiles) for non-blocking I/O
- [x] STK-INTEGRATION-029: Backend handles missing directories by creating them

**Development Workflow:**
- [x] STK-INTEGRATION-030: Developer can start frontend with: npm run dev
- [x] STK-INTEGRATION-031: Developer can start backend with: uvicorn main:app --reload
- [x] STK-INTEGRATION-032: Optional: npm script "dev:all" starts both frontend and backend
- [x] STK-INTEGRATION-033: Frontend hot reload works during development (Vite HMR)
- [x] STK-INTEGRATION-034: Backend hot reload works during development (Uvicorn --reload)
- [x] STK-INTEGRATION-035: ComfyUI server must be started separately before frontend/backend

**WSL Networking:**
- [x] STK-INTEGRATION-036: Frontend binds to 0.0.0.0 (accessible from Windows)
- [x] STK-INTEGRATION-037: Backend binds to 0.0.0.0 (accessible from Windows)
- [x] STK-INTEGRATION-038: All services accessible via localhost from Windows browser

---

*Generated with smaqit v0.6.2-beta*
