#!/usr/bin/env bash
set -euo pipefail
# Shows NVIDIA driver and GPU from inside WSL.
nvidia-smi
echo
# Kernel and distro info for context.
uname -a
# Ubuntu release; fallback to os-release if the tool is missing.
lsb_release -a 2>/dev/null || cat /etc/os-release