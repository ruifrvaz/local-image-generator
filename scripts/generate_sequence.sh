#!/usr/bin/env bash
set -euo pipefail

################################################################################
# ComfyUI Sequence Generation Script
################################################################################
# Purpose: Generate a series of images from multiple prompt files in sequence
#
# Usage:
#   ./generate_sequence.sh --model "model.safetensors" --sequence "sequence_name" [OPTIONS]
#   ./generate_sequence.sh --model "model.safetensors" --folder "/path/to/prompts" [OPTIONS]
#
# Required:
#   --model MODEL          Model path relative to models/ (supports subfolders)
#   --sequence NAME        Sequence name (looks in ~/images/prompts/sequences/NAME/)
#   OR
#   --folder PATH          Direct path to folder containing prompt files
#
# Optional:
#   --prefix TEXT          Text prepended to all prompts (style consistency)
#   --suffix TEXT          Text appended to all prompts
#   --negative TEXT        Shared negative prompt for all frames
#   --workflow PATH        Workflow JSON path (default: workflows/presets/txt2img_basic.json)
#   --lora LORA            LoRA model filename (for style consistency)
#   --steps N              Sampling steps (default: 20)
#   --cfg N                CFG scale (default: 7.0)
#   --seed N               Base seed (default: random, increments per frame)
#   --fixed-seed           Use same seed for all frames (no increment)
#   --width N              Image width (default: 1024)
#   --height N             Image height (default: 1024)
#   --output DIR           Output directory (default: ~/images/outputs/sequences/)
#   --dry-run              Preview sequence without generating images
#
# Prompt File Format:
#   Each .txt file in the sequence folder represents one frame.
#   Files are processed in alphabetical order (use NNN_ prefix for ordering).
#   Format: "positive: <text>" and optional "negative: <text>" on separate lines
#   Legacy format (plain text) also supported.
#
# Examples:
#   ./generate_sequence.sh --model "merged/model.safetensors" --sequence "street_scene"
#   ./generate_sequence.sh --model "base/sdxl.safetensors" --folder ~/my_prompts --prefix "cinematic, 8k"
#   ./generate_sequence.sh --model "model.safetensors" --sequence "story" --fixed-seed --seed 12345
#
################################################################################

# Default values
MODEL=""
SEQUENCE=""
FOLDER=""
PREFIX=""
SUFFIX=""
NEGATIVE="blurry, low quality, distorted, ugly"
WORKFLOW="../workflows/presets/txt2img_basic.json"
LORA=""
STEPS=20
CFG=5.0
BASE_SEED=$RANDOM
FIXED_SEED=false
WIDTH=1024
HEIGHT=1024
OUTPUT=""
DRY_RUN=false
COMFYUI_URL="http://localhost:8188"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGES_DIR="$HOME/images"
SEQUENCES_DIR="$IMAGES_DIR/prompts/sequences"
OUTPUTS_DIR="$IMAGES_DIR/outputs/sequences"

################################################################################
# Parse arguments
################################################################################

while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            MODEL="$2"
            shift 2
            ;;
        --sequence)
            SEQUENCE="$2"
            shift 2
            ;;
        --folder)
            FOLDER="$2"
            shift 2
            ;;
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --suffix)
            SUFFIX="$2"
            shift 2
            ;;
        --negative)
            NEGATIVE="$2"
            shift 2
            ;;
        --workflow)
            WORKFLOW="$2"
            shift 2
            ;;
        --lora)
            LORA="$2"
            shift 2
            ;;
        --steps)
            STEPS="$2"
            shift 2
            ;;
        --cfg)
            CFG="$2"
            shift 2
            ;;
        --seed)
            BASE_SEED="$2"
            shift 2
            ;;
        --fixed-seed)
            FIXED_SEED=true
            shift
            ;;
        --width)
            WIDTH="$2"
            shift 2
            ;;
        --height)
            HEIGHT="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
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
# Validate inputs
################################################################################

# Check for required --model flag
if [ -z "$MODEL" ]; then
    echo "[ERROR] --model is required"
    echo ""
    echo "Usage: $0 --model MODEL --sequence NAME [OPTIONS]"
    echo "   or: $0 --model MODEL --folder PATH [OPTIONS]"
    echo "Run with --help for full usage"
    exit 1
fi

# Check for sequence or folder
if [ -z "$SEQUENCE" ] && [ -z "$FOLDER" ]; then
    echo "[ERROR] Either --sequence or --folder is required"
    echo ""
    echo "Usage: $0 --model MODEL --sequence NAME [OPTIONS]"
    echo "   or: $0 --model MODEL --folder PATH [OPTIONS]"
    exit 1
fi

# Determine prompt folder
if [ -n "$SEQUENCE" ]; then
    PROMPT_FOLDER="$SEQUENCES_DIR/$SEQUENCE"
    SEQUENCE_NAME="$SEQUENCE"
else
    PROMPT_FOLDER="$FOLDER"
    SEQUENCE_NAME=$(basename "$FOLDER")
fi

# Check if prompt folder exists
if [ ! -d "$PROMPT_FOLDER" ]; then
    echo "[ERROR] Prompt folder not found: $PROMPT_FOLDER"
    if [ -n "$SEQUENCE" ]; then
        echo ""
        echo "Create it with: mkdir -p $PROMPT_FOLDER"
        echo "Then add prompt files: 001_scene.txt, 002_scene.txt, etc."
        echo ""
        echo "Available sequences:"
        if [ -d "$SEQUENCES_DIR" ]; then
            ls -1 "$SEQUENCES_DIR" 2>/dev/null || echo "  (none found)"
        else
            echo "  (sequences directory not found)"
            echo "  Create it with: mkdir -p $SEQUENCES_DIR"
        fi
    fi
    exit 1
fi

# Find all prompt files in the folder
PROMPT_FILES=$(find "$PROMPT_FOLDER" -maxdepth 1 -name "*.txt" -type f | sort)

if [ -z "$PROMPT_FILES" ]; then
    echo "[ERROR] No .txt files found in: $PROMPT_FOLDER"
    echo ""
    echo "Add prompt files with NNN_ prefix for ordering:"
    echo "  001_opening_scene.txt"
    echo "  002_middle_scene.txt"
    echo "  003_closing_scene.txt"
    exit 1
fi

# Count frames
FRAME_COUNT=$(echo "$PROMPT_FILES" | wc -l)

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
    echo "[ERROR] jq is not installed"
    echo "Install with: sudo apt-get install jq"
    exit 1
fi

# Check if curl is installed
if ! command -v curl >/dev/null 2>&1; then
    echo "[ERROR] curl is not installed"
    echo "Install with: sudo apt-get install curl"
    exit 1
fi

# Check if ComfyUI server is running (skip in dry-run mode)
if [ "$DRY_RUN" = false ]; then
    if ! curl -s "$COMFYUI_URL/system_stats" >/dev/null 2>&1; then
        echo "[ERROR] ComfyUI server not responding at $COMFYUI_URL"
        echo "Start the server with: ../serve_comfyui.sh"
        exit 1
    fi
fi

# Resolve workflow path
if [[ "$WORKFLOW" != /* ]]; then
    WORKFLOW="$PROJECT_DIR/$WORKFLOW"
fi
if [ ! -f "$WORKFLOW" ] && [[ "$WORKFLOW" == *"../"* ]]; then
    WORKFLOW="${WORKFLOW/..\/}"
fi
if [ ! -f "$WORKFLOW" ]; then
    echo "[ERROR] Workflow file not found: $WORKFLOW"
    exit 1
fi

# Check if model file exists
MODEL_PATH="$PROJECT_DIR/models/$MODEL"
if [ ! -f "$MODEL_PATH" ]; then
    echo "[ERROR] Model file not found: $MODEL_PATH"
    echo ""
    echo "Available models:"
    find "$PROJECT_DIR/models/" -name '*.safetensors' -type f 2>/dev/null | \
        sed "s|$PROJECT_DIR/models/||" | sort || echo "  (none found)"
    exit 1
fi

# Prepend 'user_models/' to the model name for ComfyUI
COMFYUI_MODEL="user_models/$MODEL"

# Set output directory
if [ -z "$OUTPUT" ]; then
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    OUTPUT="$OUTPUTS_DIR/${TIMESTAMP}_${SEQUENCE_NAME}"
fi

# Create output directory (skip in dry-run mode)
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$OUTPUT"
fi

################################################################################
# Display configuration
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$DRY_RUN" = true ]; then
    echo "ComfyUI Sequence Generation [DRY RUN]"
else
    echo "ComfyUI Sequence Generation"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Sequence:   $SEQUENCE_NAME"
echo "Frames:     $FRAME_COUNT"
echo "Model:      $MODEL"
echo "Workflow:   $(basename "$WORKFLOW")"
echo "Steps:      $STEPS"
echo "CFG:        $CFG"
echo "Size:       ${WIDTH}x${HEIGHT}"
echo "Base Seed:  $BASE_SEED"
echo "Fixed Seed: $FIXED_SEED"
if [ -n "$PREFIX" ]; then
    echo "Prefix:     $PREFIX"
fi
if [ -n "$SUFFIX" ]; then
    echo "Suffix:     $SUFFIX"
fi
if [ -n "$LORA" ]; then
    echo "LoRA:       $LORA"
fi
echo "Negative:   $NEGATIVE"
echo "Output:     $OUTPUT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

################################################################################
# Load workflow JSON (needed for both dry-run and generation)
################################################################################

WORKFLOW_JSON=$(cat "$WORKFLOW")

# Detect workflow type by checking if Node 2 is LoraLoader or CLIPTextEncode
IS_LORA_WORKFLOW=$(echo "$WORKFLOW_JSON" | jq -r '.["2"].class_type // ""')

################################################################################
# Process each frame
################################################################################

FRAME_NUM=0
CURRENT_SEED=$BASE_SEED
MANIFEST_ENTRIES=""

while IFS= read -r PROMPT_FILE; do
    FRAME_NUM=$((FRAME_NUM + 1))
    FRAME_NAME=$(printf "frame_%03d" "$FRAME_NUM")
    SOURCE_NAME=$(basename "$PROMPT_FILE")
    
    # Parse prompt file
    FRAME_PROMPT=$(grep -i '^positive:' "$PROMPT_FILE" 2>/dev/null | sed 's/^positive://I' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || true)
    FRAME_NEGATIVE=$(grep -i '^negative:' "$PROMPT_FILE" 2>/dev/null | sed 's/^negative://I' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || true)
    
    # Legacy format support
    if [ -z "$FRAME_PROMPT" ]; then
        FRAME_PROMPT=$(cat "$PROMPT_FILE")
    fi
    
    # Apply prefix and suffix
    if [ -n "$PREFIX" ]; then
        FRAME_PROMPT="$PREFIX, $FRAME_PROMPT"
    fi
    if [ -n "$SUFFIX" ]; then
        FRAME_PROMPT="$FRAME_PROMPT, $SUFFIX"
    fi
    
    # Use shared negative if file doesn't specify one
    if [ -z "$FRAME_NEGATIVE" ]; then
        FRAME_NEGATIVE="$NEGATIVE"
    fi
    
    # Calculate seed for this frame
    if [ "$FIXED_SEED" = true ]; then
        FRAME_SEED=$BASE_SEED
    else
        FRAME_SEED=$CURRENT_SEED
        CURRENT_SEED=$((CURRENT_SEED + 1))
    fi
    
    echo "[FRAME $FRAME_NUM/$FRAME_COUNT] $SOURCE_NAME"
    echo "  Prompt: ${FRAME_PROMPT:0:70}..."
    echo "  Seed: $FRAME_SEED"
    
    # Dry-run mode: just display info and continue
    if [ "$DRY_RUN" = true ]; then
        echo ""
        continue
    fi
    
    ############################################################################
    # Generate image via ComfyUI API
    ############################################################################
    
    # Prepare LoRA path if specified
    if [ -n "$LORA" ]; then
        LORA_PATH="user_models/$LORA"
    fi
    
    # Build modified workflow JSON
    if [ "$IS_LORA_WORKFLOW" = "LoraLoader" ]; then
        # LoRA workflow structure
        MODIFIED_WORKFLOW=$(echo "$WORKFLOW_JSON" | jq \
            --arg model "$COMFYUI_MODEL" \
            --arg lora "$LORA_PATH" \
            --arg prompt "$FRAME_PROMPT" \
            --arg negative "$FRAME_NEGATIVE" \
            --argjson steps "$STEPS" \
            --argjson cfg "$CFG" \
            --argjson seed "$FRAME_SEED" \
            --argjson width "$WIDTH" \
            --argjson height "$HEIGHT" '
            .["1"].inputs.ckpt_name = $model |
            .["2"].inputs.lora_name = $lora |
            .["3"].inputs.text = $prompt |
            .["4"].inputs.text = $negative |
            .["5"].inputs.width = $width |
            .["5"].inputs.height = $height |
            .["6"].inputs.steps = $steps |
            .["6"].inputs.cfg = $cfg |
            .["6"].inputs.seed = $seed
        ')
    else
        # Basic workflow structure
        MODIFIED_WORKFLOW=$(echo "$WORKFLOW_JSON" | jq \
            --arg model "$COMFYUI_MODEL" \
            --arg prompt "$FRAME_PROMPT" \
            --arg negative "$FRAME_NEGATIVE" \
            --argjson steps "$STEPS" \
            --argjson cfg "$CFG" \
            --argjson seed "$FRAME_SEED" \
            --argjson width "$WIDTH" \
            --argjson height "$HEIGHT" '
            if .["1"] then .["1"].inputs.ckpt_name = $model else . end |
            if .["2"] then .["2"].inputs.text = $prompt else . end |
            if .["3"] then .["3"].inputs.text = $negative else . end |
            if .["4"] then 
                .["4"].inputs.width = $width |
                .["4"].inputs.height = $height
            else . end |
            if .["5"] then 
                .["5"].inputs.steps = $steps |
                .["5"].inputs.cfg = $cfg |
                .["5"].inputs.seed = $seed
            else . end
        ')
    fi
    
    # Submit to ComfyUI
    RESPONSE=$(curl -s -X POST "$COMFYUI_URL/prompt" \
        -H "Content-Type: application/json" \
        -d "{\"prompt\": $MODIFIED_WORKFLOW}")
    
    PROMPT_ID=$(echo "$RESPONSE" | jq -r '.prompt_id')
    
    if [ -z "$PROMPT_ID" ] || [ "$PROMPT_ID" = "null" ]; then
        echo "  [ERROR] Failed to submit generation request"
        echo "  Response: $RESPONSE"
        exit 1
    fi
    
    # Poll for completion
    COMPLETED=false
    POLL_INTERVAL=1
    MAX_WAIT=300
    ELAPSED=0
    
    while [ "$COMPLETED" = false ] && [ $ELAPSED -lt $MAX_WAIT ]; do
        sleep $POLL_INTERVAL
        ELAPSED=$((ELAPSED + POLL_INTERVAL))
        
        HISTORY=$(curl -s "$COMFYUI_URL/history/$PROMPT_ID")
        
        if echo "$HISTORY" | jq -e ".\"$PROMPT_ID\"" >/dev/null 2>&1; then
            STATUS=$(echo "$HISTORY" | jq -r ".\"$PROMPT_ID\".status.completed // false")
            
            if [ "$STATUS" = "true" ]; then
                COMPLETED=true
                
                # Extract output filename
                OUTPUTS=$(echo "$HISTORY" | jq -r ".\"$PROMPT_ID\".outputs")
                FILENAME=$(echo "$OUTPUTS" | jq -r '.[].images[]?.filename' | head -1)
                
                if [ -n "$FILENAME" ]; then
                    # Download directly to frame_NNN.png
                    IMAGE_FILE="$OUTPUT/${FRAME_NAME}.png"
                    curl -s "$COMFYUI_URL/view?filename=$FILENAME" -o "$IMAGE_FILE"
                    echo "  [OK] Saved: ${FRAME_NAME}.png"
                else
                    echo "  [WARN] No output file found"
                fi
            fi
        fi
        
        if [ "$COMPLETED" = false ]; then
            printf "."
        fi
    done
    
    if [ "$COMPLETED" = false ]; then
        echo ""
        echo "  [ERROR] Generation timed out"
        exit 1
    fi
    
    # Build manifest entry
    ESCAPED_PROMPT=$(echo "$FRAME_PROMPT" | sed 's/"/\\"/g')
    if [ -n "$MANIFEST_ENTRIES" ]; then
        MANIFEST_ENTRIES="$MANIFEST_ENTRIES,"
    fi
    MANIFEST_ENTRIES="$MANIFEST_ENTRIES
    {
      \"frame\": $FRAME_NUM,
      \"filename\": \"${FRAME_NAME}.png\",
      \"source\": \"$SOURCE_NAME\",
      \"prompt\": \"$ESCAPED_PROMPT\",
      \"seed\": $FRAME_SEED
    }"
    
    echo ""
    
done <<< "$PROMPT_FILES"

################################################################################
# Dry-run summary
################################################################################

if [ "$DRY_RUN" = true ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[DRY RUN] Preview complete - no images generated"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "To generate, run without --dry-run flag"
    exit 0
fi

################################################################################
# Write manifest
################################################################################

MANIFEST_FILE="$OUTPUT/manifest.json"
cat > "$MANIFEST_FILE" << EOF
{
  "sequence": "$SEQUENCE_NAME",
  "created": "$(date -Iseconds)",
  "model": "$MODEL",
  "workflow": "$(basename "$WORKFLOW")",
  "base_seed": $BASE_SEED,
  "fixed_seed": $FIXED_SEED,
  "steps": $STEPS,
  "cfg": $CFG,
  "width": $WIDTH,
  "height": $HEIGHT,
  "negative": "$NEGATIVE",
  "frames": [$MANIFEST_ENTRIES
  ]
}
EOF

################################################################################
# Summary
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[SUCCESS] Sequence generation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Frames:   $FRAME_COUNT"
echo "Output:   $OUTPUT"
echo "Manifest: $MANIFEST_FILE"
echo ""
echo "Files:"
ls -1 "$OUTPUT"/*.png 2>/dev/null | while read -r f; do echo "  $(basename "$f")"; done
