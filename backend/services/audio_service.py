"""
Audio Service - OpenAI TTS Integration
Week 2 Day 5: Multi-modal AI (Text-to-Speech)

Generates audio narration for stories using OpenAI's TTS model.
"""

import os
import base64
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()


class AudioService:
    """
    Service for generating story narration using OpenAI TTS.
    Returns audio as base64 encoded MP3 for mobile playback.
    """
    
    def __init__(self):
        api_key = os.getenv('OPENAI_API_KEY')
        self.client = OpenAI(api_key=api_key) if api_key else None
        
        # Available voices
        self.voices = {
            "alloy": "Neutral and balanced",
            "echo": "Warm and conversational",
            "fable": "Expressive and dramatic (British)",
            "onyx": "Deep and authoritative",
            "nova": "Friendly and upbeat",
            "shimmer": "Clear and gentle"
        }
        
        # TTS model
        self.model = "tts-1"  # or "tts-1-hd" for higher quality
    
    def generate_narration(self, text: str, voice: str = "onyx") -> str:
        """
        Generate audio narration for text.
        
        Args:
            text: The text to convert to speech
            voice: Voice to use (alloy, echo, fable, onyx, nova, shimmer)
            
        Returns:
            Base64 encoded MP3 audio string
        """
        if not self.client:
            raise ValueError("OpenAI API key not configured")
        
        # Validate voice
        if voice not in self.voices:
            voice = "onyx"  # Default to onyx for storytelling
        
        # Limit text length (TTS has a 4096 character limit)
        if len(text) > 4000:
            text = text[:4000] + "..."
        
        try:
            response = self.client.audio.speech.create(
                model=self.model,
                voice=voice,
                input=text,
                response_format="mp3"
            )
            
            # Get the audio bytes and encode to base64
            audio_bytes = response.content
            audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
            
            return audio_base64
            
        except Exception as e:
            raise ValueError(f"Failed to generate audio: {str(e)}")
    
    def generate_narration_with_metadata(self, text: str, voice: str = "onyx") -> dict:
        """
        Generate narration with additional metadata.
        
        Returns:
            dict with audio_base64, voice info, and text stats
        """
        if not self.client:
            return {
                "success": False,
                "error": "OpenAI API key not configured"
            }
        
        try:
            audio_base64 = self.generate_narration(text, voice)
            
            # Estimate duration (rough: ~150 words per minute)
            word_count = len(text.split())
            estimated_duration = (word_count / 150) * 60  # seconds
            
            return {
                "success": True,
                "audio_base64": audio_base64,
                "format": "mp3",
                "voice": voice,
                "voice_description": self.voices.get(voice, "Unknown"),
                "text_length": len(text),
                "word_count": word_count,
                "estimated_duration_seconds": round(estimated_duration, 1)
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def get_available_voices(self) -> list:
        """
        Get list of available voices with descriptions.
        """
        return [
            {
                "id": voice_id,
                "description": description,
                "recommended_for": self._get_voice_recommendation(voice_id)
            }
            for voice_id, description in self.voices.items()
        ]
    
    def _get_voice_recommendation(self, voice_id: str) -> str:
        """
        Get recommendation for when to use each voice.
        """
        recommendations = {
            "alloy": "General narration, neutral stories",
            "echo": "Dialogue-heavy stories, conversations",
            "fable": "Fantasy, dramatic stories, British settings",
            "onyx": "Epic tales, serious narratives, male protagonists",
            "nova": "Children's stories, light-hearted adventures",
            "shimmer": "Romance, gentle stories, female protagonists"
        }
        return recommendations.get(voice_id, "General use")
    
    def suggest_voice_for_genre(self, genre: str) -> dict:
        """
        Suggest the best voice for a story genre.
        """
        genre_voices = {
            "fantasy": {
                "primary": "fable",
                "alternative": "onyx",
                "reason": "Fable's expressive British tone suits fantasy narratives"
            },
            "sci-fi": {
                "primary": "alloy",
                "alternative": "echo",
                "reason": "Alloy's neutral tone works well for technical sci-fi"
            },
            "mystery": {
                "primary": "onyx",
                "alternative": "echo",
                "reason": "Onyx's deep voice creates suspenseful atmosphere"
            },
            "romance": {
                "primary": "shimmer",
                "alternative": "nova",
                "reason": "Shimmer's gentle tone enhances romantic moments"
            },
            "horror": {
                "primary": "onyx",
                "alternative": "fable",
                "reason": "Onyx's authoritative depth builds tension"
            },
            "adventure": {
                "primary": "nova",
                "alternative": "echo",
                "reason": "Nova's upbeat energy matches adventure excitement"
            }
        }
        
        return genre_voices.get(genre.lower(), {
            "primary": "onyx",
            "alternative": "alloy",
            "reason": "Onyx is versatile for most story types"
        })
