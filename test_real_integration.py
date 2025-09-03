#!/usr/bin/env python3
"""
Real integration test for Aider-Jac-OSP
Tests the actual working integration between Python and Jac components.
"""

import sys
import os
sys.path.insert(0, '.')

def test_real_integration():
    """Test actual working parts of the integration."""
    print("=== REAL AIDER-JAC-OSP INTEGRATION TEST ===\n")
    
    results = []
    
    # Test 1: Basic imports
    print("1. Testing basic imports...")
    try:
        import aider
        from aider.integration.jac_bridge import JacBridge
        from aider.integration.llm_client import LLMClient
        results.append(("✅ Basic imports", True))
        print("   ✅ All core imports successful")
    except Exception as e:
        results.append(("❌ Basic imports", False, str(e)))
        print(f"   ❌ Import failed: {e}")
    
    # Test 2: Jac runtime connectivity
    print("\n2. Testing Jac runtime connectivity...")
    try:
        import subprocess
        result = subprocess.run(['jac', '--version'], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            results.append(("✅ Jac runtime", True))
            print(f"   ✅ Jac runtime available: {result.stdout.strip().split()[2]}")
        else:
            results.append(("❌ Jac runtime", False, "Command failed"))
            print("   ❌ Jac runtime not accessible")
    except Exception as e:
        results.append(("❌ Jac runtime", False, str(e)))
        print(f"   ❌ Jac runtime error: {e}")
    
    # Test 3: Jac file execution
    print("\n3. Testing Jac file execution...")
    try:
        bridge = JacBridge()
        # Test with our working Jac files
        test_result = bridge.execute_jac_file('aider/jac/ranking_algorithms_new_syntax.jac')
        results.append(("✅ Jac execution", True))
        print("   ✅ Jac file execution successful")
    except Exception as e:
        results.append(("❌ Jac execution", False, str(e)))
        print(f"   ❌ Jac execution failed: {e}")
    
    # Test 4: LLM Client with OpenRouter
    print("\n4. Testing LLM client with OpenRouter...")
    try:
        client = LLMClient()
        if client.current_provider == "openrouter":
            results.append(("✅ LLM OpenRouter", True))
            print(f"   ✅ OpenRouter configured with model: {client.config.get('model')}")
        else:
            results.append(("❌ LLM OpenRouter", False, "Wrong provider"))
            print(f"   ❌ Wrong provider: {client.current_provider}")
    except Exception as e:
        results.append(("❌ LLM OpenRouter", False, str(e)))
        print(f"   ❌ LLM client error: {e}")
    
    # Test 5: Configuration files
    print("\n5. Testing configuration...")
    try:
        config_exists = os.path.exists(os.path.expanduser("~/.aider-genius/config.json"))
        if config_exists:
            results.append(("✅ Configuration", True))
            print("   ✅ Configuration file exists and accessible")
        else:
            results.append(("❌ Configuration", False, "File not found"))
            print("   ❌ Configuration file not found")
    except Exception as e:
        results.append(("❌ Configuration", False, str(e)))
        print(f"   ❌ Configuration error: {e}")
    
    # Summary
    print("\n" + "="*50)
    print("INTEGRATION TEST SUMMARY:")
    print("="*50)
    
    passed = 0
    total = len(results)
    
    for result in results:
        if len(result) == 2:
            test_name, success = result
            if success:
                passed += 1
            print(test_name)
        else:
            test_name, success, error = result
            if success:
                passed += 1
            print(f"{test_name} - {error}")
    
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 ALL TESTS PASSED - Your Aider-Jac-OSP integration is working!")
        return True
    else:
        print(f"⚠️  {total-passed} tests failed - Some functionality may not work correctly")
        return False

if __name__ == "__main__":
    success = test_real_integration()
    sys.exit(0 if success else 1)
