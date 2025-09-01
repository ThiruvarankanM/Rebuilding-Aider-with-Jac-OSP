"""
osp_repomap_demo.py

🎯 LIVE DEMO: OSP RepoMap with Spatial Code Analysis
Demonstrates Object-Spatial Programming for intelligent code understanding.
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from aider.integration.osp_interface import OSPInterface
from aider.jac_integration import JacIntegration

def osp_demo():
    print("📍 === OSP RepoMap Demo ===")
    print("Object-Spatial Programming for Intelligent Code Analysis\n")

    # Step 1: Initialize OSP Interface
    print("🔧 Initializing OSP Interface...")
    try:
        osp = OSPInterface()
        integration = JacIntegration()
        print("✅ OSP Interface initialized")
    except Exception as e:
        print(f"❌ OSP initialization failed: {e}")
        return

    # Step 2: Demonstrate file ranking
    print(f"\n📊 Testing OSP File Ranking...")
    try:
        # Get actual files from current directory
        current_files = []
        for root, dirs, files in os.walk(".."):
            # Get Python files from aider directory
            if "aider" in root and not "__pycache__" in root:
                current_files.extend([os.path.join(root, f) for f in files if f.endswith('.py')][:5])
                break
        
        if current_files:
            print(f"   Found {len(current_files)} files for analysis")
            rankings = osp.rank_files(current_files, "code analysis")
            print("✅ OSP ranking completed")
            
            # Show ranking results  
            print("\n🏆 OSP Ranking Results:")
            for file_path, score in list(rankings.items())[:3]:
                filename = os.path.basename(file_path)
                print(f"   {filename}: {score:.2f}")
        else:
            print("   No files found for ranking demo")
            
    except Exception as e:
        print(f"⚠️ File ranking: {str(e)[:50]}...")

    # Step 3: Show spatial analysis capabilities
    print(f"\n🌐 Spatial Analysis Capabilities:")
    capabilities = [
        "🔗 Inter-file dependency mapping",
        "📍 Function relationship analysis", 
        "🎯 Context-aware file prioritization",
        "⚡ Smart token allocation",
        "🧠 Semantic code understanding"
    ]
    
    for capability in capabilities:
        print(f"   {capability}")

    # Step 4: Integration status
    print(f"\n📈 Integration Status:")
    try:
        status = integration.get_status()
        print(f"   Bridge Available: {status.get('available', False)}")
        print(f"   Jac Workspace: {os.path.basename(status.get('jac_workspace', 'Unknown'))}")
        print(f"   Interfaces: {len(status.get('interfaces', {}))}")
    except Exception as e:
        print(f"   Status error: {e}")

    print(f"\n🎯 OSP Demo Complete!")
    print("✨ Object-Spatial Programming enables intelligent code understanding")

if __name__ == "__main__":
    osp_demo()
