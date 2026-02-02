---
id: STK-FRONTEND
status: implemented
created: 2026-02-01
implemented: 2026-02-02T21:15:00Z
prompt_version: initial
---

# Frontend Technology Stack

## References

### Enables

- [FUN-GEN-REQUEST](../functional/generation-request-flow.md) — React provides reactive UI for generation flow
- [FUN-GALLERY-VIEW](../functional/gallery-view-management.md) — React components for gallery grid and image display
- [FUN-SEQUENCE-GEN](../functional/sequence-generation-workflow.md) — React state management for sequence workflow
- [FUN-BATCH-GEN](../functional/batch-generation-workflow.md) — React components for batch progress and comparison
- [FUN-MODEL-SELECT](../functional/model-selection-interface.md) — React dropdown component for model selection

## Scope

### Included

- Frontend framework and UI library selection
- State management approach
- CSS styling solution
- Build tooling and development server
- HTTP client for API communication
- Routing library for navigation
- Icon library for UI elements
- Date formatting utilities

### Excluded

- Backend framework (separate spec)
- API implementation details (backend responsibility)
- Deployment configuration (infrastructure layer)
- Testing framework (coverage layer)
- Image processing libraries (backend responsibility)

## Technology Stack

### Languages

| Language | Version |
|----------|---------|
| JavaScript (ES2022+) | ECMAScript 2022 |
| HTML5 | Current standard |
| CSS3 | Current standard |

### Frameworks

| Framework | Version |
|-----------|---------|
| React | 18.2+ |
| React Router | 6.20+ |

### Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| Vite | 5.0+ | Build tool and dev server with HMR |
| Axios | 1.6+ | HTTP client for backend API calls |
| Tailwind CSS | 3.4+ | Utility-first CSS framework |
| Lucide React | 0.300+ | Icon library for UI elements |
| date-fns | 3.0+ | Date formatting and manipulation |
| clsx | 2.0+ | Conditional CSS class composition |

### Build Tools

| Tool | Version | Purpose |
|------|---------|---------|
| npm | 10.0+ | Package manager |
| Vite | 5.0+ | Development server with HMR, production bundling |
| PostCSS | 8.4+ | CSS processing for Tailwind |
| Autoprefixer | 10.4+ | CSS vendor prefixing |

## Constraints

| Constraint | Description | Impact |
|------------|-------------|--------|
| WSL2 Ubuntu 22.04+ | Frontend must run on WSL2 with Windows host browser access | Chose standard web technologies, localhost forwarding works natively |
| Single-user local deployment | No multi-user auth, no SSO, no role management | Simplified state management, no auth libraries needed |
| Browser compatibility | Chrome, Firefox, Edge, Safari (modern versions) | Used standard ES2022 features, avoided experimental APIs |
| Coexist with ComfyUI | Frontend cannot use port 8188 | Chose Vite default port 5173 for dev server |
| Fast load time <2s | Minimize bundle size | Chose React over Angular (lighter), Tailwind over custom CSS (tree-shaking) |
| UI responsiveness <100ms | Lightweight state updates | React's virtual DOM and minimal external state library |
| Integration with existing tools | Must work alongside bash scripts | REST API allows both CLI and UI to coexist |
| No TypeScript requirement | Team prefers JavaScript for simplicity | Used plain JavaScript, no compilation overhead |
| Minimal build complexity | Easy setup and configuration | Vite offers zero-config start vs Webpack complexity |

## Acceptance Criteria

Requirements use format: `STK-FRONTEND-[NNN]`

- [x] STK-FRONTEND-001: Project uses React 18.2 or higher
- [x] STK-FRONTEND-002: Project uses Vite 5.0+ as build tool and dev server
- [x] STK-FRONTEND-003: Project uses Tailwind CSS 3.4+ for styling
- [x] STK-FRONTEND-004: Project uses Axios 1.6+ for HTTP requests
- [x] STK-FRONTEND-005: Project uses React Router 6.20+ for navigation
- [x] STK-FRONTEND-006: Project uses Lucide React 0.300+ for icons
- [x] STK-FRONTEND-007: Project uses date-fns 3.0+ for date formatting
- [x] STK-FRONTEND-008: Project uses npm 10.0+ as package manager
- [x] STK-FRONTEND-009: Project written in JavaScript (ES2022+), not TypeScript
- [x] STK-FRONTEND-010: Vite dev server runs on port 5173 (default)
- [x] STK-FRONTEND-011: Frontend serves from WSL2, accessible from Windows browser via localhost:5173
- [x] STK-FRONTEND-012: Vite configured with React plugin (@vitejs/plugin-react)
- [x] STK-FRONTEND-013: Tailwind CSS configured via tailwind.config.js
- [x] STK-FRONTEND-014: PostCSS configured with Tailwind and Autoprefixer
- [x] STK-FRONTEND-015: package.json includes dev script: "vite"
- [x] STK-FRONTEND-016: package.json includes build script: "vite build"
- [x] STK-FRONTEND-017: package.json includes preview script: "vite preview"
- [x] STK-FRONTEND-018: Axios base URL configured to point to backend API (http://localhost:8000)
- [x] STK-FRONTEND-019: React Router configured with routes: /, /gallery, /generate, /sequence, /batch
- [x] STK-FRONTEND-020: Project uses React hooks for state management (useState, useEffect, useContext)
- [x] STK-FRONTEND-021: No external state management library required (Redux, MobX, Zustand)
- [x] STK-FRONTEND-022: Tailwind utility classes used for all styling (no custom CSS files except index.css)
- [x] STK-FRONTEND-023: Lucide React icons imported as components (not font icons)
- [x] STK-FRONTEND-024: date-fns used for all date formatting (no moment.js or dayjs)
- [x] STK-FRONTEND-025: Vite hot module replacement (HMR) functional during development
- [x] STK-FRONTEND-026: Production build generates optimized static files in dist/ directory
- [x] STK-FRONTEND-027: Production build enables code splitting for lazy-loaded routes
- [x] STK-FRONTEND-028: Production build size <500KB (excluding images)
- [x] STK-FRONTEND-029: Frontend compatible with Chrome 90+, Firefox 88+, Edge 90+, Safari 14+
- [x] STK-FRONTEND-030: No jQuery or legacy JavaScript libraries included

---

*Generated with smaqit v0.6.2-beta*
