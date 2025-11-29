#!/usr/bin/env bash
# Comprehensive ComfyUI Monitor - GPU, VRAM, power, and generation tracking for image generation

set -uo pipefail

PORT="${1:-8188}"
SESSION_FILE="/tmp/comfyui_session_$(date +%Y%m%d_%H%M%S).log"

# Initialize session tracking variables
LAST_QUEUE_REMAINING=0
SESSION_START_TIME=$(date +%s)
SESSION_GENERATIONS=0
SESSION_PEAK_POWER=0
SESSION_PEAK_VRAM=0

echo "=== ComfyUI Comprehensive Monitor for Image Generation ==="
echo "Usage: ./monitor_comfyui.sh [PORT]"
echo "Session log: $SESSION_FILE"
echo "Started: $(date)"
echo "Press Ctrl+C to stop"
echo ""

# Create session log header
echo "# ComfyUI Session Log - $(date)" > "$SESSION_FILE"
echo "# Time,Session_Sec,GPU%,VRAM_Used,VRAM_Total,Power_W,Temp_C,Queue,Generations,Status" >> "$SESSION_FILE"

# Cleanup function for graceful exit
cleanup() {
    echo ""
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Session Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    SESSION_ELAPSED=$(($(date +%s) - SESSION_START_TIME))
    MINUTES=$((SESSION_ELAPSED / 60))
    SECONDS=$((SESSION_ELAPSED % 60))
    echo "Duration:        ${MINUTES}m ${SECONDS}s"
    echo "Generations:     ${SESSION_GENERATIONS}"
    echo "Peak Power:      ${SESSION_PEAK_POWER}W"
    echo "Peak VRAM:       ${SESSION_PEAK_VRAM}MB"
    echo "Session log:     $SESSION_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
}

trap cleanup SIGINT SIGTERM

while true; do
    TIME=$(date '+%H:%M:%S')
    SESSION_ELAPSED=$(($(date +%s) - SESSION_START_TIME))
    
    # GPU metrics: memory, utilization, power, temperature
    GPU_INFO=$(nvidia-smi --query-gpu=memory.used,memory.total,utilization.gpu,power.draw,temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
    if [ -n "$GPU_INFO" ]; then
        VRAM_USED=$(echo "$GPU_INFO" | awk -F',' '{print int($1)}')
        VRAM_TOTAL=$(echo "$GPU_INFO" | awk -F',' '{print int($2)}')
        GPU_UTIL=$(echo "$GPU_INFO" | awk -F',' '{gsub(/ /,"",$3); print int($3)}')
        POWER=$(echo "$GPU_INFO" | awk -F',' '{gsub(/ /,"",$4); print int($4)}')
        TEMP=$(echo "$GPU_INFO" | awk -F',' '{gsub(/ /,"",$5); print int($5)}')
        
        # Track session peaks
        [ "$POWER" -gt "$SESSION_PEAK_POWER" ] && SESSION_PEAK_POWER=$POWER
        [ "$VRAM_USED" -gt "$SESSION_PEAK_VRAM" ] && SESSION_PEAK_VRAM=$VRAM_USED
        
        # Power warning indicator
        if [ "$POWER" -gt 500 ]; then
            POWER_INDICATOR="⚠️ "
        elif [ "$POWER" -gt 400 ]; then
            POWER_INDICATOR="▲"
        else
            POWER_INDICATOR=" "
        fi
    else
        VRAM_USED=0
        VRAM_TOTAL=0
        GPU_UTIL=0
        POWER=0
        TEMP=0
        POWER_INDICATOR=" "
    fi
    
    # ComfyUI server status and queue
    if SYSTEM_STATS=$(curl -s --max-time 2 http://localhost:$PORT/system_stats 2>/dev/null); then
        STATUS="ONLINE"
        
        # Get queue status
        QUEUE_INFO=$(curl -s --max-time 2 http://localhost:$PORT/queue 2>/dev/null)
        if [ -n "$QUEUE_INFO" ]; then
            QUEUE_RUNNING=$(echo "$QUEUE_INFO" | jq '.queue_running | length' 2>/dev/null || echo "0")
            QUEUE_PENDING=$(echo "$QUEUE_INFO" | jq '.queue_pending | length' 2>/dev/null || echo "0")
            QUEUE_TOTAL=$((QUEUE_RUNNING + QUEUE_PENDING))
            
            # Detect generation completion (queue went from >0 to 0)
            if [ "$LAST_QUEUE_REMAINING" -gt 0 ] && [ "$QUEUE_TOTAL" -eq 0 ]; then
                SESSION_GENERATIONS=$((SESSION_GENERATIONS + LAST_QUEUE_REMAINING))
            fi
            LAST_QUEUE_REMAINING=$QUEUE_TOTAL
            
            if [ "$QUEUE_RUNNING" -gt 0 ]; then
                QUEUE_STATUS="GEN:${QUEUE_RUNNING}"
                [ "$QUEUE_PENDING" -gt 0 ] && QUEUE_STATUS="${QUEUE_STATUS}+${QUEUE_PENDING}q"
            elif [ "$QUEUE_PENDING" -gt 0 ]; then
                QUEUE_STATUS="Queue:${QUEUE_PENDING}"
            else
                QUEUE_STATUS="Idle"
            fi
        else
            QUEUE_STATUS="N/A"
            QUEUE_TOTAL=0
        fi
        
        # Build display line
        # Format: [TIME] GPU: XX% | VRAM: XXXX/XXXXX MB | PWR: XXXW | TEMP: XXC | STATUS | Queue
        printf "\r[%s] GPU: %3d%% | VRAM: %5d/%5d MB | PWR:%s%3dW | %2d°C | %-6s | %-12s | Gen: %d   " \
            "$TIME" "$GPU_UTIL" "$VRAM_USED" "$VRAM_TOTAL" "$POWER_INDICATOR" "$POWER" "$TEMP" "$STATUS" "$QUEUE_STATUS" "$SESSION_GENERATIONS"
        
        # Log to session file every 10 seconds or on activity
        if [ $((SESSION_ELAPSED % 10)) -eq 0 ] || [ "$QUEUE_RUNNING" -gt 0 ]; then
            echo "${TIME},${SESSION_ELAPSED},${GPU_UTIL},${VRAM_USED},${VRAM_TOTAL},${POWER},${TEMP},${QUEUE_TOTAL},${SESSION_GENERATIONS},${STATUS}" >> "$SESSION_FILE"
        fi
    else
        STATUS="OFFLINE"
        printf "\r[%s] GPU: %3d%% | VRAM: %5d/%5d MB | PWR:%s%3dW | %2d°C | %-6s | Server not responding   " \
            "$TIME" "$GPU_UTIL" "$VRAM_USED" "$VRAM_TOTAL" "$POWER_INDICATOR" "$POWER" "$TEMP" "$STATUS"
    fi
    
    sleep 1
done
