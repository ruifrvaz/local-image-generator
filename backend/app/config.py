"""
Configuration Management Module
Loads and validates configuration from .env file
Traceability: STK-CONFIG, FUN-CONFIG
"""
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List
import os
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

# Find project root (parent of backend directory)
PROJECT_ROOT = Path(__file__).parent.parent.parent
ENV_FILE = PROJECT_ROOT / '.env'


class Settings(BaseSettings):
    """
    Application configuration loaded from .env file
    
    STK-CONFIG-002: Uses pydantic-settings for type-safe configuration
    STK-CONFIG-003: Defines all required configuration fields
    """
    model_config = SettingsConfigDict(
        env_file=str(ENV_FILE),
        env_file_encoding='utf-8',
        case_sensitive=False,
        extra='ignore'  # Ignore extra fields like VITE_* from frontend
    )
    
    # Backend server configuration
    backend_host: str = "0.0.0.0"
    backend_port: int = 8000
    
    # CORS configuration
    # STK-CONFIG-011: Accepts comma-separated list of URLs
    cors_origins: str
    
    # ComfyUI integration
    comfyui_api_url: str
    
    # Storage paths
    gallery_storage_path: str
    
    @property
    def cors_origins_list(self) -> List[str]:
        """
        Parse comma-separated CORS origins into list
        STK-CONFIG-011: CORS origins accepts comma-separated list
        """
        return [origin.strip() for origin in self.cors_origins.split(',')]


def load_settings() -> Settings:
    """
    Load settings from .env file with validation
    
    STK-CONFIG-001: Loads from .env file in project root
    STK-CONFIG-004: Fails with clear error if required fields missing
    STK-CONFIG-009: Logs configuration source at startup
    """
    try:
        settings = Settings()
        
        # Log .env file location
        if ENV_FILE.exists():
            logger.info(f"Configuration loaded from: {ENV_FILE}")
        else:
            logger.warning(f".env file not found at: {ENV_FILE}")
        
        # Log loaded configuration (excluding sensitive data)
        logger.info(f"Backend host: {settings.backend_host}")
        logger.info(f"Backend port: {settings.backend_port}")
        logger.info(f"CORS origins: {settings.cors_origins_list}")
        logger.info(f"ComfyUI API URL: {settings.comfyui_api_url}")
        logger.info(f"Gallery storage path: {settings.gallery_storage_path}")
        
        return settings
    
    except Exception as e:
        # STK-CONFIG-004: Clear error message for missing configuration
        error_msg = (
            f"Configuration error: {str(e)}\n"
            f"Please ensure .env file exists at {ENV_FILE} with all required fields:\n"
            f"  - CORS_ORIGINS\n"
            f"  - COMFYUI_API_URL\n"
            f"  - GALLERY_STORAGE_PATH\n"
            f"See .env.example for template."
        )
        logger.error(error_msg)
        raise RuntimeError(error_msg) from e


# Global settings instance
settings = load_settings()
