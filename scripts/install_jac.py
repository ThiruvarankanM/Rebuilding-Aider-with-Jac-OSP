#!/usr/bin/env python3
"""
Jac Language Installation Script
Installs and verifies Jac runtime for Aider-Jac OSP integration.
"""

import subprocess
import sys
import os
from pathlib import Path

def check_python_version():
    """Ensure Python version compatibility."""
    if sys.version_info < (3, 8):
        print("❌ Python 3.8+ required for Jac language")
        return False
    
    print(f"✓ Python {sys.version_info.major}.{sys.version_info.minor} is compatible")
    return True

def install_jac():
    """Install Jac via pip with verification."""
    print("📦 Installing Jac Language Runtime...")
    
    try:
        # Install jaclang
        subprocess.run([
            sys.executable, "-m", "pip", "install", 
            "--upgrade", "jaclang"
        ], check=True, capture_output=True)
        
        print("✓ Jac language installed successfully")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to install Jac: {e}")
        return False

def verify_installation():
    """Verify Jac installation and show version."""
    print("\n🔍 Verifying installation...")
    
    try:
        # Test import
        import jaclang
        print(f"✓ Jac version: {jaclang.__version__}")
        
        # Test basic functionality without specific machine import
        print("✓ Jac runtime accessible")
        
        return True
        
    except ImportError as e:
        print(f"❌ Jac import failed: {e}")
        return False
    except Exception as e:
        print(f"❌ Jac verification failed: {e}")
        return False

def test_integration():
    """Test if Aider can load Jac integration."""
    print("\n🔗 Testing Aider-Jac integration...")
    
    try:
        # Change to project root
        project_root = Path(__file__).parent.parent
        sys.path.insert(0, str(project_root))
        
        from aider.integration.jac_bridge import JacIntegration
        print("✓ Jac bridge accessible")
        
        # Test basic integration
        integration = JacIntegration()
        print("✓ Jac integration initialized")
        
        return True
        
    except ImportError as e:
        print(f"⚠️  Aider-Jac integration not ready: {e}")
        print("   This is normal if you haven't set up the full project yet")
        return False
    except Exception as e:
        print(f"⚠️  Integration test failed: {e}")
        return False

def main():
    """Main installation process."""
    print("🎯 Jac Language Installation for Aider-OSP")
    print("=" * 45)
    
    # Check prerequisites
    if not check_python_version():
        sys.exit(1)
    
    # Install Jac
    if not install_jac():
        sys.exit(1)
    
    # Verify installation
    if not verify_installation():
        sys.exit(1)
    
    # Test integration (optional)
    test_integration()
    
    print("\n🎉 Installation complete!")
    print("\nNext steps:")
    print("1. Run: python scripts/setup_genius_mode.py")
    print("2. Test: python demo.py --quick")
    print("3. Demo: python live_demo.py")

if __name__ == "__main__":
    main()
