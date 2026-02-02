---
name: smaqit.development
description: Build application from specifications
agent: smaqit.development
---

# Development Execution

## Parameters

### Build Options
- Development mode with hot reload (Vite HMR for frontend, Uvicorn --reload for backend)
- Install dependencies automatically via npm and pip
- Generate minimal starter code following specifications
- Focus on core functionality first (generation → gallery → sequence/batch)

### Output Preferences
- Standard logging (not verbose, not quiet)
- Console output for server startup confirmation
- Error messages with stack traces for debugging
- Success confirmations for key operations (install, build, run)

### Environment
- WSL2 Ubuntu 22.04+ (existing environment)
- Development mode (not production build initially)
- Create NEW Python virtual environment at ~/.venvs/frontend-backend (DO NOT reuse imggen to avoid conflicts)
- Node.js 18+ for frontend tooling
- All servers run on localhost (frontend: 5173, backend: 8000, ComfyUI: 8188)
