# Stack Specifications

**Created:** 2026-02-01  
**Type:** Technology stack specifications for frontend UI  
**Status:** Draft (not yet implemented)

## Overview

Stack specifications define the technology choices, versions, libraries, and build tools for implementing the functional requirements. These specs justify technology selections and establish constraints for the development phase.

## Specifications Created

| Spec ID | Title | File | Type | Functional References | Acceptance Criteria |
|---------|-------|------|------|----------------------|---------------------|
| STK-BASE-PYTHON | Base Python Environment | `base-python-stack.md` | Foundation | Multiple | 15 criteria |
| STK-FRONTEND | Frontend Technology Stack | `frontend-stack.md` | Foundation | FUN-GEN-REQUEST, FUN-GALLERY-VIEW, FUN-SEQUENCE-GEN, FUN-BATCH-GEN, FUN-MODEL-SELECT | 30 criteria |
| STK-BACKEND | Backend API Technology Stack | `backend-api-stack.md` | Feature | FUN-GEN-REQUEST, FUN-GALLERY-VIEW, FUN-SEQUENCE-GEN, FUN-BATCH-GEN, FUN-MODEL-SELECT | 30 criteria |
| STK-INTEGRATION | Integration Layer Stack | `integration-layer-stack.md` | Feature | Multiple functional specs | 35 criteria |
| STK-CONFIG | Configuration Management Stack | `configuration-stack.md` | Feature | FUN-CONFIG | 18 criteria |

**Total:** 5 stack specifications, 128 acceptance criteria (all testable)

## Specification Types

### Foundation Specs (Enables)
Serve multiple functional requirements:
- **STK-BASE-PYTHON** → Enables all Python-based backend components
- **STK-FRONTEND** → Enables all frontend UI functional requirements

### Feature Specs (Implements)
Technology choices for specific integrations:
- **STK-BACKEND** → Implements backend API for functional workflows
- **STK-INTEGRATION** → Implements communication between layers

## Technology Decisions Summary

### Frontend Stack
- **Framework:** React 18.2+ (component-based reactive UI)
- **Build Tool:** Vite 5.0+ (fast HMR, minimal config)
- **Styling:** Tailwind CSS 3.4+ (utility-first, tree-shakable)
- **HTTP Client:** Axios 1.6+ (promise-based API calls)
- **Routing:** React Router 6.20+ (declarative navigation)
- **Icons:** Lucide React 0.300+ (tree-shakable icon components)
- **Date Utilities:** date-fns 3.0+ (lightweight date formatting)
- **State Management:** React hooks (no external library needed)
- **Language:** JavaScript ES2022+ (no TypeScript)

### Backend Stack
- **Framework:** FastAPI 0.109+ (async support, auto docs)
- **Server:** Uvicorn 0.27+ (ASGI server)
- **HTTP Client:** requests 2.31+ (ComfyUI integration)
- **Image Processing:** Pillow 10.2+ (thumbnail generation)
- **File I/O:** aiofiles 23.2+ (async file operations)
- **Validation:** Pydantic 2.5+ (included with FastAPI)
- **Language:** Python 3.12.3+ (consistency with ComfyUI)

### Integration Stack
- **Frontend Port:** 5173 (Vite default)
- **Backend Port:** 8000 (separate from ComfyUI)
- **ComfyUI Port:** 8188 (existing, unchanged)
- **CORS:** FastAPI middleware (browser security)
- **Communication:** REST API with JSON (frontend ↔ backend)
- **File Storage:** Filesystem-based (~/images/outputs/)
- **Scene Producer:** Subprocess invocation or HTTP (backend ↔ agent)

## Key Technology Rationale

### Why React over Vue/Svelte?
- Larger ecosystem and community
- Familiar to most developers
- Excellent documentation
- React Router mature and well-supported
- Component reusability for gallery/forms

### Why FastAPI over Flask?
- Async support for concurrent requests
- Automatic OpenAPI documentation
- Pydantic validation built-in
- Modern Python 3.12+ features
- Better performance for I/O-bound operations

### Why Vite over Webpack/CRA?
- 10-100x faster dev server startup
- Instant HMR (<100ms)
- Minimal configuration required
- Native ES modules support
- Create React App deprecated

### Why Tailwind CSS over custom CSS?
- Utility-first prevents CSS bloat
- Automatic tree-shaking removes unused classes
- Consistent design system
- Faster prototyping than writing styles manually
- No CSS naming conflicts

### Why Filesystem over Database?
- Leverage existing ~/images/outputs/ structure
- No database setup complexity
- Easy to backup and migrate (just copy files)
- Direct file access for images (no blob storage)
- Consistent with existing bash script workflow

### Why No TypeScript?
- Team preference for JavaScript simplicity
- Faster development iteration
- No compilation overhead
- Adequate for single-user local project
- PropTypes or JSDoc for critical type checking

## Requirements Traceability

Each acceptance criterion uses format: `STK-[CONCEPT]-[NNN]`

| Concept | Criteria Count | Examples |
|---------|----------------|----------|
| BASE-PYTHON | 15 | STK-BASE-PYTHON-001 to STK-BASE-PYTHON-015 |
| FRONTEND | 30 | STK-FRONTEND-001 to STK-FRONTEND-030 |
| BACKEND | 30 | STK-BACKEND-001 to STK-BACKEND-030 |
| INTEGRATION | 35 | STK-INTEGRATION-001 to STK-INTEGRATION-035 |

## Dependencies

### Upstream (Functional Layer)
All specifications enable or implement functional requirements from:
- `../functional/generation-request-flow.md`
- `../functional/gallery-view-management.md`
- `../functional/sequence-generation-workflow.md`
- `../functional/batch-generation-workflow.md`
- `../functional/model-selection-interface.md`

### Downstream (Implementation)
Stack specs will inform:
- Development phase implementation
- Package.json and requirements.txt files
- Build configuration (vite.config.js, tailwind.config.js)
- Server startup scripts

## Constraints Captured

### Platform Constraints
- WSL2 Ubuntu 22.04+ (existing environment)
- Windows 11 host with browser access
- Python 3.12.3+ (consistency with ComfyUI)
- Node.js 18+ (for Vite and npm)

### Integration Constraints
- Coexist with ComfyUI (port 8188 reserved)
- Integrate with existing bash scripts (backward compatibility)
- Integrate with scene producer agent (existing tool)
- Use existing model directory structure
- Use existing output directory structure

### Performance Constraints
- Frontend load time <2 seconds
- Gallery rendering <2 seconds for 50 images
- UI responsiveness <100ms
- Production bundle size <500KB

### Simplicity Constraints
- No TypeScript (team preference)
- No external database (filesystem only)
- No containers (bare-metal deployment)
- No complex build tools (Vite simplicity)
- Minimal configuration files

## Next Steps

**Immediate:**
- All stack specs for frontend UI complete ✅
- Ready for development phase
- No blocking issues or conflicts

**Recommended Next Phase:**
Create infrastructure specifications with `/smaqit.infrastructure` to define:
- Server startup scripts (serve_frontend.sh, serve_backend.sh)
- Development environment setup
- Directory structure
- Logging configuration
- Monitoring integration

**OR proceed directly to implementation:**
Use `/smaqit.development` to build the frontend and backend based on these stack specifications.

## Validation Status

All specifications validated against completion criteria:
- ✅ All template sections filled
- ✅ All upstream references valid and accessible
- ✅ All acceptance criteria testable
- ✅ Scope boundaries explicitly stated
- ✅ Technology choices justified with rationale
- ✅ Requirement IDs follow format: `STK-[CONCEPT]-[NNN]`
- ✅ Foundation vs feature distinction clear
- ✅ Language and framework versions specified
- ✅ No implementation details (HOW to configure)

## Files Created

- `specs/stack/base-python-stack.md` - NEW (2026-02-01)
- `specs/stack/frontend-stack.md` - NEW (2026-02-01)
- `specs/stack/backend-api-stack.md` - NEW (2026-02-01)
- `specs/stack/integration-layer-stack.md` - NEW (2026-02-01)
- `specs/stack/README.md` - This file

## Prompt File

Requirements captured in:
- `.github/prompts/smaqit.stack.prompt.md` - Populated with technology preferences, constraints, build tools, development environment, dependencies, and rationale
