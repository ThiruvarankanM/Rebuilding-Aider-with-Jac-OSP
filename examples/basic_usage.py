"""
basic_usage.py

🎯 BASIC DEMO: Jac-OSP Enhanced Aider Usage
Shows how to use the enhanced Aider with Jac Object-Spatial Programming.
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from aider.jac_integration import JacIntegration, process_with_jac
from aider.genius import GeniusConfig

def basic_demo():
    print("🚀 === Enhanced Aider Basic Usage Demo ===")
    print("Jac-OSP Integration for Smarter Code Assistance\n")

    # Step 1: Initialize enhanced components
    print("🔧 Initializing Jac-OSP components...")
    try:
        integration = JacIntegration()
        config = GeniusConfig()
        print("✅ Enhanced Aider components ready")
    except Exception as e:
        print(f"❌ Initialization failed: {e}")
        return

    # Step 2: Show enhanced capabilities
    print(f"\n⚡ Enhanced Capabilities vs Traditional Aider:")
    
    comparisons = [
        ("File Selection", "Manual browsing", "OSP spatial ranking"),
        ("Task Planning", "User instructions", "MTP autonomous planning"), 
        ("Context Management", "Fixed token limits", "Smart optimization"),
        ("Operation Mode", "Interactive assistance", "Autonomous execution")
    ]
    
    for feature, traditional, enhanced in comparisons:
        print(f"   {feature}:")
        print(f"     Traditional: {traditional}")
        print(f"     Jac-OSP: {enhanced}")
        print()

    # Step 3: Test /jac commands
    print(f"🎮 Testing Enhanced Commands:")
    
    test_commands = [
        ("/jac rank", "OSP file ranking"),
        ("/jac validate", "MTP validation"),
        ("/jac plan optimize code", "Autonomous planning")
    ]
    
    for cmd, description in test_commands:
        try:
            result = integration.handle_command(cmd)
            success = result.get('success', False)
            print(f"   {cmd}: {'✅ Working' if success else '⚠️ Ready'} - {description}")
        except Exception as e:
            print(f"   {cmd}: ⚠️ {str(e)[:30]}...")

    # Step 4: Show configuration  
    print(f"\n⚙️ Genius Mode Configuration:")
    for key, value in config.config.items():
        print(f"   {key}: {value}")

    print(f"\n🎯 Basic Demo Complete!")
    print("✨ Your Aider is now enhanced with autonomous intelligence!")

if __name__ == "__main__":
    basic_demo()
