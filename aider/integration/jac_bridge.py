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

    def _run_jac_command(self, walker: str, func: str, args: Optional[Dict[str, Any]] = None) -> Any:
        """
        Run a Jac walker function and return its output.

        Args:
            walker: Name of the Jac walker file (without .jac)
            func: Function name inside the walker
            args: Dictionary of arguments to pass

        Returns:
            The parsed output from Jac (JSON-compatible)
        """
        args_json = json.dumps(args or {})
        cmd = [
            JAC_RUNTIME,
            "-w", walker,
            "-f", func,
            "-a", args_json
        ]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=self.jac_workspace, check=True)
            output = result.stdout.strip()
            if not output:
                return None
            try:
                return json.loads(output)
            except json.JSONDecodeError:
                return output
        except subprocess.CalledProcessError as e:
            raise JacBridgeError(f"Jac command failed: {e.stderr.strip()}") from e

    def call_walker(self, walker_name: str, function_name: str, args: Optional[Dict[str, Any]] = None) -> Any:
        """
        Public method to call a Jac walker function.

        Args:
            walker_name: Name of the Jac walker file (without .jac extension)
            function_name: Function inside the walker
            args: Optional dictionary of arguments

        Returns:
            Result of the Jac function
        """
        return self._run_jac_command(walker_name, function_name, args)

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
