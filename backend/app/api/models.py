"""
Models API Endpoints
Traceability: FUN-MODEL-SELECT
"""
from fastapi import APIRouter, HTTPException
from app.models.schemas import ModelInfo, ModelList
from app.services.comfyui import comfyui_service
from typing import List

router = APIRouter()

@router.get("/checkpoints", response_model=ModelList)
async def get_available_models():
    """
    FUN-MODEL-SELECT-001: Query ComfyUI for available models
    FUN-MODEL-SELECT-002 to 003: Extract and categorize models
    """
    # FUN-MODEL-SELECT-001: Query /object_info
    object_info = comfyui_service.get_available_models()
    
    if not object_info:
        raise HTTPException(
            status_code=503,
            detail="Cannot connect to ComfyUI server"
        )
    
    base_models = []
    lora_models = []
    merged_models = []
    
    # FUN-MODEL-SELECT-002: Extract checkpoint models
    if "CheckpointLoaderSimple" in object_info:
        checkpoint_input = object_info["CheckpointLoaderSimple"].get("input", {})
        required = checkpoint_input.get("required", {})
        ckpt_names = required.get("ckpt_name", [[]])[0]
        
        for filename in ckpt_names:
            # FUN-MODEL-SELECT-004: Categorize by directory
            category = _categorize_model(filename)
            
            # FUN-MODEL-SELECT-005: Remove user_models/ prefix
            display_name = filename.replace("user_models/", "")
            
            # FUN-MODEL-SELECT-006: Remove .safetensors extension
            display_name = display_name.replace(".safetensors", "")
            
            model_info = ModelInfo(
                filename=filename,
                display_name=display_name,
                category=category,
                path=filename
            )
            
            if category == "base":
                base_models.append(model_info)
            elif category == "merged":
                merged_models.append(model_info)
    
    # FUN-MODEL-SELECT-003: Extract LoRA models
    if "LoraLoader" in object_info:
        lora_input = object_info["LoraLoader"].get("input", {})
        required = lora_input.get("required", {})
        lora_names = required.get("lora_name", [[]])[0]
        
        for filename in lora_names:
            display_name = filename.replace("user_models/", "").replace(".safetensors", "")
            
            model_info = ModelInfo(
                filename=filename,
                display_name=display_name,
                category="lora",
                path=filename
            )
            lora_models.append(model_info)
    
    # FUN-MODEL-SELECT-009: Sort alphabetically
    base_models.sort(key=lambda x: x.display_name)
    lora_models.sort(key=lambda x: x.display_name)
    merged_models.sort(key=lambda x: x.display_name)
    
    total = len(base_models) + len(lora_models) + len(merged_models)
    
    return ModelList(
        base=base_models,
        lora=lora_models,
        merged=merged_models,
        total_count=total
    )

def _categorize_model(filename: str) -> str:
    """
    FUN-MODEL-SELECT-004: Categorize model by directory path
    """
    filename_lower = filename.lower()
    
    if "base/" in filename_lower or "base" in filename_lower:
        return "base"
    elif "merged/" in filename_lower or "merged" in filename_lower:
        return "merged"
    elif "lora" in filename_lower:
        return "lora"
    else:
        # Default to base if unclear
        return "base"
