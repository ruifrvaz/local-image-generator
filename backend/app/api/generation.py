"""
Generation API Endpoints
Traceability: FUN-GEN-REQUEST, FUN-BATCH-GEN, FUN-SEQUENCE-GEN
"""
from fastapi import APIRouter, HTTPException, BackgroundTasks
from app.models.schemas import (
    GenerationRequest, GenerationResponse,
    BatchRequest, BatchProgress,
    SequenceRequest, SequencePrompts
)
from app.services.comfyui import comfyui_service
import uuid
from typing import Dict

router = APIRouter()

# In-memory storage for generation status (production would use Redis/database)
generation_status: Dict[str, Dict] = {}

@router.post("/generate", response_model=GenerationResponse)
async def generate_image(request: GenerationRequest):
    """
    FUN-GEN-REQUEST: Submit single image generation request
    STK-BACKEND-011: /api prefix
    """
    # FUN-GEN-REQUEST-001 to 006: Validation (handled by Pydantic)
    
    # STK-BACKEND-029: Check ComfyUI availability
    if not comfyui_service.is_available():
        raise HTTPException(
            status_code=503,
            detail="ComfyUI server not available. Please ensure it is running on port 8188."
        )
    
    # FUN-GEN-REQUEST-007: Construct workflow JSON
    workflow = comfyui_service.construct_workflow(request.dict())
    
    # FUN-GEN-REQUEST-008: Submit to ComfyUI
    result = comfyui_service.submit_generation(workflow)
    
    if not result or "prompt_id" not in result:
        raise HTTPException(
            status_code=500,
            detail="Failed to submit generation request to ComfyUI"
        )
    
    # FUN-GEN-REQUEST-009: Extract prompt_id
    request_id = result["prompt_id"]
    
    # Store initial status
    generation_status[request_id] = {
        "status": "queued",
        "request": request.dict()
    }
    
    # FUN-GEN-REQUEST-010: Return response with request_id
    return GenerationResponse(
        request_id=request_id,
        status="queued"
    )

@router.get("/generate/status/{request_id}", response_model=GenerationResponse)
async def get_generation_status(request_id: str):
    """
    FUN-GEN-REQUEST-011: Poll generation status
    FUN-GEN-REQUEST-012: Update progress indicator
    """
    # FUN-GEN-REQUEST-011: Poll ComfyUI /history endpoint
    history = comfyui_service.get_generation_status(request_id)
    
    if not history or request_id not in history:
        raise HTTPException(
            status_code=404,
            detail=f"Generation request {request_id} not found"
        )
    
    status_data = history[request_id]
    
    # FUN-GEN-REQUEST-013: Detect completion
    if status_data.get("status", {}).get("completed"):
        # FUN-GEN-REQUEST-014: Extract image filename
        outputs = status_data.get("outputs", {})
        if outputs:
            # Find first image in outputs
            for node_outputs in outputs.values():
                if "images" in node_outputs and node_outputs["images"]:
                    filename = node_outputs["images"][0]["filename"]
                    return GenerationResponse(
                        request_id=request_id,
                        status="complete",
                        image_url=f"/api/generate/image/{filename}"
                    )
        
        return GenerationResponse(
            request_id=request_id,
            status="complete",
            error_message="Image generated but filename not found"
        )
    
    # Check for errors
    if "error" in status_data.get("status", {}):
        error_msg = status_data["status"]["error"]
        return GenerationResponse(
            request_id=request_id,
            status="failed",
            error_message=error_msg
        )
    
    # FUN-GEN-REQUEST-012: Return processing status
    return GenerationResponse(
        request_id=request_id,
        status="processing"
    )

@router.get("/generate/image/{filename}")
async def download_generated_image(filename: str):
    """
    FUN-GEN-REQUEST-015: Download completed image
    STK-INTEGRATION-017: Download from ComfyUI
    """
    from fastapi.responses import Response
    
    # FUN-GEN-REQUEST-015: Download image bytes
    image_data = comfyui_service.download_image(filename)
    
    if not image_data:
        raise HTTPException(
            status_code=404,
            detail=f"Image {filename} not found"
        )
    
    # Return image as PNG response
    return Response(
        content=image_data,
        media_type="image/png",
        headers={
            "Content-Disposition": f"inline; filename={filename}"
        }
    )

@router.post("/batch", response_model=Dict)
async def generate_batch(request: BatchRequest):
    """
    FUN-BATCH-GEN: Submit batch generation request
    Placeholder implementation - would queue multiple generations
    """
    # FUN-BATCH-GEN-004 to 005: Validation (handled by Pydantic)
    
    if not comfyui_service.is_available():
        raise HTTPException(
            status_code=503,
            detail="ComfyUI server not available"
        )
    
    batch_id = str(uuid.uuid4())
    
    # Store batch status
    generation_status[batch_id] = {
        "status": "queued",
        "type": "batch",
        "request": request.dict(),
        "completed_images": 0,
        "total_images": request.batch_count
    }
    
    return {
        "batch_id": batch_id,
        "queued_images": request.batch_count,
        "estimated_time": request.batch_count * 5  # Rough estimate
    }

@router.post("/sequence/prompts", response_model=SequencePrompts)
async def generate_sequence_prompts(request: SequenceRequest):
    """
    FUN-SEQUENCE-GEN-007: Generate frame prompts via scene producer
    STK-INTEGRATION-020 to 022: Backend-agent integration
    Placeholder implementation - would call scene producer agent
    """
    # FUN-SEQUENCE-GEN-005 to 006: Validation (handled by Pydantic)
    
    sequence_id = str(uuid.uuid4())
    
    # TODO: Integrate with scene producer agent
    # For now, return placeholder prompts
    from app.models.schemas import FramePrompt
    
    prompts = [
        FramePrompt(
            frame_number=i+1,
            prompt=f"Frame {i+1} of story: {request.story_description[:50]}...",
            description=f"Scene {i+1}",
            shot_type="medium"
        )
        for i in range(request.frame_count)
    ]
    
    return SequencePrompts(
        sequence_id=sequence_id,
        prompts=prompts,
        metadata={
            "story": request.story_description,
            "arc": request.narrative_arc
        }
    )
