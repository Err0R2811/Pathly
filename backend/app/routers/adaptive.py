"""Adaptive difficulty router — personalized module ordering based on user mastery."""
from __future__ import annotations
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import ModuleSchema
from ..models import User, Module, Roadmap
from .auth import get_current_user

router = APIRouter(prefix="/adaptive", tags=["adaptive"])


@router.get("/roadmap/{roadmap_id}/modules")
async def get_adaptive_module_order(
    roadmap_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get modules ordered by adaptive difficulty based on user level and progress."""
    # Verify roadmap exists
    roadmap = db.query(Roadmap).filter(Roadmap.id == roadmap_id).first()
    if not roadmap:
        raise HTTPException(status_code=404, detail="Roadmap not found")
    
    # Get all modules for the roadmap
    modules = db.query(Module).filter(Module.roadmap_id == roadmap_id).all()
    
    # Adaptive ordering logic
    user_level = current_user.level
    
    # Sort modules based on user level and difficulty
    ordered_modules = []
    
    for module in modules:
        # Calculate a "fit score" for this module for the current user
        module_difficulty = module.difficulty_score or 50
        
        # Simple adaptive logic:
        # - Beginner users (level 1-4): start with easier modules (difficulty < 50)
        # - Intermediate users (level 5-9): balanced mix
        # - Advanced users (level 10+): can handle harder modules
        
        if user_level <= 4:
            # Prefer easier modules
            fit_score = 100 - module_difficulty
        elif user_level <= 9:
            # Balanced - prefer modules around user's level
            fit_score = 100 - abs(module_difficulty - 50)
        else:
            # Advanced users can handle harder content
            fit_score = module_difficulty
        
        ordered_modules.append({
            "module": module,
            "fit_score": fit_score,
        })
    
    # Sort by fit score (descending)
    ordered_modules.sort(key=lambda x: x["fit_score"], reverse=True)
    
    # Return ordered modules
    result = []
    for item in ordered_modules:
        module = item["module"]
        result.append({
            "id": module.id,
            "module_name": module.module_name,
            "level": module.level,
            "difficulty_score": module.difficulty_score,
            "estimated_hours": module.estimated_hours,
            "fit_score": item["fit_score"],
            "recommended": item["fit_score"] > 70,  # High fit score = recommended
        })
    
    return {
        "roadmap_id": roadmap_id,
        "user_level": user_level,
        "user_title": current_user.title,
        "modules": result,
    }
