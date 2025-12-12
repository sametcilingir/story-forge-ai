"""
StoryForge AI - Flask Backend
Week 2 LLM Engineering Project

A multi-modal AI story creation backend with:
- Multiple LLM support via LiteLLM
- DALL-E image generation
- OpenAI TTS for narration
- Tool calling for story enhancement
- SQLite for story persistence
"""

import os
import json
from flask import Flask, request, jsonify, Response, send_file
from flask_cors import CORS
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Configuration
# Using 5001 instead of 5000 to avoid macOS AirPlay Receiver conflict
PORT = int(os.getenv('PORT', 5001))
DEBUG = os.getenv('DEBUG', 'True').lower() == 'true'

# Import services (will be created next)
from services.llm_service import LLMService
from services.image_service import ImageService
from services.audio_service import AudioService
from database.db import Database
from tools.story_tools import StoryTools

# Initialize services
llm_service = LLMService()
image_service = ImageService()
audio_service = AudioService()
db = Database()
story_tools = StoryTools()


@app.route('/')
def root():
    """Health check endpoint"""
    return jsonify({
        "app": "StoryForge AI",
        "version": "1.0.0",
        "status": "running",
        "endpoints": [
            "POST /api/story/generate",
            "POST /api/story/illustrate",
            "POST /api/story/narrate",
            "POST /api/story/save",
            "GET /api/story/history",
            "GET /api/models"
        ]
    })


@app.route('/api/models', methods=['GET'])
def get_models():
    """Get available AI models"""
    return jsonify({
        "models": llm_service.get_available_models()
    })


@app.route('/api/story/generate', methods=['POST'])
def generate_story():
    """
    Generate story continuation using LLM with tool calling
    
    Request body:
    {
        "prompt": "User's story prompt or continuation request",
        "history": [{"role": "user/assistant", "content": "..."}],
        "model": "gpt-4o-mini" (optional),
        "genre": "fantasy" (optional)
    }
    """
    try:
        data = request.json
        prompt = data.get('prompt', '')
        history = data.get('history', [])
        model = data.get('model', 'gpt-4o-mini')
        genre = data.get('genre', 'fantasy')
        
        if not prompt:
            return jsonify({"error": "Prompt is required"}), 400
        
        # Generate story with tool calling support
        result = llm_service.generate_story(
            prompt=prompt,
            history=history,
            model=model,
            genre=genre,
            tools=story_tools.get_tools()
        )
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/story/generate/stream', methods=['POST'])
def generate_story_stream():
    """
    Stream story generation for real-time UI updates
    """
    try:
        data = request.json
        prompt = data.get('prompt', '')
        history = data.get('history', [])
        model = data.get('model', 'gpt-4o-mini')
        genre = data.get('genre', 'fantasy')
        
        if not prompt:
            return jsonify({"error": "Prompt is required"}), 400
        
        def generate():
            for chunk in llm_service.generate_story_stream(
                prompt=prompt,
                history=history,
                model=model,
                genre=genre
            ):
                yield f"data: {json.dumps({'content': chunk})}\n\n"
            yield "data: [DONE]\n\n"
        
        return Response(generate(), mimetype='text/event-stream')
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/story/illustrate', methods=['POST'])
def illustrate_story():
    """
    Generate illustration for a story scene using DALL-E
    
    Request body:
    {
        "scene_description": "A brave knight facing a dragon...",
        "style": "fantasy art" (optional)
    }
    """
    try:
        data = request.json
        scene = data.get('scene_description', '')
        style = data.get('style', 'digital fantasy art, vibrant colors')
        
        if not scene:
            return jsonify({"error": "Scene description is required"}), 400
        
        result = image_service.generate_illustration(scene, style)
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/story/narrate', methods=['POST'])
def narrate_story():
    """
    Generate audio narration for story text using OpenAI TTS
    
    Request body:
    {
        "text": "The story text to narrate...",
        "voice": "onyx" (optional: alloy, echo, fable, onyx, nova, shimmer)
    }
    """
    try:
        data = request.json
        text = data.get('text', '')
        voice = data.get('voice', 'onyx')
        
        if not text:
            return jsonify({"error": "Text is required"}), 400
        
        audio_data = audio_service.generate_narration(text, voice)
        
        # Return base64 encoded audio
        return jsonify({
            "audio_base64": audio_data,
            "format": "mp3"
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/story/save', methods=['POST'])
def save_story():
    """
    Save story to database
    
    Request body:
    {
        "title": "My Epic Adventure",
        "content": "Full story content...",
        "genre": "fantasy",
        "model_used": "gpt-4o-mini"
    }
    """
    try:
        data = request.json
        title = data.get('title', 'Untitled Story')
        content = data.get('content', '')
        genre = data.get('genre', 'general')
        model_used = data.get('model_used', 'unknown')
        
        if not content:
            return jsonify({"error": "Content is required"}), 400
        
        story_id = db.save_story(title, content, genre, model_used)
        
        return jsonify({
            "success": True,
            "story_id": story_id,
            "message": "Story saved successfully"
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/story/history', methods=['GET'])
def get_story_history():
    """Get all saved stories"""
    try:
        stories = db.get_all_stories()
        return jsonify({"stories": stories})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/story/<int:story_id>', methods=['GET'])
def get_story(story_id):
    """Get a specific story by ID"""
    try:
        story = db.get_story(story_id)
        if story:
            return jsonify(story)
        return jsonify({"error": "Story not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/story/<int:story_id>', methods=['DELETE'])
def delete_story(story_id):
    """Delete a story"""
    try:
        success = db.delete_story(story_id)
        if success:
            return jsonify({"success": True, "message": "Story deleted"})
        return jsonify({"error": "Story not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    print(f"""
    ╔══════════════════════════════════════════╗
    ║       StoryForge AI Backend              ║
    ║       Week 2 LLM Engineering             ║
    ╠══════════════════════════════════════════╣
    ║  Running on http://localhost:{PORT}        ║
    ║  Debug mode: {DEBUG}                       ║
    ╚══════════════════════════════════════════╝
    """)
    app.run(host='0.0.0.0', port=PORT, debug=DEBUG)
