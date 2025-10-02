"""
jac_integration.py
Main Jac integration class that bridges Python Aider with Jac OSP/MTP components.
"""

import os
from typing import Any, Dict, List, Optional
from .integration import OSPInterface, MTPInterface, JacBridge

class JacIntegrationError(Exception):
    """Exception raised for Jac integration errors."""
    pass

class JacIntegration:
    """
    Main integration class that connects Aider's Python code with Jac OSP/MTP modules.
    Provides high-level interface for all Jac-based functionality.
    """

    def __init__(self, jac_workspace: Optional[str] = None, cache_dir: Optional[str] = None):
        """
        Initialize Jac integration.

        Args:
            jac_workspace: Path to Jac modules directory
            cache_dir: Cache directory for Jac operations
        """
        self.jac_workspace = jac_workspace or os.path.join(os.path.dirname(__file__), 'jac')
        self.cache_dir = cache_dir or os.path.join(os.path.dirname(__file__), '..', '.jac_cache')

        # Initialize interfaces
        self.osp = OSPInterface(jac_workspace=self.jac_workspace)
        self.mtp = MTPInterface(jac_workspace=self.jac_workspace)
        self.bridge = JacBridge(jac_workspace=self.jac_workspace)

    def handle_command(self, command: str) -> Dict[str, Any]:
        """
        Handle Jac-specific commands (e.g., /jac rank, /jac plan).

        Args:
            command: Command string starting with /jac

        Returns:
            Dict containing command result
        """
    parts = command.strip().split()
        """Handle /jac rank command."""
        try:
            rankings = self.osp.rank_files()
            return {
                "success": True,
                "command": "rank",
                "result": rankings
            }
        except Exception as e:
            return {"error": f"Ranking failed: {str(e)}"}

    def _handle_plan_command(self, args: List[str]) -> Dict[str, Any]:
        """Handle /jac plan command."""
        if not args:
            return {"error": "Plan command requires a task description"}

        task = " ".join(args)
        try:
            plan = self.mtp.plan_task(task)
            return {
                "success": True,
                "command": "plan",
                "task": task,
                "result": plan
            }
        except Exception as e:
            return {"error": f"Planning failed: {str(e)}"}

    def _handle_validate_command(self, args: List[str]) -> Dict[str, Any]:
        """Handle /jac validate command."""
        try:
            validation_result = self.mtp.validate_changes()
            return {
                "success": True,
                "command": "validate",
                "result": validation_result
            }
        except Exception as e:
            return {"error": f"Validation failed: {str(e)}"}

    def _handle_optimize_command(self, args: List[str]) -> Dict[str, Any]:
        """Handle /jac optimize command."""
        try:
            optimization_result = self.bridge.execute_script("token_optimizer.jac")
            return {
                "success": True,
                "command": "optimize",
                "result": optimization_result
            }
        except Exception as e:
            return {"error": f"Optimization failed: {str(e)}"}

    def get_repo_ranking(self, files: List[str], context: Optional[str] = None) -> Dict[str, float]:
        """
        Get OSP-based ranking of repository files.

        Args:
            files: List of file paths to rank
            context: Optional context for ranking

        Returns:
            Dict mapping file paths to ranking scores
        """
        try:
            return self.osp.rank_files(files, context)
        except Exception as e:
            raise JacIntegrationError(f"Failed to get repo ranking: {str(e)}")

    def plan_autonomous_task(self, task_description: str, context: Optional[str] = None) -> Dict[str, Any]:
        """
        Generate autonomous task plan using MTP.

        Args:
            task_description: Description of task to plan
            context: Optional context information

        Returns:
            Dict containing generated plan
        """
        try:
            return self.mtp.plan_task(task_description, context)
        except Exception as e:
            raise JacIntegrationError(f"Failed to plan autonomous task: {str(e)}")

    def validate_code_changes(self, files: List[str]) -> Dict[str, Any]:
        """
        Validate code changes using Jac validation walkers.

        Args:
            files: List of file paths to validate

        Returns:
            Dict containing validation results
        """
        try:
            return self.mtp.validate_changes(files)
        except Exception as e:
            raise JacIntegrationError(f"Failed to validate code changes: {str(e)}")

    def optimize_token_usage(self, content: str, target_tokens: int) -> Dict[str, Any]:
        """
        Optimize token usage for LLM interactions.

        Args:
            content: Content to optimize
            target_tokens: Target token count

        Returns:
            Dict containing optimized content and metrics
        """
        try:
            return self.bridge.execute_script("token_optimizer.jac", {
                "content": content,
                "target_tokens": target_tokens
            })
        except Exception as e:
            raise JacIntegrationError(f"Failed to optimize token usage: {str(e)}")

    def get_status(self) -> Dict[str, Any]:
        """
        Get current integration status.

        Returns:
            Dict containing status information
        """
    try:
    """
    Utility function for processing content with Jac.
    Used by llm.py for integration.

    Args:
        content: Content to process
        operation: Type of operation to perform

    Returns:
        Processing result
    """
    integration = JacIntegration()
