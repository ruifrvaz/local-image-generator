"""
Pydantic models/schemas for API requests and responses
"""
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
from datetime import datetime


# Gallery schemas
class GalleryImage(BaseModel):
    id: str
    image_url: str
    thumbnail_url: str
    prompt: str
    model: str
    seed: int
    parameters: Dict[str, Any]
    timestamp: datetime
    filesize: int
    metadata: Dict[str, Any]
    filepath: Optional[str] = None


class GalleryFilter(BaseModel):
    keywords: Optional[str] = None
    date_start: Optional[str] = None
    date_end: Optional[str] = None
    model: Optional[str] = None


class GalleryStatistics(BaseModel):
    total_images: int
    filtered_images: int
    total_storage: int
    filtered_storage: int


# Generation schemas
class GenerationRequest(BaseModel):
    prompt: str
    model: str
    steps: Optional[int] = 20
    cfg: Optional[float] = 7.0
    seed: Optional[int] = -1
    resolution: Optional[Dict[str, int]] = {"width": 1024, "height": 1024}
    negative_prompt: Optional[str] = None


class GenerationResponse(BaseModel):
    request_id: str
    status: str
    message: Optional[str] = None


class GenerationStatus(BaseModel):
    request_id: str
    status: str
    progress: Optional[float] = None
    image_url: Optional[str] = None
    error: Optional[str] = None


class FramePrompt(BaseModel):
    """For animation/video generation"""
    frame_number: int
    prompt: str


# Batch generation schemas
class BatchRequest(BaseModel):
    prompts: List[str]
    model: str
    steps: Optional[int] = 20
    cfg: Optional[float] = 7.0
    seed_start: Optional[int] = -1
    resolution: Optional[Dict[str, int]] = {"width": 1024, "height": 1024}
    negative_prompt: Optional[str] = None


class BatchProgress(BaseModel):
    batch_id: str
    total_images: int
    completed: int
    failed: int
    status: str
    image_urls: List[str]


# Sequence generation schemas
class SequencePrompts(BaseModel):
    prompts: List[str]
    model: str
    steps: Optional[int] = 20
    cfg: Optional[float] = 7.0
    seed: Optional[int] = -1
    resolution: Optional[Dict[str, int]] = {"width": 1024, "height": 1024}
    negative_prompt: Optional[str] = None


class SequenceRequest(BaseModel):
    prompts: List[str]
    model: str
    steps: Optional[int] = 20
    cfg: Optional[float] = 7.0
    seed: Optional[int] = -1
    resolution: Optional[Dict[str, int]] = {"width": 1024, "height": 1024}
    negative_prompt: Optional[str] = None


# Model schemas
class ModelInfo(BaseModel):
    filename: str
    display_name: str
    category: str
    size: Optional[int] = None
    description: Optional[str] = None


class ModelList(BaseModel):
    base: List[ModelInfo]
    lora: List[ModelInfo]
    merged: List[ModelInfo]
