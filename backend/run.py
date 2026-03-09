import sys
from pathlib import Path

# Add the backend app directory to PYTHONPATH when running scripts
backend_path = Path(__file__).resolve().parent.parent
sys.path.append(str(backend_path / "app"))
