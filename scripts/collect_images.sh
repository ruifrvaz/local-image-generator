#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Collect Images Script
################################################################################
# Purpose: Gather all generated images into a single directory with unique names
#
# Usage:
#   ./collect_images.sh [OPTIONS]
#
# Optional:
#   --output DIR     Output directory (default: ~/images/outputs/collected/)
#   --dry-run        Show what would be done without copying
#   -h, --help       Show this help
#
# Output naming: Images are renamed numerically (001.png, 002.png, etc.)
# sorted by original folder timestamp (oldest first)
#
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUTS_DIR="$HOME/images/outputs"
IMAGES_DIR="$OUTPUTS_DIR/collected"
DRY_RUN=false

################################################################################
# Parse arguments
################################################################################

while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            IMAGES_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            grep '^#' "$0" | grep -v '#!/usr/bin/env' | sed 's/^# \?//'
            exit 0
            ;;
        *)
            echo "[ERROR] Unknown argument: $1"
            echo "Run with --help for usage"
            exit 1
            ;;
    esac
done

################################################################################
# Main
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Collect Generated Images"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Source:      $OUTPUTS_DIR"
echo "Destination: $IMAGES_DIR"
if [ "$DRY_RUN" = true ]; then
    echo "Mode:        DRY RUN (no files will be copied)"
fi
echo ""

# Check outputs directory exists
if [ ! -d "$OUTPUTS_DIR" ]; then
    echo "[ERROR] Outputs directory not found: $OUTPUTS_DIR"
    exit 1
fi

# Find all image files in timestamped subdirectories (exclude images/ folder itself)
# Sort by folder name (timestamp) to maintain chronological order
IMAGE_FILES=$(find "$OUTPUTS_DIR" -mindepth 2 -maxdepth 2 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) \
    ! -path "$IMAGES_DIR/*" 2>/dev/null | sort)

if [ -z "$IMAGE_FILES" ]; then
    echo "[WARN] No images found in $OUTPUTS_DIR subdirectories"
    exit 0
fi

# Count images
TOTAL=$(echo "$IMAGE_FILES" | wc -l)
echo "[INFO] Found $TOTAL image(s) to collect"
echo ""

# Create destination directory
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$IMAGES_DIR"
fi

# Copy and rename images
COUNTER=1
while IFS= read -r IMAGE_PATH; do
    # Get source folder name (timestamp)
    SOURCE_FOLDER=$(basename "$(dirname "$IMAGE_PATH")")
    
    # Get file extension
    EXTENSION="${IMAGE_PATH##*.}"
    
    # Generate new filename with zero-padded number
    NEW_NAME=$(printf "%03d.%s" "$COUNTER" "$EXTENSION")
    DEST_PATH="$IMAGES_DIR/$NEW_NAME"
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] $SOURCE_FOLDER/$(basename "$IMAGE_PATH") → $NEW_NAME"
    else
        cp "$IMAGE_PATH" "$DEST_PATH"
        echo "[OK] $SOURCE_FOLDER/$(basename "$IMAGE_PATH") → $NEW_NAME"
    fi
    
    COUNTER=$((COUNTER + 1))
done <<< "$IMAGE_FILES"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$DRY_RUN" = true ]; then
    echo "[INFO] Dry run complete. $TOTAL image(s) would be collected."
else
    echo "[SUCCESS] Collected $((COUNTER - 1)) image(s) to $IMAGES_DIR"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
