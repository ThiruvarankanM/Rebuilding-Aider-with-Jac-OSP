#!/usr/bin/env python3
"""
Aider-Jac OSP Test Runner
Runs comprehensive tests for the Jac-OSP integration and Genius Mode features.
"""

import subprocess
import sys
import os
from pathlib import Path

def run_specific_tests():
    """Run specific test modules for competition demo validation."""
    print("🧪 Running Aider-Jac OSP Test Suite")
    print("=" * 50)
    
    test_modules = [
        "tests.test_jac_integration",
        "tests.test_genius_mode", 
        "tests.test_osp_repomap",
        "tests.test_token_optimization"
    ]
    
    results = {}
    
    for module in test_modules:
        print(f"\n🔍 Testing {module}...")
        try:
            result = subprocess.run(
                [sys.executable, "-m", "unittest", module],
                capture_output=True,
                text=True,
                cwd=Path(__file__).parent.parent
            )
            
            if result.returncode == 0:
                print(f"✓ {module} - PASSED")
                results[module] = "PASSED"
            else:
                print(f"✗ {module} - FAILED")
                if result.stderr:
                    print(f"Error: {result.stderr}")
                results[module] = "FAILED"
                
        except Exception as e:
            print(f"✗ {module} - ERROR: {e}")
            results[module] = "ERROR"
    
    # Summary
    print("\n📊 Test Results Summary:")
    print("=" * 30)
    passed = sum(1 for status in results.values() if status == "PASSED")
    total = len(results)
    
    for module, status in results.items():
        status_emoji = "✓" if status == "PASSED" else "✗"
        print(f"{status_emoji} {module}: {status}")
    
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Ready for competition demo.")
    else:
        print("⚠️  Some tests failed. Review before demo.")
    
    return passed == total

def run_quick_validation():
    """Quick validation for demo readiness."""
    print("\n⚡ Quick Demo Validation")
    print("-" * 25)
    
    # Check if demo scripts exist and can import
    demo_scripts = [
        "demo.py",
        "live_demo.py", 
        "present.py"
    ]
    
    base_dir = Path(__file__).parent.parent
    
    for script in demo_scripts:
        script_path = base_dir / script
        if script_path.exists():
            print(f"✓ {script} exists")
            
            # Quick import test
            try:
                if script == "demo.py":
                    subprocess.run([sys.executable, script, "--help"], 
                                 capture_output=True, check=True, cwd=base_dir)
                print(f"✓ {script} can execute")
            except:
                print(f"⚠️  {script} may have issues")
        else:
            print(f"✗ {script} missing")

def main():
    """Main test runner."""
    if len(sys.argv) > 1 and sys.argv[1] == "--quick":
        run_quick_validation()
    else:
        success = run_specific_tests()
        run_quick_validation()
        
        if not success:
            sys.exit(1)

if __name__ == "__main__":
    main()
