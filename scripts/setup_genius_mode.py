"""
setup_genius_mode.py

This script sets up the Genius / MTP autonomous agent environment
for Aider. It ensures required files, folders, and configuration
settings are in place.
"""

import os
import shutil
from pathlib import Path

# Define important directories
BASE_DIR = Path(__file__).parent.parent
JAC_DIR = BASE_DIR / "aider" / "jac"
GENIUS_DATA_DIR = BASE_DIR / "aider" / "jac" / "genius_data"

def create_genius_folders():
    """Create necessary folders for Genius mode."""
    try:
        GENIUS_DATA_DIR.mkdir(parents=True, exist_ok=True)
        print(f"Genius data directory ready at: {GENIUS_DATA_DIR}")
    except Exception as e:
        print(f"Error creating Genius mode directories: {e}")

def copy_default_prompts():
    """Copy default MTP prompts to Genius data folder if not present."""
    try:
        default_prompts = JAC_DIR / "mtp_prompts.jac"
        destination = GENIUS_DATA_DIR / "mtp_prompts.jac"
        if not destination.exists():
            shutil.copy(default_prompts, destination)
            print("Default MTP prompts copied to Genius data folder.")
        else:
            print("Default MTP prompts already present.")
    except Exception as e:
        print(f"Error copying default prompts: {e}")

def main():
    """Main setup routine."""
    print("Setting up Genius / MTP autonomous agent...")
    create_genius_folders()
    copy_default_prompts()
    print("Genius mode setup completed successfully.")

if __name__ == "__main__":
    main()
