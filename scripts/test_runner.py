"""
test_runner.py

Automates the execution of Aider unit tests, including OSP, Genius mode,
Jac integration, and token optimization tests.
"""

import subprocess
import sys
from pathlib import Path

# Define test directory
BASE_DIR = Path(__file__).parent.parent
TEST_DIR = BASE_DIR / "tests"

def run_tests():
    """Run all Python unit tests in the tests directory."""
    print(f"Running tests in: {TEST_DIR}")
    try:
        result = subprocess.run(
            [sys.executable, "-m", "unittest", "discover", "-s", str(TEST_DIR), "-p", "*.py"],
            capture_output=True,
            text=True,
            check=False,
        )
        print(result.stdout)
        if result.stderr:
            print("Errors / Warnings:")
            print(result.stderr)
    except Exception as e:
        print(f"Error running tests: {e}")

def main():
    print("Starting automated test runner...")
    run_tests()
    print("Test execution completed.")

if __name__ == "__main__":
    main()
