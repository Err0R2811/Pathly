import sys
import os

# Add the backend directory to sys.path for test imports
backend_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(backend_path)

