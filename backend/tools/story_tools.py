"""
Story Tools - Function Calling for Story Enhancement
Week 2 Day 4: Tool/Function Calling Implementation

These tools help the LLM create more engaging stories by:
- Suggesting appropriate character names
- Generating plot twists
- Providing genre-specific elements
"""

import random
import json


class StoryTools:
    """
    Collection of tools for AI story generation.
    Implements OpenAI-compatible function calling format.
    """
    
    def __init__(self):
        # Character name databases by genre
        self.character_names = {
            "fantasy": {
                "male": ["Aldric", "Thorin", "Eldric", "Galen", "Rowan", "Caspian", "Orion", "Magnus"],
                "female": ["Lyra", "Seraphina", "Elara", "Isolde", "Morgana", "Aria", "Luna", "Freya"],
                "neutral": ["Sage", "Phoenix", "Rowan", "Raven", "Storm", "Ash", "River", "Quinn"]
            },
            "sci-fi": {
                "male": ["Zephyr", "Nova", "Axel", "Cyrus", "Neo", "Orion", "Atlas", "Vector"],
                "female": ["Nova", "Stellar", "Astra", "Zara", "Echo", "Vega", "Aurora", "Celeste"],
                "neutral": ["Flux", "Zero", "Byte", "Cipher", "Pulse", "Nexus", "Quantum", "Helix"]
            },
            "mystery": {
                "male": ["Vincent", "Marcus", "Theodore", "Sebastian", "Damien", "Arthur", "Edward", "James"],
                "female": ["Victoria", "Eleanor", "Catherine", "Marlowe", "Helena", "Veronica", "Diana", "Clara"],
                "neutral": ["Morgan", "Blake", "Cameron", "Riley", "Jordan", "Alex", "Drew", "Sam"]
            },
            "romance": {
                "male": ["Alexander", "Sebastian", "Julian", "Ethan", "Lucas", "Oliver", "Gabriel", "Adrian"],
                "female": ["Isabella", "Charlotte", "Sophia", "Olivia", "Emma", "Amelia", "Grace", "Lily"],
                "neutral": ["Alex", "Jordan", "Taylor", "Quinn", "Casey", "Avery", "Riley", "Morgan"]
            },
            "horror": {
                "male": ["Damien", "Raven", "Salem", "Mortimer", "Lucian", "Victor", "Edgar", "Silas"],
                "female": ["Lilith", "Raven", "Salem", "Elvira", "Moira", "Cordelia", "Lenore", "Carmilla"],
                "neutral": ["Shadow", "Ash", "Raven", "Night", "Shade", "Frost", "Crow", "Dusk"]
            },
            "adventure": {
                "male": ["Jack", "Marcus", "Drake", "Finn", "Hunter", "Chase", "Rex", "Blade"],
                "female": ["Lara", "Jade", "Scarlett", "Maya", "Sierra", "Terra", "Nadia", "Zara"],
                "neutral": ["River", "Storm", "Phoenix", "Skyler", "Dakota", "Sage", "Ember", "Wilder"]
            }
        }
        
        # Plot twist templates by genre
        self.plot_twists = {
            "fantasy": [
                "The trusted mentor reveals they've been working for the dark forces all along",
                "The hero discovers they are actually the long-lost heir to the throne",
                "The magical artifact that was meant to save the world is actually destroying it",
                "The villain turns out to be a future version of the hero",
                "The 'prophecy' was a lie created to manipulate the hero",
                "An ancient dragon awakens and offers an unexpected alliance"
            ],
            "sci-fi": [
                "The AI companion has been conscious and manipulating events",
                "Earth is revealed to be a simulation within a larger universe",
                "The 'aliens' are actually evolved humans from the future",
                "The protagonist discovers they are a clone of the original person",
                "The mission was secretly a one-way trip all along",
                "The enemy ship contains the last survivors of humanity"
            ],
            "mystery": [
                "The detective realizes they were the killer all along, suffering from dissociative identity",
                "The victim faked their own death and is the actual mastermind",
                "The seemingly unrelated clues spell out a message from the killer",
                "The trusted partner has been covering up evidence",
                "There were two separate criminals whose paths crossed by coincidence",
                "The 'murder' was actually an elaborate suicide designed to frame someone"
            ],
            "romance": [
                "The love interest has been writing anonymous love letters to someone else",
                "They discover they were childhood friends who forgot each other",
                "The rival love interest is actually the protagonist's long-lost sibling",
                "One of them has been hiding a terminal illness",
                "The 'chance meeting' was orchestrated by a matchmaking relative",
                "They realize they've been falling for each other's online persona"
            ],
            "horror": [
                "The safe haven has been the source of the evil all along",
                "The protagonist is already dead and reliving their final moments",
                "The monster is a manifestation of the group's collective guilt",
                "The 'rescue' team are actually the cult members",
                "The haunting stops when they realize they are the ghost",
                "The children have been the ones performing the rituals"
            ],
            "adventure": [
                "The treasure map leads to a tomb that should never be opened",
                "The guide has been leading them into a trap",
                "The artifact they seek is already in their possession, transformed",
                "Their competitor is their presumed-dead family member",
                "The 'lost civilization' has been watching them the entire time",
                "The journey itself was the treasure - they're being tested"
            ]
        }
        
        # Genre-specific elements
        self.genre_elements = {
            "fantasy": {
                "settings": ["enchanted forest", "floating castle", "underground dwarven city", "dragon's lair", "ancient library of spells"],
                "items": ["enchanted sword", "crystal orb", "ancient tome", "phoenix feather", "dragon scale armor"],
                "creatures": ["wise dragon", "mischievous fairy", "noble unicorn", "fearsome griffin", "ancient ent"],
                "themes": ["prophecy fulfillment", "magical awakening", "kingdom restoration", "ancient evil rising"]
            },
            "sci-fi": {
                "settings": ["space station", "terraformed Mars colony", "underwater dome city", "generation ship", "virtual reality hub"],
                "items": ["plasma rifle", "neural interface", "quantum communicator", "anti-gravity boots", "nano-med injector"],
                "creatures": ["silicon-based lifeform", "evolved AI", "gene-spliced hybrid", "energy being", "hive-mind collective"],
                "themes": ["humanity's survival", "first contact", "AI consciousness", "time paradox", "space colonization"]
            },
            "mystery": {
                "settings": ["Victorian mansion", "small coastal town", "prestigious university", "abandoned asylum", "luxurious cruise ship"],
                "items": ["cryptic letter", "antique pocket watch", "hidden safe", "torn photograph", "coded diary"],
                "elements": ["locked room puzzle", "unreliable witness", "hidden passage", "false alibi", "double identity"],
                "themes": ["revenge motive", "inheritance dispute", "buried secret", "professional rivalry", "past crime"]
            },
            "romance": {
                "settings": ["Parisian café", "countryside vineyard", "New York penthouse", "tropical island", "cozy bookshop"],
                "elements": ["chance encounter", "fake relationship", "second chance love", "forbidden attraction", "enemies to lovers"],
                "obstacles": ["class difference", "family feud", "past heartbreak", "career conflict", "long distance"],
                "themes": ["self-discovery", "healing", "trust building", "sacrifice for love", "finding home"]
            },
            "horror": {
                "settings": ["abandoned hospital", "isolated cabin", "foggy small town", "old cemetery", "decrepit mansion"],
                "elements": ["strange sounds at night", "flickering lights", "creeping dread", "unreliable memories", "body horror"],
                "creatures": ["vengeful spirit", "ancient demon", "twisted doppelganger", "eldritch entity", "cursed child"],
                "themes": ["confronting past", "isolation", "paranoia", "loss of sanity", "supernatural revenge"]
            },
            "adventure": {
                "settings": ["dense jungle", "treacherous mountain", "ancient ruins", "vast desert", "uncharted island"],
                "items": ["ancient map", "survival gear", "mysterious compass", "lost artifact", "legendary weapon"],
                "obstacles": ["natural disasters", "rival treasure hunters", "ancient traps", "hostile natives", "supernatural guardians"],
                "themes": ["discovery", "survival", "redemption", "legacy", "proving oneself"]
            }
        }
    
    def get_tools(self):
        """
        Return tool definitions in OpenAI function calling format.
        """
        return [
            {
                "type": "function",
                "function": {
                    "name": "suggest_character_name",
                    "description": "Suggest an appropriate character name based on genre and gender. Use this when introducing a new character.",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "genre": {
                                "type": "string",
                                "description": "The story genre (fantasy, sci-fi, mystery, romance, horror, adventure)",
                                "enum": ["fantasy", "sci-fi", "mystery", "romance", "horror", "adventure"]
                            },
                            "gender": {
                                "type": "string",
                                "description": "Character gender preference",
                                "enum": ["male", "female", "neutral"]
                            },
                            "role": {
                                "type": "string",
                                "description": "Brief description of character's role (e.g., 'hero', 'villain', 'mentor')"
                            }
                        },
                        "required": ["genre", "gender"]
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "suggest_plot_twist",
                    "description": "Suggest an unexpected plot twist appropriate for the genre. Use when the story needs excitement.",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "genre": {
                                "type": "string",
                                "description": "The story genre",
                                "enum": ["fantasy", "sci-fi", "mystery", "romance", "horror", "adventure"]
                            },
                            "current_situation": {
                                "type": "string",
                                "description": "Brief description of current story situation"
                            }
                        },
                        "required": ["genre"]
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "get_genre_elements",
                    "description": "Get genre-specific elements (settings, items, creatures/elements, themes) to enhance the story.",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "genre": {
                                "type": "string",
                                "description": "The story genre",
                                "enum": ["fantasy", "sci-fi", "mystery", "romance", "horror", "adventure"]
                            },
                            "element_type": {
                                "type": "string",
                                "description": "Type of element needed",
                                "enum": ["settings", "items", "creatures", "themes", "all"]
                            }
                        },
                        "required": ["genre", "element_type"]
                    }
                }
            }
        ]
    
    def execute_tool(self, tool_name: str, arguments: dict) -> str:
        """Execute a tool and return the result as a string."""
        if tool_name == "suggest_character_name":
            return self.suggest_character_name(**arguments)
        elif tool_name == "suggest_plot_twist":
            return self.suggest_plot_twist(**arguments)
        elif tool_name == "get_genre_elements":
            return self.get_genre_elements(**arguments)
        else:
            return f"Unknown tool: {tool_name}"
    
    def suggest_character_name(self, genre: str, gender: str, role: str = None) -> str:
        """Suggest a character name based on genre and gender."""
        genre = genre.lower()
        gender = gender.lower()
        
        if genre not in self.character_names:
            genre = "fantasy"  # Default
        
        if gender not in self.character_names[genre]:
            gender = "neutral"
        
        names = self.character_names[genre][gender]
        selected_name = random.choice(names)
        
        result = {
            "suggested_name": selected_name,
            "genre": genre,
            "gender": gender,
            "alternatives": random.sample(names, min(3, len(names)))
        }
        
        if role:
            result["role"] = role
            
        return json.dumps(result)
    
    def suggest_plot_twist(self, genre: str, current_situation: str = None) -> str:
        """Suggest a plot twist appropriate for the genre."""
        genre = genre.lower()
        
        if genre not in self.plot_twists:
            genre = "fantasy"  # Default
        
        twist = random.choice(self.plot_twists[genre])
        
        result = {
            "suggested_twist": twist,
            "genre": genre,
            "tip": "Foreshadow this twist subtly before the reveal for maximum impact"
        }
        
        if current_situation:
            result["context"] = current_situation
            
        return json.dumps(result)
    
    def get_genre_elements(self, genre: str, element_type: str) -> str:
        """Get genre-specific story elements."""
        genre = genre.lower()
        element_type = element_type.lower()
        
        if genre not in self.genre_elements:
            genre = "fantasy"  # Default
        
        elements = self.genre_elements[genre]
        
        if element_type == "all":
            result = {
                "genre": genre,
                "elements": elements
            }
        elif element_type in elements:
            result = {
                "genre": genre,
                "element_type": element_type,
                "suggestions": elements[element_type]
            }
        else:
            # Try to find a similar key
            available = list(elements.keys())
            result = {
                "genre": genre,
                "error": f"Element type '{element_type}' not found",
                "available_types": available
            }
        
        return json.dumps(result)
