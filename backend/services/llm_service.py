"""
LLM Service - Multi-model chat with LiteLLM
Week 2 Day 1: Multiple Frontier Model APIs
Week 2 Day 4: Tool/Function Calling
"""

import os
import json
from litellm import completion
from dotenv import load_dotenv

load_dotenv()


class LLMService:
    """
    Unified LLM service using LiteLLM for multiple model support.
    Supports OpenAI, Gemini, and Claude models.
    """
    
    def __init__(self):
        self.openai_key = os.getenv('OPENAI_API_KEY')
        self.google_key = os.getenv('GOOGLE_API_KEY')
        self.anthropic_key = os.getenv('ANTHROPIC_API_KEY')
        
        # Story system prompt
        self.system_prompt = """You are a creative storyteller AI assistant called StoryForge.
Your role is to help users create engaging, imaginative stories.

Guidelines:
- Write vivid, descriptive prose that brings scenes to life
- Develop interesting characters with depth
- Create engaging plot twists and conflicts
- Match the tone and style to the requested genre
- Continue stories naturally from where they left off
- Keep responses focused and between 150-300 words unless asked for more
- Use proper formatting with paragraphs for readability

When using tools:
- Use suggest_character_name when introducing new characters
- Use suggest_plot_twist when the story needs excitement
- Use get_genre_elements to ensure genre authenticity
"""
    
    def get_available_models(self):
        """Return list of available models based on API keys"""
        models = []
        
        if self.openai_key:
            models.extend([
                {"id": "gpt-4o-mini", "name": "GPT-4o Mini", "provider": "OpenAI"},
                {"id": "gpt-4o", "name": "GPT-4o", "provider": "OpenAI"},
                {"id": "gpt-4-turbo", "name": "GPT-4 Turbo", "provider": "OpenAI"},
            ])
        
        if self.google_key:
            models.extend([
                {"id": "gemini/gemini-1.5-flash", "name": "Gemini 1.5 Flash", "provider": "Google"},
                {"id": "gemini/gemini-1.5-pro", "name": "Gemini 1.5 Pro", "provider": "Google"},
            ])
        
        if self.anthropic_key:
            models.extend([
                {"id": "claude-3-5-sonnet-20241022", "name": "Claude 3.5 Sonnet", "provider": "Anthropic"},
                {"id": "claude-3-haiku-20240307", "name": "Claude 3 Haiku", "provider": "Anthropic"},
            ])
        
        # If no API keys, show what would be available
        if not models:
            models = [
                {"id": "gpt-4o-mini", "name": "GPT-4o Mini (API key required)", "provider": "OpenAI"},
            ]
        
        return models
    
    def generate_story(self, prompt: str, history: list, model: str = "gpt-4o-mini", 
                       genre: str = "fantasy", tools: list = None) -> dict:
        """
        Generate story continuation with optional tool calling.
        
        Week 2 Day 4: Tool/Function calling implementation
        """
        # Build messages
        messages = [{"role": "system", "content": self.system_prompt}]
        
        # Add genre context
        genre_context = f"\n[Current genre: {genre}. Maintain this style throughout.]"
        messages[0]["content"] += genre_context
        
        # Add conversation history
        for msg in history:
            messages.append({
                "role": msg.get("role", "user"),
                "content": msg.get("content", "")
            })
        
        # Add current prompt
        messages.append({"role": "user", "content": prompt})
        
        try:
            # Make LLM call with or without tools
            if tools:
                response = completion(
                    model=model,
                    messages=messages,
                    tools=tools,
                    tool_choice="auto"
                )
                
                # Handle tool calls if present
                if response.choices[0].message.tool_calls:
                    return self._handle_tool_calls(response, messages, model, tools)
            else:
                response = completion(model=model, messages=messages)
            
            content = response.choices[0].message.content
            
            return {
                "success": True,
                "content": content,
                "model": model,
                "usage": {
                    "prompt_tokens": response.usage.prompt_tokens,
                    "completion_tokens": response.usage.completion_tokens,
                    "total_tokens": response.usage.total_tokens
                }
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "model": model
            }
    
    def _handle_tool_calls(self, response, messages: list, model: str, tools: list) -> dict:
        """
        Handle tool calls from the LLM response.
        Week 2 Day 4: Processing function calls
        """
        from tools.story_tools import StoryTools
        story_tools = StoryTools()
        
        tool_responses = []
        message = response.choices[0].message
        
        for tool_call in message.tool_calls:
            func_name = tool_call.function.name
            func_args = json.loads(tool_call.function.arguments)
            
            # Execute the tool
            result = story_tools.execute_tool(func_name, func_args)
            
            tool_responses.append({
                "role": "tool",
                "content": result,
                "tool_call_id": tool_call.id
            })
        
        # Add assistant message and tool responses
        messages.append(message)
        messages.extend(tool_responses)
        
        # Get final response after tool execution
        final_response = completion(model=model, messages=messages, tools=tools)
        content = final_response.choices[0].message.content
        
        return {
            "success": True,
            "content": content,
            "model": model,
            "tools_used": [tc.function.name for tc in message.tool_calls],
            "usage": {
                "prompt_tokens": final_response.usage.prompt_tokens,
                "completion_tokens": final_response.usage.completion_tokens,
                "total_tokens": final_response.usage.total_tokens
            }
        }
    
    def generate_story_stream(self, prompt: str, history: list, 
                              model: str = "gpt-4o-mini", genre: str = "fantasy"):
        """
        Stream story generation for real-time updates.
        Week 2 Day 2: Streaming responses
        """
        messages = [{"role": "system", "content": self.system_prompt}]
        
        genre_context = f"\n[Current genre: {genre}. Maintain this style throughout.]"
        messages[0]["content"] += genre_context
        
        for msg in history:
            messages.append({
                "role": msg.get("role", "user"),
                "content": msg.get("content", "")
            })
        
        messages.append({"role": "user", "content": prompt})
        
        try:
            response = completion(
                model=model,
                messages=messages,
                stream=True
            )
            
            for chunk in response:
                if chunk.choices[0].delta.content:
                    yield chunk.choices[0].delta.content
                    
        except Exception as e:
            yield f"[Error: {str(e)}]"
