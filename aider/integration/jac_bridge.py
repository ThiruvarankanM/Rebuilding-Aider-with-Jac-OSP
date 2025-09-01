"""
jac_bridge.py
Python ↔ Jac bridge
Handles interaction between Python code and Jac walkers/functions.
Allows Python to execute Jac walkers, retrieve outputs, and pass data.
"""

import os
import subprocess
import json
from typing import Any, Dict, List, Optional

# Optional: path to Jac runtime executable
JAC_RUNTIME = os.environ.get("JAC_RUNTIME_PATH", "jac")

class JacBridgeError(Exception):
    """Custom exception for Jac bridge errors."""
    pass


class JacBridge:
    """
    Bridge class to interact with Jac scripts from Python.
    """

    def __init__(self, jac_workspace: Optional[str] = None):
        """
        Initialize Jac bridge.

        Args:
            jac_workspace: Path to the Jac project folder containing Jac files.
        """
        self.jac_workspace = jac_workspace or os.getcwd()

    def _run_jac_command(self, jac_file: str, args: Optional[Dict[str, Any]] = None) -> Any:
        """
        Run a Jac file and return its output.

        Args:
            jac_file: Name of the Jac file (with or without .jac extension)
            args: Dictionary of arguments to pass (optional)

        Returns:
            The parsed output from Jac (JSON-compatible)
        """
        # Ensure .jac extension
        if not jac_file.endswith('.jac'):
            jac_file += '.jac'
        
        # Build jac run command
        cmd = [JAC_RUNTIME, "run", jac_file]

        try:
            # Set environment variables for arguments if provided
            env = os.environ.copy()
            if args:
                env['JAC_ARGS'] = json.dumps(args)
            
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=self.jac_workspace, check=True, env=env)
            output = result.stdout.strip()
            if not output:
                return None
            try:
                return json.loads(output)
            except json.JSONDecodeError:
                return output
        except subprocess.CalledProcessError as e:
            raise JacBridgeError(f"Jac command failed: {e.stderr.strip()}") from e

    def execute_script(self, jac_file: str, args: Optional[Dict[str, Any]] = None) -> Any:
        """
        Execute a Jac script file.

        Args:
            jac_file: Name of the Jac file to execute
            args: Optional dictionary of arguments

        Returns:
            Result of the Jac script execution
        """
        return self._run_jac_command(jac_file, args)

    def call_walker(self, walker_name: str, function_name: str, args: Optional[Dict[str, Any]] = None) -> Any:
        """
        Execute a Jac walker file (legacy method name for compatibility).

        Args:
            walker_name: Name of the Jac walker file (without .jac extension)
            function_name: Function inside the walker (not used with jac run)
            args: Optional dictionary of arguments

        Returns:
            Result of the Jac function
        """
        return self.execute_script(walker_name, args)

    def test_connection(self) -> Dict[str, Any]:
        """
        Test the Jac bridge connection.

        Returns:
            Dict with success status and connection info
        """
        try:
            # Test by running a simple Jac command
            result = subprocess.run([JAC_RUNTIME, "--version"], capture_output=True, text=True, check=True)
            return {
                "success": True,
                "jac_version": result.stdout.strip(),
                "workspace": self.jac_workspace
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "workspace": self.jac_workspace
            }

    def call_multiple(self, calls: List[Dict[str, Any]]) -> List[Any]:
        """
        Call multiple Jac functions in sequence.

        Args:
            calls: List of dicts, each with keys: walker, func, args

        Returns:
            List of results in the same order
        """
        results = []
        for call in calls:
            walker = call.get("walker")
            func = call.get("func")
            args = call.get("args", {})
            results.append(self.call_walker(walker, func, args))
        return results


# Example usage:
if __name__ == "__main__":
    bridge = JacBridge(jac_workspace="./jac")

    try:
        result = bridge.call_walker("file_nodes", "list_all_nodes", args={"filter": "CodeFile"})
        print("Jac walker output:", result)
    except JacBridgeError as e:
        print("Error calling Jac walker:", e)
