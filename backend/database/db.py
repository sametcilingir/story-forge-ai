"""
Database Service - SQLite Integration
Week 2 Day 4: Database for Tool Calling & Persistence

Stores story history, user preferences, and generated content.
"""

import sqlite3
import os
from datetime import datetime
from typing import List, Dict, Optional


class Database:
    """
    SQLite database for storing stories and related data.
    Uses context managers for safe connection handling.
    """
    
    def __init__(self, db_path: str = None):
        if db_path is None:
            # Store in backend directory
            backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            db_path = os.path.join(backend_dir, 'stories.db')
        
        self.db_path = db_path
        self._initialize_database()
    
    def _get_connection(self):
        """Get a database connection with row factory."""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn
    
    def _initialize_database(self):
        """Create tables if they don't exist."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            # Stories table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS stories (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL,
                    content TEXT NOT NULL,
                    genre TEXT DEFAULT 'general',
                    model_used TEXT DEFAULT 'unknown',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    word_count INTEGER DEFAULT 0,
                    is_favorite INTEGER DEFAULT 0
                )
            ''')
            
            # Story chapters (for longer stories)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS chapters (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    story_id INTEGER NOT NULL,
                    chapter_number INTEGER NOT NULL,
                    title TEXT,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE
                )
            ''')
            
            # Generated images
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS images (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    story_id INTEGER,
                    scene_description TEXT,
                    style TEXT,
                    image_base64 TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE
                )
            ''')
            
            # Chat history (for conversation context)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS chat_history (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    story_id INTEGER,
                    role TEXT NOT NULL,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE
                )
            ''')
            
            conn.commit()
    
    # ==================== Story Operations ====================
    
    def save_story(self, title: str, content: str, genre: str = 'general', 
                   model_used: str = 'unknown') -> int:
        """
        Save a new story to the database.
        
        Returns:
            The ID of the newly created story
        """
        word_count = len(content.split())
        
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO stories (title, content, genre, model_used, word_count)
                VALUES (?, ?, ?, ?, ?)
            ''', (title, content, genre, model_used, word_count))
            conn.commit()
            return cursor.lastrowid
    
    def get_story(self, story_id: int) -> Optional[Dict]:
        """Get a story by ID."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('SELECT * FROM stories WHERE id = ?', (story_id,))
            row = cursor.fetchone()
            
            if row:
                return dict(row)
            return None
    
    def get_all_stories(self, limit: int = 50, offset: int = 0) -> List[Dict]:
        """Get all stories with pagination."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT id, title, genre, model_used, created_at, word_count, is_favorite
                FROM stories
                ORDER BY created_at DESC
                LIMIT ? OFFSET ?
            ''', (limit, offset))
            
            return [dict(row) for row in cursor.fetchall()]
    
    def update_story(self, story_id: int, title: str = None, content: str = None) -> bool:
        """Update a story's title and/or content."""
        updates = []
        values = []
        
        if title:
            updates.append("title = ?")
            values.append(title)
        
        if content:
            updates.append("content = ?")
            values.append(content)
            updates.append("word_count = ?")
            values.append(len(content.split()))
        
        if not updates:
            return False
        
        updates.append("updated_at = ?")
        values.append(datetime.now().isoformat())
        values.append(story_id)
        
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(f'''
                UPDATE stories
                SET {", ".join(updates)}
                WHERE id = ?
            ''', values)
            conn.commit()
            return cursor.rowcount > 0
    
    def delete_story(self, story_id: int) -> bool:
        """Delete a story and all related data."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('DELETE FROM stories WHERE id = ?', (story_id,))
            conn.commit()
            return cursor.rowcount > 0
    
    def toggle_favorite(self, story_id: int) -> bool:
        """Toggle the favorite status of a story."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                UPDATE stories
                SET is_favorite = CASE WHEN is_favorite = 1 THEN 0 ELSE 1 END
                WHERE id = ?
            ''', (story_id,))
            conn.commit()
            return cursor.rowcount > 0
    
    def get_favorite_stories(self) -> List[Dict]:
        """Get all favorite stories."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT id, title, genre, model_used, created_at, word_count
                FROM stories
                WHERE is_favorite = 1
                ORDER BY created_at DESC
            ''')
            return [dict(row) for row in cursor.fetchall()]
    
    def search_stories(self, query: str) -> List[Dict]:
        """Search stories by title or content."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT id, title, genre, model_used, created_at, word_count
                FROM stories
                WHERE title LIKE ? OR content LIKE ?
                ORDER BY created_at DESC
            ''', (f'%{query}%', f'%{query}%'))
            return [dict(row) for row in cursor.fetchall()]
    
    # ==================== Chat History Operations ====================
    
    def save_chat_message(self, story_id: int, role: str, content: str) -> int:
        """Save a chat message for conversation history."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO chat_history (story_id, role, content)
                VALUES (?, ?, ?)
            ''', (story_id, role, content))
            conn.commit()
            return cursor.lastrowid
    
    def get_chat_history(self, story_id: int) -> List[Dict]:
        """Get chat history for a story."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT role, content, created_at
                FROM chat_history
                WHERE story_id = ?
                ORDER BY created_at ASC
            ''', (story_id,))
            return [dict(row) for row in cursor.fetchall()]
    
    # ==================== Image Operations ====================
    
    def save_image(self, story_id: int, scene_description: str, 
                   style: str, image_base64: str) -> int:
        """Save a generated image."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO images (story_id, scene_description, style, image_base64)
                VALUES (?, ?, ?, ?)
            ''', (story_id, scene_description, style, image_base64))
            conn.commit()
            return cursor.lastrowid
    
    def get_story_images(self, story_id: int) -> List[Dict]:
        """Get all images for a story."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT id, scene_description, style, image_base64, created_at
                FROM images
                WHERE story_id = ?
                ORDER BY created_at ASC
            ''', (story_id,))
            return [dict(row) for row in cursor.fetchall()]
    
    # ==================== Statistics ====================
    
    def get_statistics(self) -> Dict:
        """Get overall statistics."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            # Total stories
            cursor.execute('SELECT COUNT(*) FROM stories')
            total_stories = cursor.fetchone()[0]
            
            # Total words
            cursor.execute('SELECT SUM(word_count) FROM stories')
            total_words = cursor.fetchone()[0] or 0
            
            # Stories by genre
            cursor.execute('''
                SELECT genre, COUNT(*) as count
                FROM stories
                GROUP BY genre
                ORDER BY count DESC
            ''')
            genres = {row[0]: row[1] for row in cursor.fetchall()}
            
            # Most used models
            cursor.execute('''
                SELECT model_used, COUNT(*) as count
                FROM stories
                GROUP BY model_used
                ORDER BY count DESC
            ''')
            models = {row[0]: row[1] for row in cursor.fetchall()}
            
            return {
                "total_stories": total_stories,
                "total_words": total_words,
                "stories_by_genre": genres,
                "stories_by_model": models,
                "average_word_count": round(total_words / max(total_stories, 1))
            }
