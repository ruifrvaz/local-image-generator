"""
FastAPI Backend for Image Generation Frontend
Integrates with ComfyUI for image generation
Traceability: STK-BACKEND, FUN-GEN-REQUEST, FUN-GALLERY-VIEW
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import generation, gallery, models

app = FastAPI(
    title="Image Generation API",
    description="Backend API for SDXL image generation frontend",
    version="1.0.0"
)

# STK-INTEGRATION-005: CORS middleware for frontend origin
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",  # Frontend dev server (localhost)
        "http://172.31.243.212:5173",  # Frontend dev server (WSL IP)
    ],
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
