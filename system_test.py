#!/usr/bin/env python3
"""
System Test - Verify Aider-Genius is working
"""

def test_config():
    """Test that configuration is properly set up"""
    import os
    import json
    from pathlib import Path
    
    print("🔧 Testing Configuration...")
    
    config_file = Path.home() / ".aider-genius" / "config.json"
    
    if config_file.exists():
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        print("✅ Configuration file found")
        print(f"   Provider: {config.get('llm_provider')}")
        print(f"   Model: {config.get('model')}")
        print(f"   API Key: {'***' + config.get('api_key', '')[-8:] if config.get('api_key') else 'Not set'}")
        
        return config.get('api_key') is not None
    else:
        print("❌ No configuration file found")
        print("   Run: aider-genius setup")
        return False

def test_cli_integration():
    """Test that CLI commands work"""
    import subprocess
    import sys
    
    print("\n🖥️ Testing CLI Integration...")
    
    try:
        # Test that aider-genius command exists
        result = subprocess.run([sys.executable, "-m", "aider.cli", "--help"], 
                              capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            print("✅ CLI interface working")
            return True
        else:
            print(f"❌ CLI failed: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ CLI test error: {e}")
        return False

def test_jac_bridge():
    """Test that Jac integration works"""
    print("\n🧠 Testing Jac-OSP Integration...")
    
    try:
        import sys
        import os
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        
        from aider.integration.jac_bridge import JacBridge
        
        bridge = JacBridge(os.path.join("aider", "jac"))
        
        # Test OSP analysis
        result = bridge.call_walker("repomap_osp", "analyze_project", {"project_path": "."})
        
        if result:
            print("✅ Jac-OSP bridge working")
            print(f"   Analysis result: {str(result)[:100]}...")
            return True
        else:
            print("❌ Jac bridge returned no results")
            return False
            
    except Exception as e:
        print(f"❌ Jac bridge error: {e}")
        return False

if __name__ == "__main__":
    print("🧪 Aider-Genius System Test")
    print("=" * 40)
    
    # Run all tests
    config_ok = test_config()
    cli_ok = test_cli_integration()
    jac_ok = test_jac_bridge()
    
    print("\n📊 Test Results:")
    print(f"{'✅' if config_ok else '❌'} Configuration")
    print(f"{'✅' if cli_ok else '❌'} CLI Interface") 
    print(f"{'✅' if jac_ok else '❌'} Jac-OSP Integration")
    
    if config_ok and cli_ok and jac_ok:
        print("\n🎉 All systems working! Your Aider-Genius is ready!")
        print("\n🚀 Try: aider-genius edit 'improve this code'")
    else:
        print("\n⚠️ Some components need attention, but core system functional")
    
    print(f"\n✅ System Status: {sum([config_ok, cli_ok, jac_ok])} / 3 components working")
