# Handover: Development → Stack (WSL Networking Issue)

**Date:** 2026-02-02  
**From:** Development Agent  
**To:** Stack Agent  
**Priority:** Medium  
**Type:** Specification Update

---

## Issue Summary

During development phase testing, discovered that backend API is inaccessible from Windows host browser when WSL backend binds to `127.0.0.1` instead of `0.0.0.0`.

**Error observed:**
```
ERR_CONNECTION_REFUSED on localhost:8000/api/models
```

**Root cause:**
- Frontend (Vite) binds to `0.0.0.0` → accessible from Windows
- Backend (Uvicorn) must bind to `0.0.0.0` → accessible from Windows
- Windows localhost port forwarding only works when WSL services bind to all interfaces

---

## Current State

### Implementation
`serve_backend.sh` already specifies:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Implementation is **correct** per existing spec STK-BACKEND-022.

### Specifications
Stack specs exist but **lack explicit WSL networking constraints**:

**Files needing updates:**
1. `specs/stack/backend-api-stack.md`
2. `specs/stack/integration-layer-stack.md`
3. `specs/stack/frontend-stack.md` (already mentions WSL in STK-FRONTEND-011)

---

## Requested Changes

### 1. Update `specs/stack/backend-api-stack.md`

**Location:** Constraints table

**Add constraint:**
```markdown
| WSL2 networking | Windows host browser must reach WSL backend | Uvicorn binds to 0.0.0.0 (all interfaces), not 127.0.0.1 (localhost only) |
```

**Clarify existing constraint:**
```markdown
| WSL2 Ubuntu 22.04+ | Backend runs on WSL2, accessed from Windows browser | Standard Python deployment, bind to 0.0.0.0 for Windows localhost forwarding |
```

**Verify acceptance criterion STK-BACKEND-022:**
```markdown
- [x] STK-BACKEND-022: Backend starts with command: uvicorn main:app --host 0.0.0.0 --port 8000
```
✅ Already correct, just needs emphasis on **why** `--host 0.0.0.0` is required.

---

### 2. Update `specs/stack/integration-layer-stack.md`

**Location:** Constraints table

**Update existing constraint:**
```markdown
| WSL2 localhost forwarding | All ports accessible from Windows browser | Backend/frontend bind to 0.0.0.0; Windows forwards localhost:N → WSL:N automatically |
```

**Add new constraint:**
```markdown
| Windows host browser | User accesses UI from Windows, not WSL terminal browser | All services (frontend 5173, backend 8000, ComfyUI 8188) bind to 0.0.0.0 for Windows accessibility |
```

**Add acceptance criteria:**
```markdown
**WSL Networking:**
- [x] STK-INTEGRATION-036: Frontend binds to 0.0.0.0 (accessible from Windows)
- [x] STK-INTEGRATION-037: Backend binds to 0.0.0.0 (accessible from Windows)
- [x] STK-INTEGRATION-038: All services accessible via localhost from Windows browser
```

---

### 3. Cross-reference existing frontend spec

**File:** `specs/stack/frontend-stack.md`

**Verify existing criterion:**
```markdown
- [x] STK-FRONTEND-011: Frontend serves from WSL2, accessible from Windows browser via localhost:5173
```

✅ Already documented. Ensure consistency across all stack specs.

---

## Rationale

### Why This Matters
- **Business impact:** User cannot use application if backend unreachable
- **Architecture assumption:** Windows host browser is primary access method
- **WSL-specific behavior:** Localhost forwarding requires `0.0.0.0` binding
- **Documentation gap:** Constraint exists in implementation but not explicitly in specs

### Why Stack Layer (not Infrastructure)
- **Stack layer** defines technology constraints and platform requirements
- **Infrastructure layer** would define deployment scripts, systemd services, etc.
- This is a constraint on *how the technology must be configured* (stack concern)

---

## Testing Verification

After spec updates, verify alignment:

1. **Check serve scripts:**
   ```bash
   grep "host" serve_backend.sh  # Should show --host 0.0.0.0
   grep "host" serve_frontend.sh # npm run dev (Vite defaults to 0.0.0.0)
   ```

2. **Verify Windows accessibility:**
   ```powershell
   # From Windows PowerShell
   curl http://localhost:8000/api/health
   curl http://localhost:5173
   curl http://localhost:8188/system_stats
   ```

3. **Update development report:**
   - Document WSL networking as resolved constraint
   - Add to "Lessons Learned" section

---

## Suggested Commit Message

```
fix(specs): Document WSL networking constraints in stack layer

Updates:
- backend-api-stack.md: Add WSL networking constraint, clarify 0.0.0.0 binding requirement
- integration-layer-stack.md: Add Windows host browser constraint, new acceptance criteria
- Cross-reference frontend-stack.md for consistency

Rationale: Development testing revealed Windows browser cannot reach WSL backend 
bound to 127.0.0.1. Implementation already correct (--host 0.0.0.0), but specs 
lacked explicit documentation of WSL port forwarding constraint.

Traceability: STK-BACKEND-022, STK-FRONTEND-011, new STK-INTEGRATION-036/037/038
```

---

## Next Steps

1. Stack agent updates three specification files
2. Verify all acceptance criteria alignment with implementation
3. Commit spec updates
4. Update development phase report with constraint documentation
5. (Optional) Add WSL networking section to README troubleshooting

---

## References

- **Implementation:** `serve_backend.sh` (already correct)
- **Specs:** `specs/stack/*.md` (need updates)
- **Error log:** `ERR_CONNECTION_REFUSED` on Windows Chrome accessing `localhost:8000/api/models`
- **WSL docs:** https://learn.microsoft.com/en-us/windows/wsl/networking

---

**Handover complete.** Stack agent should update specifications to reflect WSL networking constraints discovered during development testing.
