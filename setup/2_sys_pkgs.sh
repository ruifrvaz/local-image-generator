#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Install System Packages for Image Generation
################################################################################
# Purpose: Install build tools and image processing dependencies
#
# What it installs:
#   - python3-venv, python3-dev (Python development)
#   - build-essential (GCC, G++, make)
#   - git, git-lfs, curl, jq (utilities)
#   - ffmpeg (video/image processing)
#   - libgl1 (OpenGL for image libraries)
#
# Requirements:
#   - Ubuntu 22.04+ or similar
#   - sudo access
#
# Idempotent: Yes - checks before installing
# Usage: ./2_sys_pkgs.sh
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing System Packages for Image Generation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Refresh package lists
echo "[UPDATE] Refreshing package lists..."
sudo apt-get update -y
echo "[OK] Package lists updated"
echo ""

# Check which packages are missing
echo "[CHECK] Checking for installed packages..."
MISSING_PKGS=()
REQUIRED_PKGS=(
  "python3-venv"
  "python3-dev"
  "build-essential"
  "git"
  "git-lfs"
  "curl"
  "jq"
  "ffmpeg"
  "libgl1"
  "libglib2.0-0"
)

for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
        echo "   Missing: $pkg"
    else
        echo "   Installed: $pkg"
    fi
done
echo ""

# Install only missing packages
if [ ${#MISSING_PKGS[@]} -eq 0 ]; then
    echo "[OK] All required packages already installed"
    echo "[SKIP] No installation needed"
else
    echo "[INSTALL] Installing ${#MISSING_PKGS[@]} missing package(s)..."
    sudo apt-get install -y "${MISSING_PKGS[@]}"
    echo "[OK] Missing packages installed"
fi
echo ""

# Verify installations
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python3 --version
echo "Python venv support: $(python3 -m venv --help | head -1)"
git --version
git lfs version
curl --version | head -1
jq --version
ffmpeg -version | head -1
gcc --version | head -1
make --version | head -1
echo ""
echo "[OK] All system tools verified successfully!"
echo ""
echo "Next step:"
echo "  Run: ./3_create_venv.sh"
