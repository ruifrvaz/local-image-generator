---
id: FUN-CONFIG
status: draft
created: 2026-02-03
prompt_version: user-request
---

# Configuration Management

## References

### Enables

- [BUS-FRONTEND-UI](../business/uc6-frontend-ui.md) — Frontend must connect to backend regardless of deployment environment
- [BUS-SINGLE-IMAGE](../business/uc1-single-image-generation.md) — Generation must work across dev/prod environments
- [BUS-SERVER-MGMT](../business/uc4-server-management.md) — Server configuration must adapt to different environments

## Scope

### Included

- Externalization of environment-specific values (URLs, ports, paths)
- Runtime configuration loading without code modification
- Support for multiple deployment environments (development, production)
- Validation of required configuration values at startup

### Excluded

- Technology choice for configuration mechanism (Stack layer)
- Secret management or encryption (Infrastructure layer)
- Dynamic configuration updates during runtime
- Configuration versioning or migration

## Configuration Model

### Required Configuration Values

| Configuration Key | Type | Description | Example Values |
|-------------------|------|-------------|----------------|
| Backend Base URL | URL | Address where backend API is accessible | `http://localhost:8000`, `http://172.31.243.212:8000` |
| Frontend Origin | URL | Address where frontend is served | `http://localhost:5173`, `http://172.31.243.212:5173` |
| ComfyUI API URL | URL | Address of ComfyUI server | `http://localhost:8188` |
| Gallery Storage Path | Filesystem Path | Directory containing persistent images | `/home/user/images/outputs` |

### Configuration Behavior

**At Application Startup:**

1. System attempts to load configuration from external source
2. System validates that all required configuration keys are present
3. If any required key is missing, system fails to start with clear error message identifying missing keys
4. If all keys present, system uses configuration values for runtime behavior

**During Runtime:**

- Configuration values remain constant (no hot-reload)
- All components use configuration values instead of hardcoded constants
- Configuration values are not exposed in API responses or client-side code (except where necessary for client operation)

## Acceptance Criteria

- [ ] FUN-CONFIG-001: Backend must load backend base URL from configuration source, not hardcoded value
- [ ] FUN-CONFIG-002: Backend must load allowed CORS origins from configuration source, not hardcoded value
- [ ] FUN-CONFIG-003: Backend must load ComfyUI API URL from configuration source, not hardcoded value
- [ ] FUN-CONFIG-004: Backend must load gallery storage path from configuration source, not hardcoded value
- [ ] FUN-CONFIG-005: Frontend must load backend API URL from configuration source, not hardcoded value
- [ ] FUN-CONFIG-006: System must fail to start if required configuration values are missing
- [ ] FUN-CONFIG-007: System must log which configuration source was used at startup
- [ ] FUN-CONFIG-008: Configuration values must be changeable without modifying source code
- [ ] FUN-CONFIG-009: Different environments (dev, prod) must use different configuration values from separate sources
- [ ] FUN-CONFIG-010: Hardcoded URLs/paths in source code must be replaced with configuration references

## Error Handling

| Condition | Behavior |
|-----------|----------|
| Configuration file missing | System fails to start with error: "Configuration file not found at [path]" |
| Required key missing | System fails to start with error: "Missing required configuration: [key]" |
| Invalid URL format | System fails to start with error: "Invalid URL in configuration: [key]=[value]" |
| Invalid path (does not exist) | System logs warning but continues (path may be created later) |

## Notes

This specification defines **what** must be configurable and **how** the system should behave with externalized configuration. The **technology choice** (`.env` files, JSON, YAML, etc.) is deferred to the Stack layer.

The key functional requirement is: **Configuration values must be externalized so the same codebase can run in different environments without modification.**
