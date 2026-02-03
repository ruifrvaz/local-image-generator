---
id: STK-CONFIG
status: draft
created: 2026-02-03
prompt_version: user-request
---

# Configuration Management Stack

## References

### Foundation Reference

- [STK-BASE-PYTHON](./base-python-stack.md) — Python environment for backend configuration loading
- [STK-FRONTEND](./frontend-stack.md) — Vite build system for frontend configuration

### Implements

- [FUN-CONFIG](../functional/configuration-management.md) — Externalized configuration for environment-specific values

## Scope

### Included

- Backend configuration file format and loading mechanism
- Frontend configuration file format and loading mechanism
- Environment variable naming conventions
- Configuration validation libraries
- Default value handling
- Error messaging for missing configuration

### Excluded

- Secret encryption or key management (infrastructure layer)
- Configuration hot-reload during runtime
- Configuration version control strategy
- Deployment-specific configuration distribution

## Technology Stack

### Languages

| Language | Version |
|----------|---------|
| Python | 3.12+ |
| JavaScript (ES2022+) | ECMAScript 2022 |

### Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| python-dotenv | 1.0.0+ | Load `.env` files in Python backend |
| pydantic-settings | 2.0.0+ | Validate and type-safe configuration in Python |

### Build Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Vite | 5.0+ | Frontend build with environment variable injection |

## Configuration Approach

### Backend Configuration

**File:** `.env` (root directory, not committed to git)

**Format:**
```
# Backend API configuration
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000

# Frontend CORS origins (comma-separated)
CORS_ORIGINS=http://localhost:5173,http://172.31.243.212:5173

# ComfyUI integration
COMFYUI_API_URL=http://localhost:8188

# Storage paths
GALLERY_STORAGE_PATH=/home/user/images/outputs
```

**Loading mechanism:**
- Use `pydantic-settings` `BaseSettings` class
- Automatically loads from `.env` file
- Validates types and required fields at import time
- Provides clear error messages for missing/invalid values

**Example implementation pattern:**
```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', env_file_encoding='utf-8')
    
    backend_host: str = "0.0.0.0"
    backend_port: int = 8000
    cors_origins: str
    comfyui_api_url: str
    gallery_storage_path: str

settings = Settings()  # Fails if required fields missing
```

### Frontend Configuration

**File:** `.env` or `.env.local` (root directory, not committed to git)

**Format:**
```
# Vite requires VITE_ prefix for client-side exposure
VITE_API_BASE_URL=http://172.31.243.212:8000
```

**Loading mechanism:**
- Vite automatically loads `.env` files
- Only variables prefixed with `VITE_` are exposed to client code
- Access via `import.meta.env.VITE_API_BASE_URL`
- Build-time substitution (no runtime overhead)

**Example implementation pattern:**
```javascript
const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';

if (!import.meta.env.VITE_API_BASE_URL) {
  console.warn('VITE_API_BASE_URL not set, using default');
}
```

### Environment File Management

**Development:**
- `.env` file in project root
- Contains localhost URLs for local development
- Included in `.gitignore`

**Production/Alternative environments:**
- `.env.production` or `.env.local` for environment-specific overrides
- Deployed separately from codebase
- Not committed to version control

**Example `.env.example` (committed to git):**
```
# Backend configuration
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
CORS_ORIGINS=http://localhost:5173
COMFYUI_API_URL=http://localhost:8188
GALLERY_STORAGE_PATH=/home/user/images/outputs

# Frontend configuration
VITE_API_BASE_URL=http://localhost:8000
```

## Constraints

| Constraint | Description | Impact |
|------------|-------------|--------|
| WSL2 IP address variability | WSL2 assigns dynamic IP addresses on Windows host restart | Requires updating IP in `.env` file when IP changes; localhost forwarding preferred |
| Single-user deployment | No multi-tenancy or user-specific configuration | Simplified configuration model with single `.env` file |
| Existing Python environment | Backend already uses Python 3.12 with PyTorch | Use Python-native configuration libraries (python-dotenv, pydantic-settings) |
| Vite build system | Frontend uses Vite for development and building | Leverage Vite's built-in `.env` support with `VITE_` prefix convention |
| No secret management | Local deployment without sensitive credentials | Simple file-based configuration sufficient; no need for vault or encryption |

## Acceptance Criteria

- [ ] STK-CONFIG-001: Backend uses `.env` file in project root for configuration loading
- [ ] STK-CONFIG-002: Backend uses `pydantic-settings` for type-safe configuration validation
- [ ] STK-CONFIG-003: Backend configuration class defines all required fields (host, port, CORS origins, ComfyUI URL, storage path)
- [ ] STK-CONFIG-004: Backend fails to start with clear error message if required configuration missing
- [ ] STK-CONFIG-005: Frontend uses `.env` file with `VITE_` prefix for configuration variables
- [ ] STK-CONFIG-006: Frontend accesses configuration via `import.meta.env.VITE_*` syntax
- [ ] STK-CONFIG-007: `.env` file is listed in `.gitignore` to prevent accidental commit
- [ ] STK-CONFIG-008: `.env.example` file is committed to repository showing required configuration keys
- [ ] STK-CONFIG-009: Backend logs loaded configuration source (file path) at startup
- [ ] STK-CONFIG-010: Frontend provides fallback default for `VITE_API_BASE_URL` if not set
- [ ] STK-CONFIG-011: CORS origins configuration accepts comma-separated list of URLs
- [ ] STK-CONFIG-012: Configuration values replace all hardcoded URLs in `backend/main.py`
- [ ] STK-CONFIG-013: Configuration values replace all hardcoded URLs in `backend/app/services/comfyui.py`
- [ ] STK-CONFIG-014: Configuration values replace all hardcoded URLs in `backend/app/api/gallery.py`
- [ ] STK-CONFIG-015: Configuration values replace all hardcoded URLs in frontend components (GenerationForm, Gallery, ImageModal, GalleryPage)
- [ ] STK-CONFIG-016: Documentation explains how to update `.env` for different environments
- [ ] STK-CONFIG-017: `python-dotenv` version 1.0.0+ added to `backend/requirements.txt`
- [ ] STK-CONFIG-018: `pydantic-settings` version 2.0.0+ added to `backend/requirements.txt`

---

*Generated with smaqit v0.6.2-beta*
