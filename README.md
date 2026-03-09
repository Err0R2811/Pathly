# Pathly - Gamified Learning Platform

Pathly is a comprehensive, gamified learning platform designed to provide interactive and personalized AI-generated educational curriculums. The platform consists of a modern mobile frontend built with Flutter and a robust Python backend powered by FastAPI.

## Project Structure

The repository is structured into two main components:

- `app/` - The Flutter mobile application.
- `backend/` - The FastAPI Python backend service.
- `architecture/` - Architecture diagrams and system design documentation.
- `docs/` - Additional project documentation.

## Tech Stack

### Frontend (Flutter App)
- **Framework:** Flutter (v3.24.0+) / Dart (v3.5.0+)
- **State Management:** Riverpod (`flutter_riverpod`, `riverpod_annotation`)
- **Routing:** GoRouter
- **Networking:** Dio & HTTP
- **Local Storage:** Hive (`hive_flutter`)
- **UI & Animations:** Google Fonts, Flutter SVG, Cached Network Image, Shimmer, Percent Indicator, Flutter Animate

### Backend (FastAPI Service)
- **Framework:** FastAPI (Python 3.10+)
- **Server:** Uvicorn
- **Database ORM:** SQLAlchemy (Async with `aiosqlite`)
- **Migrations:** Alembic
- **Data Validation:** Pydantic
- **HTTP Client:** HTTPX
- **Key Features:** AI curriculum generation

## Getting Started

### Prerequisites
- Python 3.10 or higher
- Flutter SDK (v3.24.0 or higher)
- Poetry (for backend dependency management)

### Setting up the Backend
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies using Poetry:
   ```bash
   poetry install
   ```
3. Run database migrations:
   ```bash
   poetry run alembic upgrade head
   ```
4. Start the development server:
   ```bash
   poetry run uvicorn app.main:app --reload
   ```
   *Note: You may need to configure environment variables (e.g., for AI model endpoints like OpenRouter) before starting the server.*

### Setting up the Frontend App
1. Navigate to the app directory:
   ```bash
   cd app
   ```
2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Generate required code (for Freezed, Riverpod, etc.):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Contributing
Contributions are welcome. Please ensure that all new code follows the existing style guidelines and includes appropriate tests. Use `flutter analyze` for the frontend and `pytest` for the backend before submitting changes.
