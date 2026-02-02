---
id: STK-BASE-PYTHON
status: implemented
created: 2026-02-01
implemented: 2026-02-02T21:15:00Z
prompt_version: initial
---

# Base Python Environment

## References

### Enables

- [STK-BACKEND](./backend-api-stack.md) — Backend API requires Python runtime
- [FUN-GEN-REQUEST](../functional/generation-request-flow.md) — Generation orchestration requires Python
- [FUN-GALLERY-VIEW](../functional/gallery-view-management.md) — Gallery operations require Python
- [FUN-SEQUENCE-GEN](../functional/sequence-generation-workflow.md) — Sequence workflow requires Python
- [FUN-BATCH-GEN](../functional/batch-generation-workflow.md) — Batch management requires Python

### Justification

This is a foundation spec serving multiple functional requirements. Backend API, generation orchestration, and file operations all require a shared Python runtime environment.

## Scope

### Included

- Python version specification
- Virtual environment configuration
- Package management approach
- Shared Python dependencies across backend components
- Integration with existing ComfyUI Python environment

### Excluded

- Frontend JavaScript environment (separate spec)
- Specific backend framework (covered in STK-BACKEND)
- Testing framework (coverage layer)
- Deployment configuration (infrastructure layer)

## Technology Stack

### Languages

| Language | Version |
|----------|---------|
| Python | 3.12.3+ |

### Frameworks

No frameworks at this foundation layer (frameworks specified in feature specs).

### Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| pip | 23.0+ | Package installer |
| setuptools | 69.0+ | Package building utilities |
| wheel | 0.42+ | Binary package format |

### Build Tools

| Tool | Version | Purpose |
|------|---------|---------|
| venv | Built-in | Virtual environment creation |
| pip | 23.0+ | Dependency installation |

## Constraints

| Constraint | Description | Impact |
|------------|-------------|--------|
| Python 3.12.3 consistency | Match existing ComfyUI environment in ~/.venvs/imggen | Use same Python version for compatibility |
| WSL2 Ubuntu 22.04+ | Must run on existing platform | Standard Python installation from apt |
| Virtual environment isolation | Separate from system Python AND from imggen | Use venv module for ~/.venvs/frontend-backend (dedicated) |
| Coexist with ComfyUI | Must NOT pollute ~/.venvs/imggen | Create separate venv to avoid dependency conflicts |
| Minimal system dependencies | Avoid requiring additional apt packages | Use pure Python packages where possible |
| No conda/anaconda | Avoid heavyweight environment managers | Use built-in venv module |

## Acceptance Criteria

Requirements use format: `STK-BASE-PYTHON-[NNN]`

- [x] STK-BASE-PYTHON-001: Python 3.12.3 or higher installed on system
- [x] STK-BASE-PYTHON-002: Python executable available at /usr/bin/python3
- [x] STK-BASE-PYTHON-003: Virtual environment created for frontend backend at ~/.venvs/frontend-backend (separate from imggen)
- [x] STK-BASE-PYTHON-004: Virtual environment activated before running backend server
- [x] STK-BASE-PYTHON-005: pip 23.0+ installed in virtual environment
- [x] STK-BASE-PYTHON-006: setuptools 69.0+ installed in virtual environment
- [x] STK-BASE-PYTHON-007: wheel 0.42+ installed in virtual environment
- [x] STK-BASE-PYTHON-008: Virtual environment isolated from system Python packages AND from ~/.venvs/imggen
- [x] STK-BASE-PYTHON-009: Python version matches existing ComfyUI environment (3.12.3+)
- [x] STK-BASE-PYTHON-010: No conda or anaconda dependencies required
- [x] STK-BASE-PYTHON-011: requirements.txt format used for dependency specification
- [x] STK-BASE-PYTHON-012: All Python dependencies installable via pip
- [x] STK-BASE-PYTHON-013: Virtual environment reproducible on fresh WSL2 Ubuntu install
- [x] STK-BASE-PYTHON-014: No Windows-specific Python packages required
- [x] STK-BASE-PYTHON-015: Python environment compatible with existing ComfyUI setup (can coexist)

---

*Generated with smaqit v0.6.2-beta*
