---
name: smaqit.stack
description: Create stack layer specifications from technology preferences
agent: smaqit.stack
---

# Stack Prompt

This prompt captures technology preferences and constraints for your project. These requirements will be used to generate stack specifications.

## Requirements

### Technology Preferences

**Frontend:**
- Modern JavaScript framework with reactive UI (React, Vue, or Svelte)
- Component-based architecture for reusable UI elements
- Built-in state management or lightweight state library
- TypeScript optional (prefer simpler JavaScript for rapid development)
- Tailwind CSS or similar utility-first CSS framework for styling
- Native browser APIs for file operations (no heavy dependencies)

**Backend:**
- Python 3.12+ (consistency with existing ComfyUI environment)
- Lightweight web framework: Flask or FastAPI
- Async support for concurrent request handling
- WebSocket support for real-time progress updates (optional, can use polling)
- Minimal dependencies (leverage existing PyTorch/ComfyUI environment)

**Storage:**
- Filesystem-based (leverage existing ~/images/outputs/ structure)
- SQLite for metadata indexing (optional, can use JSON files initially)
- No external database server required

**API Layer:**
- RESTful HTTP API for CRUD operations
- JSON for data interchange
- Direct integration with existing ComfyUI HTTP API (localhost:8188)

### Constraints

**Platform:**
- Must run on WSL2 Ubuntu 22.04+ (existing environment)
- Accessible via browser on Windows host (localhost forwarding)
- No Windows-specific dependencies
- Single-user local deployment only (no multi-user authentication)

**Integration:**
- Must coexist with existing ComfyUI setup (port 8188 already used)
- Must use existing model directory structure (~/image-gen/models/)
- Must use existing output directory (~/images/outputs/)
- Must integrate with existing bash generation scripts (backward compatibility)
- Must integrate with scene producer agent (existing tool)

**Performance:**
- Frontend load time <2 seconds
- Gallery rendering <2 seconds for 50 images
- UI responsiveness <100ms
- No blocking operations during image generation

**Simplicity:**
- Minimal build complexity (avoid heavy toolchains)
- Easy to start/stop (single command like serve_comfyui.sh)
- No container orchestration (runs directly on WSL2)
- Minimal configuration files

### Build Tools

**Frontend:**
- Vite for fast development server and building (preferred over Webpack)
- npm or pnpm for package management
- Minimal build step (prefer simple configurations)
- Hot module replacement for development

**Backend:**
- Standard Python packaging (pip requirements.txt)
- No complex build steps (pure Python)
- Virtual environment: reuse ~/.venvs/imggen or create ~/.venvs/frontend

**Development:**
- Single command to start dev environment (e.g., npm run dev + python app.py)
- Live reload for both frontend and backend during development

### Development Environment

**Required:**
- Python 3.12+ (already installed for ComfyUI)
- Node.js 18+ and npm (for frontend tooling)
- ComfyUI server running on port 8188
- Modern web browser (Chrome, Firefox, Edge, Safari)
- Text editor with JavaScript/Python support

**Optional:**
- VS Code with Python and JavaScript extensions
- Browser DevTools for debugging

**Ports:**
- Frontend dev server: 5173 (Vite default) or 3000
- Backend API server: 8000 or 5000 (separate from ComfyUI 8188)
- ComfyUI server: 8188 (existing, must not conflict)

### Dependencies

**Frontend (npm packages):**
- React 18+ or Vue 3+ or Svelte 4+ (choose one)
- Axios or fetch API for HTTP requests
- date-fns or dayjs for date formatting
- Lightweight icon library (lucide-react, heroicons, or feather-icons)
- Tailwind CSS for styling
- React Router or Vue Router for navigation (if multi-page)

**Backend (Python packages):**
- Flask 3.0+ or FastAPI 0.100+ (choose one)
- Requests for ComfyUI API calls
- Pillow for thumbnail generation
- python-multipart for file uploads (if needed)
- aiofiles for async file operations (if using FastAPI)
- flask-cors or fastapi.middleware.cors for CORS support

**Shared:**
- No external database (SQLite or JSON files)
- No Redis or message queue
- No Docker or containerization

### Rationale

**Why Python Backend:**
- Consistency with existing ComfyUI Python environment (avoid Node.js backend)
- Access to Pillow for thumbnail generation (same library used by ComfyUI)
- Can reuse existing ~/.venvs/imggen virtual environment
- Team already familiar with Python from setup scripts

**Why Lightweight Framework (Flask/FastAPI):**
- Minimal boilerplate compared to Django
- Simple REST API for frontend-backend communication
- FastAPI provides automatic OpenAPI docs and async support
- Flask offers simplicity and zero-configuration start

**Why Modern JS Framework (React/Vue/Svelte):**
- Reactive UI updates for real-time progress indicators
- Component reusability (gallery grid, image cards, forms)
- Rich ecosystem for UI components
- Avoid jQuery and vanilla DOM manipulation complexity

**Why Filesystem Storage:**
- Leverage existing directory structure (~/images/outputs/)
- No database setup complexity
- Easy to backup and migrate
- Direct file access for images (no blob storage)

**Why Vite Build Tool:**
- Fastest dev server with HMR
- Minimal configuration required
- Better than Create React App (deprecated) or Webpack (complex)
- Native ES modules support

**Why No Containers:**
- Single-user local deployment doesn't need orchestration
- Simpler troubleshooting and development
- Faster startup (no container overhead)
- Consistent with existing bare-metal ComfyUI setup

**Why REST API (not GraphQL):**
- Simpler for CRUD operations
- No complex schema definitions
- Standard HTTP methods intuitive for team
- Adequate for frontend needs (no over-fetching issues at local scale)

**Why Tailwind CSS:**
- Utility-first prevents CSS bloat
- No need to write custom CSS
- Consistent design system
- Faster prototyping than writing styles manually
