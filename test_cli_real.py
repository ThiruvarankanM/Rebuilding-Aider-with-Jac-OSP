#!/usr/bin/env python3
"""
REAL Aider-Genius CLI Test 
Test the actual CLI commands with authentic LLM power
"""

import subprocess
import sys
import os

def run_command(cmd: str) -> tuple:
    """Run a command and return (success, output)"""
    print(f"\n🔧 Running: {cmd}")
    print("=" * 60)
    
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    success = result.returncode == 0
    output = result.stdout + result.stderr
    
    print(output)
    print("=" * 60)
    print(f"✅ Success: {success}\n")
    
    return success, output

def show_file_changes(filename: str):
    """Show current file contents"""
    print(f"\n📄 Current {filename}:")
    print("-" * 40)
    with open(filename, 'r') as f:
        content = f.read()
        print(content)
    print("-" * 40)

def main():
    """Test real CLI commands"""
    print("🚀 REAL AIDER-GENIUS CLI TESTING")
    print("Testing the actual command-line interface with authentic LLM power\n")
    
    # Reset files to clean state
    clean_simple1 = """class User:
    def __init__(self, name):
        self.name = name
        self.active = True"""
    
    clean_simple2 = """class Report:
    def get_status(self):
        return "status report\""""
    
    with open('simple1.py', 'w') as f:
        f.write(clean_simple1)
    with open('simple2.py', 'w') as f:
        f.write(clean_simple2)
    
    print("🔄 Reset files to clean state")
    show_file_changes('simple1.py')
    show_file_changes('simple2.py')
    
    # Test 1: Add a method 
    print("\n" + "="*80)
    print("TEST 1: Add user status method")
    print("="*80)
    success1, _ = run_command('aider-genius edit "add a method to get user status" --files simple1.py')
    show_file_changes('simple1.py')
    
    # Test 2: Cross-file import
    print("\n" + "="*80)
    print("TEST 2: Cross-file import and usage")
    print("="*80)
    success2, _ = run_command('aider-genius edit "import User class from simple1 and use it in Report class" --files simple1.py simple2.py')
    show_file_changes('simple1.py')
    show_file_changes('simple2.py')
    
    # Test 3: Analysis
    print("\n" + "="*80)
    print("TEST 3: Project analysis")
    print("="*80)
    success3, _ = run_command('aider-genius analyze --files simple1.py simple2.py')
    
    # Test 4: Rename class
    print("\n" + "="*80)
    print("TEST 4: Rename User class to Person")
    print("="*80)
    success4, _ = run_command('aider-genius edit "rename User class to Person" --files simple1.py')
    show_file_changes('simple1.py')
    
    # Test 5: Change property name
    print("\n" + "="*80)
    print("TEST 5: Change name property to username")
    print("="*80)
    success5, _ = run_command('aider-genius edit "change User class name property to username" --files simple1.py')
    show_file_changes('simple1.py')
    
    # Summary
    print("\n" + "="*80)
    print("🎯 CLI TEST RESULTS SUMMARY")
    print("="*80)
    tests = [
        ("Add method", success1),
        ("Cross-file import", success2), 
        ("Analysis", success3),
        ("Rename class", success4),
        ("Change property", success5)
    ]
    
    for test_name, success in tests:
        status = "✅ PASSED" if success else "❌ FAILED"
        print(f"  {test_name:20} {status}")
    
    total_passed = sum(1 for _, success in tests if success)
    print(f"\n📊 Results: {total_passed}/{len(tests)} tests passed")
    
    if total_passed >= 3:
        print("🎉 CLI system is working! Your aider-genius commands are functional!")
    else:
        print("⚠️  Some CLI functionality needs improvement")
        
    return total_passed >= 3

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
