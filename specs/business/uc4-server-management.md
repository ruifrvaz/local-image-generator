---
id: BUS-SERVER-MGMT
status: implemented
created: 2026-02-01
prompt_version: retroactive
implemented: 2025-11-27
---

# UC4-SERVER-MGMT: Server Management

## Scope

### Included

- Starting ComfyUI server with GPU optimization
- Verifying server health and readiness
- Graceful server shutdown with resource cleanup
- Automatic detection of existing server processes
- Server access via web UI and API
- Timestamped log file generation

### Excluded

- Automatic server restart on crash
- Remote server access (network-wide)
- Multiple concurrent server instances
- Server configuration via command-line flags
- Log rotation or archival

## Actors

| Actor | Description | Goals |
|-------|-------------|-------|
| System Administrator | User managing ComfyUI infrastructure | Reliable server uptime, clean startup/shutdown, resource monitoring |
| Creative User | User needing generation capability | Quick server start, confirmation of readiness, simple access to web UI |
| System | Server process and resource manager | Efficient GPU utilization, clean process lifecycle, log preservation |
| Performance Optimizer | User monitoring resource usage | Confirm GPU detection, verify VRAM availability, track server resource consumption |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Startup Time | <10 seconds | Time from command execution to server ready |
| Shutdown Time | <5 seconds | Time from stop command to process termination |
| Process Cleanup | 100% | No orphaned ComfyUI processes after shutdown |
| Uptime Reliability | >99% | Server remains responsive during normal operation |
| Log Preservation | 100% | Each server session creates unique timestamped log file |

## Use Case

### Preconditions

- Virtual environment exists at ~/.venvs/imggen/
- ComfyUI installed at ~/ComfyUI/
- PyTorch 2.8.0+cu128 installed
- NVIDIA GPU available with CUDA support
- Port 8188 available (not in use by another process)

### Main Flow (Server Start)

1. User executes server start script
2. System displays startup banner with timestamp, port, GPU info
3. System verifies ComfyUI directory exists
4. System activates virtual environment
5. System checks for existing ComfyUI processes
6. If existing processes found, system terminates them and waits 2 seconds
7. System creates timestamped log file in logs/ directory
8. System detects GPU name and VRAM capacity via nvidia-smi
9. System counts available .safetensors model files
10. System starts ComfyUI server on port 8188 (listen 0.0.0.0)
11. System enables GPU-only optimization mode
12. System redirects output to log file
13. System confirms server accessible at http://localhost:8188
14. System displays web UI and API URLs
15. Server runs continuously until user stops it

### Main Flow (Server Stop)

1. User executes server stop script
2. System displays shutdown banner with timestamp
3. System searches for ComfyUI processes (pgrep -f "python.*ComfyUI/main.py")
4. If processes found, system sends SIGTERM signal
5. System waits up to 10 seconds for graceful shutdown
6. If processes remain, system sends SIGKILL signal (force)
7. System verifies no ComfyUI processes remain
8. System displays shutdown confirmation
9. System exits

### Alternative Flows

#### A1: Virtual Environment Not Found

**Trigger:** Virtual environment missing during activation (step 4)

1. System displays error with expected venv path
2. System suggests running setup script (4_create_venv.sh)
3. System exits with non-zero status

#### A2: ComfyUI Not Installed

**Trigger:** ComfyUI directory missing (step 3)

1. System displays error with expected ComfyUI path
2. System suggests running setup script (6_install_comfyui.sh)
3. System exits with non-zero status

#### A3: Port 8188 Already In Use

**Trigger:** Port unavailable when starting server (step 10)

1. Server startup fails with port binding error
2. User must check for conflicting processes using port 8188
3. User resolves conflict and restarts server

#### A4: No Running Server

**Trigger:** No ComfyUI processes found during stop (step 3)

1. System displays "no processes found" message
2. System exits (not an error - idempotent operation)

#### A5: GPU Not Detected

**Trigger:** nvidia-smi unavailable or fails (step 8)

1. System displays warning (not error)
2. System continues server startup without GPU info display
3. ComfyUI may fail later if GPU truly unavailable

### Postconditions (Start)

- ComfyUI server running on port 8188
- Server accessible via http://localhost:8188 (web UI)
- API accessible at http://localhost:8188/prompt
- Timestamped log file created and actively written
- GPU recognized and available for generation

### Postconditions (Stop)

- No ComfyUI processes running
- Port 8188 released
- Log file closed and preserved
- GPU resources released

## Acceptance Criteria

Requirements use format: `BUS-SERVER-MGMT-[NNN]`

- [ ] BUS-SERVER-MGMT-001: User starts server with single command execution
- [ ] BUS-SERVER-MGMT-002: Server becomes responsive within 10 seconds of startup
- [ ] BUS-SERVER-MGMT-003: System activates virtual environment before server start
- [ ] BUS-SERVER-MGMT-004: System detects and terminates existing server processes before starting
- [ ] BUS-SERVER-MGMT-005: System creates timestamped log file (YYYYMMDD_HHMMSS.log)
- [ ] BUS-SERVER-MGMT-006: System displays GPU name and VRAM capacity during startup
- [ ] BUS-SERVER-MGMT-007: System counts and displays available model files
- [ ] BUS-SERVER-MGMT-008: Server listens on port 8188 (localhost)
- [ ] BUS-SERVER-MGMT-009: Web UI accessible at http://localhost:8188
- [ ] BUS-SERVER-MGMT-010: API accessible at http://localhost:8188/prompt
- [ ] BUS-SERVER-MGMT-011: User stops server with single command execution
- [ ] BUS-SERVER-MGMT-012: System attempts graceful shutdown (SIGTERM) before force kill
- [ ] BUS-SERVER-MGMT-013: System completes shutdown within 5 seconds
- [ ] BUS-SERVER-MGMT-014: System verifies no ComfyUI processes remain after stop
- [ ] BUS-SERVER-MGMT-015: System displays error when virtual environment not found
- [ ] BUS-SERVER-MGMT-016: System displays error when ComfyUI directory not found
- [ ] BUS-SERVER-MGMT-017: Stop command is idempotent (no error if server not running)
- [ ] BUS-SERVER-MGMT-018: System preserves log files after server stop
- [ ] BUS-SERVER-MGMT-019: System enables GPU-only optimization mode on startup
- [ ] BUS-SERVER-MGMT-020: Server continues running until explicitly stopped

---

*Generated with smaqit v0.6.2-beta*
