"""
genius_mode_demo.py

🚀 LIVE DEMO: Genius Mode with Jac-OSP Integration
Demonstrates autonomous AI coding with Object-Spatial Programming.
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from aider.jac_integration import JacIntegration
from aider.genius import GeniusMode, GeniusConfig

def genius_demo():
    print("🤖 === Aider Genius Mode Demo ===")
    print("Autonomous AI Coding with Jac-OSP Integration\n")

    # Step 1: Initialize Genius Mode components
    print("🔧 Initializing Genius Mode...")
    try:
        config = GeniusConfig()
        integration = JacIntegration()
        print("✅ Genius Mode components initialized")
        print(f"   Configuration: {len(config.config)} settings loaded")
        print(f"   Jac workspace: {integration.jac_workspace}")
    except Exception as e:
        print(f"❌ Initialization failed: {e}")
        return

    # Step 2: Show configuration
    print(f"\n⚙️ Genius Mode Configuration:")
    for key, value in config.config.items():
        print(f"   {key}: {value}")

    # Step 3: Test OSP file ranking
    print(f"\n📍 Testing OSP File Ranking...")
    try:
        # Simulate file ranking
        test_files = ["main.py", "utils.py", "models.py", "tests.py"]
        ranking_result = integration.handle_command("/jac rank")
        print("✅ OSP ranking system operational")
        print(f"   Command result: {type(ranking_result).__name__}")
    except Exception as e:
        print(f"⚠️ OSP ranking: {str(e)[:50]}...")

    # Step 4: Test MTP autonomous planning  
    print(f"\n🧠 Testing MTP Autonomous Planning...")
    try:
        plan_result = integration.handle_command("/jac plan Refactor error handling")
        print("✅ MTP planning system operational")
        print(f"   Planning result: {type(plan_result).__name__}")
    except Exception as e:
        print(f"⚠️ MTP planning: {str(e)[:50]}...")

    # Step 5: Test token optimization
    print(f"\n⚡ Testing Token Optimization...")
    try:
        optimization_result = integration.handle_command("/jac optimize")
        print("✅ Token optimization operational")
        print(f"   Optimization result: {type(optimization_result).__name__}")
    except Exception as e:
        print(f"⚠️ Token optimization: {str(e)[:50]}...")

    # Step 6: Show integration status
    print(f"\n📊 Integration Status:")
    try:
        status = integration.get_status()
        print(f"   Available: {status.get('available', False)}")
        print(f"   Interfaces: {list(status.get('interfaces', {}).keys())}")
    except Exception as e:
        print(f"   Status check failed: {e}")

    print(f"\n🎯 Demo Complete!")
    print("✨ Jac-OSP integration transforms Aider into autonomous AI agent")

if __name__ == "__main__":
    genius_demo()
