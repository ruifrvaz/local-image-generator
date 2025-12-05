#!/usr/bin/env bash
set -euo pipefail

################################################################################
# ComfyUI Image Generation Script
################################################################################
# Purpose: Command-line wrapper for ComfyUI API-based image generation
#
# Usage:
#   ./generate.sh --model "model.safetensors" [OPTIONS]
#   ./generate.sh --model "subfolder/model.safetensors" [OPTIONS]
#
# Required:
#   --model MODEL          Model path relative to models/ (supports subfolders)
#
# Optional:
#   --prompt-file FILE     Read prompt from text file (default: latest in ~/images/prompts/)
#                          File format: "positive: <text>" and "negative: <text>" on separate lines
#                          Legacy format (plain text) also supported
#   --prompt TEXT          Generation prompt (overrides --prompt-file)
#   --negative TEXT        Negative prompt (overrides file-based negative, default: "blurry, low quality")
#   --workflow PATH        Workflow JSON path (default: workflows/presets/txt2img_basic.json)
#   --lora LORA            LoRA model filename (for txt2img_lora workflow)
#   --steps N              Sampling steps (default: 20)
#   --cfg N                CFG scale (default: 7.0)
#   --seed N               Random seed (default: random)
#   --width N              Image width (default: 1024)
#   --height N             Image height (default: 1024)
#   --output DIR           Output directory (default: ~/images/outputs/YYYYMMDD_HHMMSS/)
#   --count N              Number of images to generate (default: 1, uses different seeds)
#
# Requirements:
#   - ComfyUI server running on http://localhost:8188
#   - jq installed (for JSON manipulation)
#   - curl installed (for API calls)
#
# TODO:
#   - Batch generation from text file of prompts
#   - Support for img2img workflow
#   - Support for upscale workflow
#
# Examples:
#   ./generate.sh --model "base_sdxl.safetensors" --prompt "astronaut on mars"
#   ./generate.sh --model "illustrious/model.safetensors" --prompt "1girl, astronaut"
#   ./generate.sh --model "Pony/model.safetensors" --workflow workflows/presets/txt2img_lora.json --lora "lora.safetensors"
#
################################################################################

# Default values
PROMPT=""
PROMPT_FILE=""
NEGATIVE="blurry, low quality, distorted, ugly"
WORKFLOW="../workflows/presets/txt2img_basic.json"
LORA=""
STEPS=20
CFG=5.0
SEED=$RANDOM
SEED_SPECIFIED=false
WIDTH=1024
HEIGHT=1024
OUTPUT=""
MODEL=""
COUNT=1
COMFYUI_URL="http://localhost:8188"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGES_DIR="$HOME/images"
PROMPTS_DIR="$IMAGES_DIR/prompts"
OUTPUTS_DIR="$IMAGES_DIR/outputs"

################################################################################
# Parse arguments
################################################################################

while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            MODEL="$2"
            shift 2
            ;;
        --prompt-file)
            PROMPT_FILE="$2"
            shift 2
            ;;
        --prompt)
            PROMPT="$2"
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
            SEED="$2"
            SEED_SPECIFIED=true
            shift 2
            ;;
        --width)
            WIDTH="$2"
            shift 2
            ;;
        --count)
            COUNT="$2"
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
    echo "Usage: $0 --model MODEL_FILE [OPTIONS]"
    echo "Run with --help for full usage"
    exit 1
fi

# Load prompt from file if not specified via --prompt
if [ -z "$PROMPT" ]; then
    # Determine which file to load
    SELECTED_FILE=""
    
    # If --prompt-file specified, use that file
    if [ -n "$PROMPT_FILE" ]; then
        if [ ! -f "$PROMPT_FILE" ]; then
            echo "[ERROR] Prompt file not found: $PROMPT_FILE"
            exit 1
        fi
        SELECTED_FILE="$PROMPT_FILE"
    else
        # Find latest prompt file in prompts/ directory
        if [ -d "$PROMPTS_DIR" ]; then
            LATEST_PROMPT=$(ls -t "$PROMPTS_DIR"/*.txt 2>/dev/null | head -1)
            if [ -n "$LATEST_PROMPT" ]; then
                SELECTED_FILE="$LATEST_PROMPT"
            else
                echo "[ERROR] No prompt files found in $PROMPTS_DIR"
                echo "Create a text file with your prompt, e.g.:"
                echo "  positive: your prompt here"
                echo "  negative: bad quality, distorted"
                exit 1
            fi
        else
            echo "[ERROR] Prompts directory not found: $PROMPTS_DIR"
            echo "Create it with: mkdir -p $PROMPTS_DIR"
            exit 1
        fi
    fi
    
    # Parse file for positive: and negative: entries
    # Note: || true prevents set -e from exiting when grep finds no match
    PROMPT=$(grep -i '^positive:' "$SELECTED_FILE" 2>/dev/null | sed 's/^positive://I' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || true)
    FILE_NEGATIVE=$(grep -i '^negative:' "$SELECTED_FILE" 2>/dev/null | sed 's/^negative://I' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || true)
    
    # If no structured format found, treat entire file as positive prompt (legacy support)
    if [ -z "$PROMPT" ]; then
        PROMPT=$(cat "$SELECTED_FILE")
        echo "[INFO] Loaded prompt from: $SELECTED_FILE (legacy format)"
    else
        echo "[INFO] Loaded prompt from: $SELECTED_FILE"
        # Override default negative if file contains negative: entry
        if [ -n "$FILE_NEGATIVE" ]; then
            NEGATIVE="$FILE_NEGATIVE"
            echo "[INFO] Loaded negative prompt from file"
        fi
    fi
fi

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

# Check if ComfyUI server is running
if ! curl -s "$COMFYUI_URL/system_stats" >/dev/null 2>&1; then
    echo "[ERROR] ComfyUI server not responding at $COMFYUI_URL"
    echo "Start the server with: ../serve_comfyui.sh"
    exit 1
fi

# Resolve workflow path (relative to script dir or absolute)
if [[ "$WORKFLOW" != /* ]]; then
    # If relative path, resolve from project root
    WORKFLOW="$PROJECT_DIR/$WORKFLOW"
fi

# If workflow still not found, try removing ../ prefix
if [ ! -f "$WORKFLOW" ] && [[ "$WORKFLOW" == *"../"* ]]; then
    WORKFLOW="${WORKFLOW/..\/}"
fi

# Check if workflow file exists
if [ ! -f "$WORKFLOW" ]; then
    echo "[ERROR] Workflow file not found: $WORKFLOW"
    exit 1
fi

# Check if model file exists (supports subfolders)
MODEL_PATH="$PROJECT_DIR/models/$MODEL"
if [ ! -f "$MODEL_PATH" ]; then
    echo "[ERROR] Model file not found: $MODEL_PATH"
    echo ""
    echo "Available models:"
    # List all .safetensors files recursively with relative paths
    find "$PROJECT_DIR/models/" -name '*.safetensors' -type f 2>/dev/null | \
        sed "s|$PROJECT_DIR/models/||" | sort || echo "  (none found)"
    echo ""
    echo "Tip: Use subfolder/filename.safetensors for organized models"
    exit 1
fi

# Prepend 'user_models/' to the model name for ComfyUI
MODEL="user_models/$MODEL"

# Set output directory with timestamp if not specified
if [ -z "$OUTPUT" ]; then
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    OUTPUT="$OUTPUTS_DIR/$TIMESTAMP"
fi

# Create output directory
mkdir -p "$OUTPUT"

################################################################################
# Generate image
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ComfyUI Image Generation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Model:    $MODEL"
echo "Prompt:   $PROMPT"
echo "Negative: $NEGATIVE"
echo "Steps:    $STEPS"
echo "CFG:      $CFG"
echo "Seed:     $SEED"
echo "Size:     ${WIDTH}x${HEIGHT}"
if [ -n "$LORA" ]; then
    echo "LoRA:     $LORA"
fi
echo "Workflow: $(basename "$WORKFLOW")"
echo "Output:   $OUTPUT"
if [ "$COUNT" -gt 1 ]; then
    echo "Count:    $COUNT"
fi
echo ""

# Load workflow JSON
WORKFLOW_JSON=$(cat "$WORKFLOW")

# Detect workflow type by checking if Node 2 is LoraLoader or CLIPTextEncode
IS_LORA_WORKFLOW=$(echo "$WORKFLOW_JSON" | jq -r '.["2"].class_type // ""')

# Store base seed for multi-generation
BASE_SEED=$SEED

################################################################################
# Generation loop
################################################################################

for ((GEN_NUM=1; GEN_NUM<=COUNT; GEN_NUM++)); do

# Calculate seed for this iteration
if [ "$SEED_SPECIFIED" = true ]; then
    CURRENT_SEED=$((BASE_SEED + GEN_NUM - 1))
else
    CURRENT_SEED=$RANDOM
fi

# Set output filenames based on count
if [ "$COUNT" -eq 1 ]; then
    IMAGE_FILE="$OUTPUT/image.png"
    METADATA_FILE="$OUTPUT/prompt.txt"
else
    IMAGE_FILE="$OUTPUT/image_$(printf '%03d' $GEN_NUM).png"
    METADATA_FILE="$OUTPUT/prompt_$(printf '%03d' $GEN_NUM).txt"
fi

if [ "$COUNT" -gt 1 ]; then
    echo "[${GEN_NUM}/${COUNT}] Generating with seed $CURRENT_SEED..."
else
    echo "[BUILD] Preparing workflow with parameters..."
fi

if [ "$IS_LORA_WORKFLOW" = "LoraLoader" ]; then
    # LoRA workflow: txt2img_lora.json structure
    LORA_PATH="user_models/$LORA"
    
    MODIFIED_WORKFLOW=$(echo "$WORKFLOW_JSON" | jq \
        --arg model "$MODEL" \
        --arg lora "$LORA_PATH" \
        --arg prompt "$PROMPT" \
        --arg negative "$NEGATIVE" \
        --argjson steps "$STEPS" \
        --argjson cfg "$CFG" \
        --argjson seed "$CURRENT_SEED" \
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
    # Basic workflow: txt2img_basic.json structure
    MODIFIED_WORKFLOW=$(echo "$WORKFLOW_JSON" | jq \
        --arg model "$MODEL" \
        --arg prompt "$PROMPT" \
        --arg negative "$NEGATIVE" \
        --argjson steps "$STEPS" \
        --argjson cfg "$CFG" \
        --argjson seed "$CURRENT_SEED" \
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
    echo "[ERROR] Failed to submit generation request"
    echo "Response: $RESPONSE"
    exit 1
fi

# Poll for completion
COMPLETED=false
POLL_INTERVAL=2
MAX_WAIT=300  # 5 minutes
ELAPSED=0

while [ "$COMPLETED" = false ] && [ $ELAPSED -lt $MAX_WAIT ]; do
    sleep $POLL_INTERVAL
    ELAPSED=$((ELAPSED + POLL_INTERVAL))
    
    # Check history for completion
    HISTORY=$(curl -s "$COMFYUI_URL/history/$PROMPT_ID")
    
    if echo "$HISTORY" | jq -e ".\"$PROMPT_ID\"" >/dev/null 2>&1; then
        # Check if generation completed successfully
        STATUS=$(echo "$HISTORY" | jq -r ".\"$PROMPT_ID\".status.completed // false")
        
        if [ "$STATUS" = "true" ]; then
            COMPLETED=true
            
            # Extract output filenames
            OUTPUTS=$(echo "$HISTORY" | jq -r ".\"$PROMPT_ID\".outputs")
            
            # Find the SaveImage node output (usually node 8)
            FILENAMES=$(echo "$OUTPUTS" | jq -r '.[].images[]?.filename' | head -1)
            
            if [ -n "$FILENAMES" ]; then
                # Download image
                curl -s "$COMFYUI_URL/view?filename=$FILENAMES" -o "$IMAGE_FILE"
                
                if [ "$COUNT" -gt 1 ]; then
                    echo "[OK] Saved: $(basename "$IMAGE_FILE") (seed: $CURRENT_SEED)"
                else
                    echo "[OK] Image saved: $IMAGE_FILE"
                fi
                
                # Save metadata
                cat > "$METADATA_FILE" <<EOF
Model: $MODEL
Prompt: $PROMPT
Negative: $NEGATIVE
Steps: $STEPS
CFG: $CFG
Seed: $CURRENT_SEED
Size: ${WIDTH}x${HEIGHT}
Workflow: $(basename "$WORKFLOW")
Generated: $(date '+%Y-%m-%d %H:%M:%S')
EOF
                if [ "$COUNT" -eq 1 ]; then
                    echo "[OK] Metadata saved: $METADATA_FILE"
                fi
            else
                echo "[WARN] No output files found in response"
            fi
        fi
    fi
    
    # Print progress indicator (only for single image)
    if [ "$COMPLETED" = false ] && [ "$COUNT" -eq 1 ]; then
        printf "."
    fi
done

if [ "$COMPLETED" = false ]; then
    echo "[ERROR] Generation timed out after ${MAX_WAIT}s"
    exit 1
fi

done  # End generation loop

################################################################################
# Summary
################################################################################

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$COUNT" -gt 1 ]; then
    echo "[SUCCESS] Generated $COUNT images!"
else
    echo "[SUCCESS] Image generation complete!"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Output: $OUTPUT"
echo ""
