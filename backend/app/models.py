from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, Integer, JSON, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime, timezone

Base = declarative_base()

class Roadmap(Base):
    __tablename__ = "roadmaps"
    id = Column(String, primary_key=True)
    user_id = Column(String, nullable=False)
    skill_name = Column(String, nullable=False)
    domain_type = Column(String, nullable=False)
    verification_score = Column(Integer)
    created_at = Column(String)  # placeholder, use DateTime in real
    modules = relationship("Module", back_populates="roadmap")

class Module(Base):
    __tablename__ = "modules"
    id = Column(String, primary_key=True)
    roadmap_id = Column(String, ForeignKey("roadmaps.id"), nullable=False)
    module_name = Column(String, nullable=False)
    level = Column(String, nullable=False)
    difficulty_score = Column(Integer)
    verification_alignment_score = Column(Integer)
    estimated_hours = Column(Integer)
    pedagogical_basis = Column(String)
    roadmap = relationship("Roadmap", back_populates="modules")
    sources = relationship("ResearchSource", back_populates="module")

class ResearchSource(Base):
    __tablename__ = "research_sources"
    id = Column(String, primary_key=True)
    module_id = Column(String, ForeignKey("modules.id"), nullable=False)
    title = Column(String)
    doi = Column(String)
    url = Column(String)
    abstract = Column(String)
    embedding = Column(JSON)  # placeholder for vector
    module = relationship("Module", back_populates="sources")
