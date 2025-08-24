"""
install_jac.py

This script installs and verifies the Jac runtime environment for Aider.

It ensures that the latest stable version of Jac is installed
and that the environment is correctly set up.
"""

import subprocess
import sys

def install_jac():
    """Install Jac via pip and verify installation."""
    try:
        print("Installing Jac runtime...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", "jaclang"])
        print("Jac installed successfully!")

        # Verify installation
        import jaclang
        print(f"Jac version: {jaclang.__version__}")
        print("Jac installation verified successfully!")

    except subprocess.CalledProcessError as e:
        print(f"Error during Jac installation: {e}")
        sys.exit(1)
    except ImportError:
        print("Jac could not be imported after installation. Please check your Python environment.")
        sys.exit(1)

if __name__ == "__main__":
    install_jac()
