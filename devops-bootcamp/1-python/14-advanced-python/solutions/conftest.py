# Lets pytest import the lab modules in this folder when run from anywhere.
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
