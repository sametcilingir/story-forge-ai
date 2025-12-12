# StoryForge AI - Backend

Flask backend for the StoryForge AI multi-modal story creation application.

## Setup

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
# Create .env file with:
OPENAI_API_KEY=sk-your-key
GOOGLE_API_KEY=your-google-key  # Optional
ANTHROPIC_API_KEY=your-anthropic-key  # Optional
PORT=5001  # Using 5001 to avoid macOS AirPlay Receiver conflict on port 5000
DEBUG=True

# Run server
python app.py
```

## API Endpoints

- `GET /` - Health check
- `GET /api/models` - Available AI models
- `POST /api/story/generate` - Generate story
- `POST /api/story/generate/stream` - Stream story (SSE)
- `POST /api/story/illustrate` - Generate DALL-E image
- `POST /api/story/narrate` - Generate TTS audio
- `POST /api/story/save` - Save story
- `GET /api/story/history` - Get saved stories

## Week 2 Features

- **LiteLLM**: Multi-model support (OpenAI, Gemini, Claude)
- **Tool Calling**: Character names, plot twists
- **DALL-E 3**: Image generation
- **OpenAI TTS**: Voice narration
- **SQLite**: Story persistence
