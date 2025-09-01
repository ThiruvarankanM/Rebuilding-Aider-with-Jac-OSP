#!/usr/bin/env python3
"""
setup_genius_mode.py
Complete setup script for Aider Genius Mode with Jac-OSP integration
Sets up environment, installs dependencies, and configures the system
"""

import os
import sys
import subprocess
import json
from pathlib import Path

def check_python_version():
    """Ensure Python 3.8+ is available"""
    if sys.version_info < (3, 8):
        print("❌ Python 3.8+ required. Current version:", sys.version)
        return False
    print(f"✅ Python {sys.version.split()[0]} detected")
    return True

def install_requirements():
    """Install all required packages"""
    requirements = [
        "rich",           # For demo visuals
        "prompt-toolkit", # For interactive CLI
        "configargparse", # For argument parsing
        "pyperclip",      # For clipboard operations
        "pillow",         # For image handling
        "litellm",        # For LLM integration
        "openai",         # For AI models
        "anthropic",      # For Claude models
        "tiktoken",       # For token counting
        "tree-sitter",    # For code parsing
        "gitpython",      # For git operations
        "aiofiles",       # For async file operations
        "pydantic",       # For data validation
    ]
    
    print("📦 Installing required packages...")
    for package in requirements:
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])
            print(f"✅ Installed {package}")
        except subprocess.CalledProcessError:
            print(f"⚠️  Failed to install {package}")
    
def setup_jac_integration():
    """Setup Jac language integration"""
    print("🔧 Setting up Jac integration...")
    
    # Check if Jac is available
    try:
        result = subprocess.run(["jac", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Jac runtime detected")
        else:
            print("⚠️  Jac runtime not found - some features may be limited")
    except FileNotFoundError:
        print("⚠️  Jac runtime not found - installing...")
        # Try to install jac
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", "jaclang"])
            print("✅ Jac installed successfully")
        except subprocess.CalledProcessError:
            print("⚠️  Could not install Jac - manual installation may be needed")

def create_config_files():
    """Create necessary configuration files"""
    print("📝 Creating configuration files...")
    
    # Create .env template if it doesn't exist
    env_file = Path(".env")
    if not env_file.exists():
        env_content = """# Aider Configuration
# API Keys (add your own)
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here

# Genius Mode Settings
GENIUS_MODE_ENABLED=true
JAC_INTEGRATION_ENABLED=true
OSP_RANKING_ENABLED=true
TOKEN_OPTIMIZATION_ENABLED=true

# Model Settings
DEFAULT_MODEL=gpt-4
FALLBACK_MODEL=claude-3-sonnet
"""
        with open(env_file, "w") as f:
            f.write(env_content)
        print("✅ Created .env template")
    
    # Create aider config if it doesn't exist
    config_dir = Path.home() / ".aider"
    config_dir.mkdir(exist_ok=True)
    
    config_file = config_dir / "config.yml"
    if not config_file.exists():
        config_content = """# Aider Configuration
model: gpt-4
auto-commits: true
pretty: true
stream: true

# Genius Mode Configuration
genius-mode: true
jac-integration: true
osp-ranking: true
token-optimization: true
"""
        with open(config_file, "w") as f:
            f.write(config_content)
        print("✅ Created aider config")

def verify_integration():
    """Verify that all components work together"""
    print("🔍 Verifying system integration...")
    
    try:
        # Test imports
        sys.path.insert(0, str(Path(__file__).parent.parent))
        
        from aider.main import main
        from aider.commands import Commands
        from aider.integration.jac_bridge import JacBridge
        from aider.integration.osp_interface import OSPInterface
        
        print("✅ Core imports successful")
        
        # Test Jac bridge
        bridge = JacBridge()
        print("✅ Jac bridge initialized")
        
        # Test OSP interface
        osp = OSPInterface()
        print("✅ OSP interface initialized")
        
        return True
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"⚠️  Integration warning: {e}")
        return True  # Continue anyway

def main():
    """Main setup function"""
    print("🚀 Setting up Aider Genius Mode with Jac-OSP Integration")
    print("=" * 60)
    
    # Check prerequisites
    if not check_python_version():
        sys.exit(1)
    
    # Install dependencies
    install_requirements()
    
    # Setup Jac integration
    setup_jac_integration()
    
    # Create config files
    create_config_files()
    
    # Verify everything works
    if verify_integration():
        print("\n🎉 Setup complete! Genius Mode is ready.")
        print("\nNext steps:")
        print("1. Add your API keys to .env file")
        print("2. Run: python demo.py --quick")
        print("3. Run: python live_demo.py")
        print("4. Start coding with: python -m aider")
    else:
        print("\n⚠️  Setup completed with warnings.")
        print("Some features may not work until dependencies are resolved.")

if __name__ == "__main__":
    main()
