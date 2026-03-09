from pathlib import Path
import sys

# Ensure the app directory is on the PYTHONPATH
top_dir = Path(__file__).resolve().parents[2]
app_dir = top_dir / "app"
sys.path.append(str(app_dir))
