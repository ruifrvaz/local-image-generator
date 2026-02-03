"""
FastAPI Backend for Image Generation Frontend
Integrates with ComfyUI for image generation
Traceability: STK-BACKEND, FUN-GEN-REQUEST, FUN-GALLERY-VIEW, STK-CONFIG
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import generation, gallery, models
from app.config import settings
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

app = FastAPI(
    title="Image Generation API",
    description="Backend API for SDXL image generation frontend",
    version="1.0.0"
)

# STK-INTEGRATION-005: CORS middleware for frontend origin
# STK-CONFIG-012: Configuration values replace hardcoded URLs
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
)

# Include API routers
app.include_router(generation.router, prefix="/api", tags=["generation"])
app.include_router(gallery.router, prefix="/api", tags=["gallery"])
app.include_router(models.router, prefix="/api", tags=["models"])

@app.get("/api/health")
async def health_check():
    """STK-BACKEND-030: Health check endpoint"""
    return {"status": "healthy", "service": "image-gen-backend"}
