"""Authentication router — login, register, user management."""

from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jwt.exceptions import PyJWTError
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import User
from ..schemas import (
    AuthResponse,
    UserLoginRequest,
    UserRegisterRequest,
    UserResponse,
)
from ..settings import get_settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

settings = get_settings()
SECRET_KEY = settings.jwt_secret_key
ALGORITHM = settings.jwt_algorithm
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

router = APIRouter(prefix="/auth", tags=["auth"])


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire, "type": "access"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_token(token: str) -> str | None:
    """Verify JWT token and return user_id if valid."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        token_type: str = payload.get("type")
        if user_id is None or token_type != "access":
            return None
        return user_id
    except PyJWTError:
        return None


async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    """FastAPI dependency to get current authenticated user."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    user_id = verify_token(token)
    if user_id is None:
        raise credentials_exception

    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise credentials_exception

    return user


async def get_current_user_optional(
    token: str | None = Depends(OAuth2PasswordBearer(tokenUrl="auth/token", auto_error=False)),
    db: Session = Depends(get_db),
) -> User | None:
    """Optional authentication - returns None if no valid token provided."""
    if token is None:
        return None

    try:
        user_id = verify_token(token)
        if user_id is None:
            return None

        user = db.query(User).filter(User.id == user_id).first()
        return user
    except Exception:
        return None


@router.post("/register", response_model=AuthResponse, status_code=201)
async def register(body: UserRegisterRequest, db: Session = Depends(get_db)):
    """Register a new user."""
    # Check if email already exists
    existing_user = db.query(User).filter(User.email == body.email).first()
    if existing_user:
        raise HTTPException(status_code=409, detail="Email already registered")

    # Create new user
    user_id = str(uuid.uuid4())
    hashed_password = get_password_hash(body.password)

    db_user = User(
        id=user_id,
        email=body.email,
        name=body.name,
        hashed_password=hashed_password,
        created_at=datetime.now(timezone.utc).isoformat(),
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    # Generate JWT tokens
    access_token = create_access_token(data={"sub": user_id})
    refresh_token = create_refresh_token(data={"sub": user_id})

    return AuthResponse(
        access_token=access_token,
        token_type="bearer",
        refresh_token=refresh_token,
        user=UserResponse(
            id=db_user.id,
            email=db_user.email,
            name=db_user.name,
            avatar_url=db_user.avatar_url,
            title=db_user.title,
            level=db_user.level,
            xp=db_user.xp,
            streak_days=db_user.streak_days,
            total_minutes=db_user.total_minutes,
            lessons_completed=db_user.lessons_completed,
            created_at=db_user.created_at,
        ),
    )


@router.post("/login", response_model=AuthResponse)
async def login(body: UserLoginRequest, db: Session = Depends(get_db)):
    """Login an existing user."""
    # Find user by email
    user = db.query(User).filter(User.email == body.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    # Verify password
    if not verify_password(body.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    # Generate JWT tokens
    access_token = create_access_token(data={"sub": user.id})
    refresh_token = create_refresh_token(data={"sub": user.id})

    return AuthResponse(
        access_token=access_token,
        token_type="bearer",
        refresh_token=refresh_token,
        user=UserResponse(
            id=user.id,
            email=user.email,
            name=user.name,
            avatar_url=user.avatar_url,
            title=user.title,
            level=user.level,
            xp=user.xp,
            streak_days=user.streak_days,
            total_minutes=user.total_minutes,
            lessons_completed=user.lessons_completed,
            created_at=user.created_at,
        ),
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """Get current user profile (requires authentication)."""
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        name=current_user.name,
        avatar_url=current_user.avatar_url,
        title=current_user.title,
        level=current_user.level,
        xp=current_user.xp,
        streak_days=current_user.streak_days,
        total_minutes=current_user.total_minutes,
        lessons_completed=current_user.lessons_completed,
        created_at=current_user.created_at,
    )


@router.post("/refresh", response_model=AuthResponse)
async def refresh_token(body: dict, db: Session = Depends(get_db)):
    """Refresh access token using refresh token."""
    refresh_token = body.get("refresh_token")
    if not refresh_token:
        raise HTTPException(status_code=422, detail="refresh_token is required")
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        token_type: str = payload.get("type")
        if user_id is None or token_type != "refresh":
            raise HTTPException(status_code=401, detail="Invalid refresh token")
    except PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    # Generate new tokens
    access_token = create_access_token(data={"sub": user_id})
    new_refresh_token = create_refresh_token(data={"sub": user_id})

    return AuthResponse(
        access_token=access_token,
        token_type="bearer",
        refresh_token=new_refresh_token,
        user=UserResponse(
            id=user.id,
            email=user.email,
            name=user.name,
            avatar_url=user.avatar_url,
            title=user.title,
            level=user.level,
            xp=user.xp,
            streak_days=user.streak_days,
            total_minutes=user.total_minutes,
            lessons_completed=user.lessons_completed,
            created_at=user.created_at,
        ),
    )
