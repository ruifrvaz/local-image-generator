"""
Gallery API Endpoints
Traceability: FUN-GALLERY-VIEW, STK-CONFIG
"""
from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse
from app.models.schemas import GalleryImage, GalleryFilter, GalleryStatistics
from app.config import settings
from typing import List
import os
from pathlib import Path
from datetime import datetime
import json

router = APIRouter()

# STK-CONFIG-014: Configuration values replace hardcoded paths
GALLERY_PATH = Path(settings.gallery_storage_path)

@router.get("/gallery", response_model=List[GalleryImage])
async def load_gallery(
    keywords: str = None,
    date_start: str = None,
    date_end: str = None,
    model: str = None
):
    """
    FUN-GALLERY-VIEW-001: Load images from storage directory
    FUN-GALLERY-VIEW-002: Parse metadata from txt files
    """
    if not GALLERY_PATH.exists():
        return []
    
    images = []
    
    # FUN-GALLERY-VIEW-001: Load all images from outputs directory
    for subdir in GALLERY_PATH.iterdir():
        if subdir.is_dir():
            for image_file in subdir.glob("*.png"):
                # FUN-GALLERY-VIEW-002: Parse metadata
                metadata_file = image_file.with_suffix(".txt")
                if metadata_file.exists():
                    metadata = _parse_metadata(metadata_file)
                else:
                    metadata = {}
                
                # Build GalleryImage object with API URLs
                image_id = image_file.stem
                image = GalleryImage(
                    id=image_id,
                    image_url=f"/api/gallery/image/{image_id}",
                    thumbnail_url=f"/api/gallery/image/{image_id}",  # Same for now, could optimize with actual thumbnails
                    prompt=metadata.get("prompt", ""),
                    model=metadata.get("model", "unknown"),
                    seed=metadata.get("seed", -1),
                    parameters=metadata.get("parameters", {}),
                    timestamp=datetime.fromtimestamp(image_file.stat().st_mtime),
                    filesize=image_file.stat().st_size,
                    metadata=metadata
                )
                
                # Apply filters
                if keywords and keywords.lower() not in image.prompt.lower():
                    continue
                if model and model not in image.model:
                    continue
                
                images.append(image)
    
    # FUN-GALLERY-VIEW-006: Sort by timestamp descending
    images.sort(key=lambda x: x.timestamp, reverse=True)
    
    return images

@router.get("/gallery/statistics", response_model=GalleryStatistics)
async def get_gallery_statistics():
    """
    FUN-GALLERY-VIEW-009 to 011: Calculate gallery statistics
    """
    images = await load_gallery()
    
    total_storage = sum(img.filesize for img in images)
    
    return GalleryStatistics(
        total_images=len(images),
        filtered_images=len(images),
        total_storage=total_storage,
        filtered_storage=total_storage
    )

@router.get("/gallery/image/{image_id}")
async def get_gallery_image(image_id: str):
    """
    FUN-GALLERY-VIEW-020: Serve full-size image
    """
    # Find image file
    for subdir in GALLERY_PATH.iterdir():
        if subdir.is_dir():
            image_file = subdir / f"{image_id}.png"
            if image_file.exists():
                return FileResponse(
                    image_file,
                    media_type="image/png",
                    filename=image_file.name
                )
    
    raise HTTPException(
        status_code=404,
        detail=f"Image {image_id} not found"
    )

@router.delete("/gallery/image/{image_id}")
async def delete_gallery_image(image_id: str):
    """
    FUN-GALLERY-VIEW-027: Delete image from storage
    """
    # Find and delete image file and metadata
    for subdir in GALLERY_PATH.iterdir():
        if subdir.is_dir():
            image_file = subdir / f"{image_id}.png"
            metadata_file = subdir / f"{image_id}.txt"
            
            if image_file.exists():
                # FUN-GALLERY-VIEW-027: Delete image and metadata
                deleted_files = []
                
                if image_file.exists():
                    image_file.unlink()
                    deleted_files.append(str(image_file))
                
                if metadata_file.exists():
                    metadata_file.unlink()
                    deleted_files.append(str(metadata_file))
                
                return {
                    "deleted": True,
                    "deleted_files": deleted_files
                }
    
    raise HTTPException(
        status_code=404,
        detail=f"Image {image_id} not found"
    )

def _parse_metadata(metadata_file: Path) -> dict:
    """
    Parse metadata from .txt file
    Expected format: key: value pairs
    """
    metadata = {}
    try:
        with open(metadata_file, "r") as f:
            content = f.read()
            
            # Try JSON format first
            try:
                metadata = json.loads(content)
                return metadata
            except json.JSONDecodeError:
                pass
            
            # Parse key: value format
            for line in content.split("\n"):
                if ":" in line:
                    key, value = line.split(":", 1)
                    key = key.strip().lower()
                    value = value.strip()
                    
                    if key == "prompt":
                        metadata["prompt"] = value
                    elif key == "model":
                        metadata["model"] = value
                    elif key == "seed":
                        try:
                            metadata["seed"] = int(value)
                        except ValueError:
                            metadata["seed"] = -1
                    elif key in ["steps", "cfg", "width", "height"]:
                        metadata.setdefault("parameters", {})[key] = value
    
    except Exception as e:
        print(f"Error parsing metadata: {e}")
    
    return metadata
