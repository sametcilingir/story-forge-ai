"""
Image Service - DALL-E 3 Integration
Week 2 Day 5: Multi-modal AI (Image Generation)

Generates story illustrations using OpenAI's DALL-E 3 model.
"""

import os
import base64
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()


class ImageService:
    """
    Service for generating story illustrations using DALL-E 3.
    Returns images as base64 encoded strings for easy mobile integration.
    """
    
    def __init__(self):
        api_key = os.getenv('OPENAI_API_KEY')
        self.client = OpenAI(api_key=api_key) if api_key else None
        
        # Image generation settings
        self.default_size = "1024x1024"
        self.quality = "standard"  # "standard" or "hd"
        self.model = "dall-e-3"
    
    def generate_illustration(self, scene_description: str, style: str = "digital fantasy art") -> dict:
        """
        Generate an illustration for a story scene.
        
        Args:
            scene_description: Description of the scene to illustrate
            style: Art style to use (e.g., "watercolor", "digital art", "oil painting")
            
        Returns:
            dict with image_url or image_base64, and metadata
        """
        if not self.client:
            return {
                "success": False,
                "error": "OpenAI API key not configured"
            }
        
        # Craft the prompt for better results
        full_prompt = self._craft_image_prompt(scene_description, style)
        
        try:
            response = self.client.images.generate(
                model=self.model,
                prompt=full_prompt,
                size=self.default_size,
                quality=self.quality,
                n=1,
                response_format="b64_json"  # Return base64 for mobile app
            )
            
            image_base64 = response.data[0].b64_json
            revised_prompt = response.data[0].revised_prompt
            
            return {
                "success": True,
                "image_base64": image_base64,
                "revised_prompt": revised_prompt,
                "style": style,
                "size": self.default_size
            }
            
        except Exception as e:
            error_message = str(e)
            
            # Handle specific errors
            if "content_policy_violation" in error_message.lower():
                return {
                    "success": False,
                    "error": "The scene description contains content that cannot be illustrated. Please try a different description."
                }
            elif "rate_limit" in error_message.lower():
                return {
                    "success": False,
                    "error": "Image generation rate limit reached. Please wait a moment and try again."
                }
            else:
                return {
                    "success": False,
                    "error": f"Failed to generate image: {error_message}"
                }
    
    def _craft_image_prompt(self, scene_description: str, style: str) -> str:
        """
        Craft an optimized prompt for DALL-E 3.
        
        DALL-E 3 works best with detailed, descriptive prompts.
        """
        # Base prompt structure
        prompt_parts = [
            f"Create a {style} illustration:",
            scene_description,
            "The image should be highly detailed and visually striking.",
            "Suitable for a storybook illustration.",
            "No text or letters in the image."
        ]
        
        return " ".join(prompt_parts)
    
    def generate_character_portrait(self, character_description: str, style: str = "portrait art") -> dict:
        """
        Generate a character portrait.
        
        Args:
            character_description: Description of the character
            style: Art style for the portrait
            
        Returns:
            dict with image data
        """
        prompt = f"Character portrait: {character_description}. {style}, detailed face, expressive eyes, professional quality."
        
        return self.generate_illustration(prompt, style)
    
    def generate_scene_thumbnail(self, scene_description: str) -> dict:
        """
        Generate a smaller thumbnail image for scene preview.
        Uses standard quality for faster generation.
        """
        if not self.client:
            return {
                "success": False,
                "error": "OpenAI API key not configured"
            }
        
        try:
            response = self.client.images.generate(
                model=self.model,
                prompt=f"Thumbnail illustration: {scene_description}. Simple, clear composition.",
                size="1024x1024",  # DALL-E 3 minimum
                quality="standard",
                n=1,
                response_format="b64_json"
            )
            
            return {
                "success": True,
                "image_base64": response.data[0].b64_json,
                "type": "thumbnail"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def get_style_suggestions(self, genre: str) -> list:
        """
        Get art style suggestions based on story genre.
        """
        style_map = {
            "fantasy": [
                "digital fantasy art, vibrant colors",
                "watercolor fairy tale illustration",
                "epic fantasy oil painting style",
                "anime fantasy style",
                "classic storybook illustration"
            ],
            "sci-fi": [
                "sleek sci-fi digital art",
                "retro futuristic illustration",
                "cyberpunk neon aesthetic",
                "realistic space art",
                "conceptual sci-fi design"
            ],
            "mystery": [
                "noir film style, high contrast",
                "moody atmospheric illustration",
                "vintage detective story art",
                "dark cinematic style",
                "shadowy dramatic lighting"
            ],
            "romance": [
                "soft romantic watercolor",
                "dreamy pastel illustration",
                "elegant classic art style",
                "warm golden hour aesthetic",
                "tender emotional portrait style"
            ],
            "horror": [
                "dark gothic illustration",
                "eerie atmospheric horror art",
                "creepy unsettling style",
                "dramatic chiaroscuro",
                "supernatural dark fantasy"
            ],
            "adventure": [
                "dynamic action illustration",
                "Indiana Jones movie poster style",
                "vibrant adventure comic art",
                "epic landscape painting",
                "exciting pulp adventure style"
            ]
        }
        
        return style_map.get(genre.lower(), style_map["fantasy"])
