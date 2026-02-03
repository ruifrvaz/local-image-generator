"""
ComfyUI Integration Service
Handles communication with ComfyUI server
Traceability: STK-INTEGRATION-014 to STK-INTEGRATION-019, FUN-GEN-REQUEST
"""
import requests
import json
import os
import random
from typing import Dict, Optional

COMFYUI_BASE_URL = "http://localhost:8188"
WORKFLOW_DIR = os.path.join(os.path.dirname(__file__), "../../..", "workflows/presets")

class ComfyUIService:
    """Service for interacting with ComfyUI API"""
    
    def __init__(self):
        self.base_url = COMFYUI_BASE_URL
    
    def is_available(self) -> bool:
        """Check if ComfyUI server is running"""
        try:
            response = requests.get(f"{self.base_url}/system_stats", timeout=2)
            return response.status_code == 200
        except requests.RequestException:
            return False
    
    def submit_generation(self, workflow: Dict) -> Optional[Dict]:
        """
        STK-INTEGRATION-015: Submit generation request to ComfyUI
        FUN-GEN-REQUEST-008: POST to /prompt endpoint
        """
        try:
            response = requests.post(
                f"{self.base_url}/prompt",
                json={"prompt": workflow},
                timeout=10
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error submitting to ComfyUI: {e}")
            return None
    
    def get_generation_status(self, prompt_id: str) -> Optional[Dict]:
        """
        STK-INTEGRATION-016: Poll ComfyUI for generation status
        FUN-GEN-REQUEST-011: Poll /history/{prompt_id}
        """
        try:
            response = requests.get(
                f"{self.base_url}/history/{prompt_id}",
                timeout=5
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error checking status: {e}")
            return None
    
    def download_image(self, filename: str) -> Optional[bytes]:
        """
        STK-INTEGRATION-017: Download generated image
        FUN-GEN-REQUEST-015: Download via /view endpoint
        """
        try:
            response = requests.get(
                f"{self.base_url}/view",
                params={"filename": filename},
                timeout=30
            )
            response.raise_for_status()
            return response.content
        except requests.RequestException as e:
            print(f"Error downloading image: {e}")
            return None
    
    def get_available_models(self) -> Optional[Dict]:
        """
        STK-INTEGRATION-018: Query available models
        FUN-MODEL-SELECT-001: Query /object_info endpoint
        """
        try:
            response = requests.get(
                f"{self.base_url}/object_info",
                timeout=5
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error fetching models: {e}")
            return None
    
    def construct_workflow(self, request_data: Dict) -> Dict:
        """
        FUN-GEN-REQUEST-007: Construct workflow JSON with parameters
        """
        # Load workflow template
        workflow_path = os.path.join(WORKFLOW_DIR, "txt2img_basic.json")
        with open(workflow_path, 'r') as f:
            workflow = json.load(f)
        
        # Update node parameters
        workflow["1"]["inputs"]["ckpt_name"] = request_data['model']
        workflow["2"]["inputs"]["text"] = request_data['prompt']
        workflow["3"]["inputs"]["text"] = request_data.get('negative_prompt', 'blurry, low quality')
        
        # Handle seed: -1 means random, otherwise use provided seed
        seed = request_data.get('seed', -1)
        if seed == -1:
            seed = random.randint(0, 2**32 - 1)
        workflow["5"]["inputs"]["seed"] = seed
        
        workflow["5"]["inputs"]["steps"] = request_data.get('steps', 20)
        workflow["5"]["inputs"]["cfg"] = request_data.get('cfg', 7.0)
        
        return workflow

comfyui_service = ComfyUIService()
