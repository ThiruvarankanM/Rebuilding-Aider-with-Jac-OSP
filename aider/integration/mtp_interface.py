"""
mtp_interface.py
High-level interface for Genius/MTP autonomous agent.
Provides Python-friendly API to interact with Jac-based MTP agent.
"""

from typing import Any, Dict, List, Optional
from .jac_bridge import JacBridge, JacBridgeError

class MTPInterfaceError(Exception):
    """Custom exception for MTP interface errors."""
    pass

class MTPInterface:
    """
    High-level interface for Genius/MTP agent operations.
    """

    def __init__(self, jac_workspace: Optional[str] = None):
        """
        Initialize MTP interface with optional Jac workspace.

        Args:
            jac_workspace: Path to Jac project containing MTP modules
        """
        self.bridge = JacBridge(jac_workspace=jac_workspace)

    def plan_task(self, task_description: str, context: Optional[str] = None) -> Dict[str, Any]:
        """
        Generate a high-level plan for a given task.

        Args:
            task_description: Task description in natural language
            context: Optional repository context or additional instructions

        Returns:
            Plan dictionary with ordered steps and metadata
        """
    try:
        """
        Apply edits to a file according to MTP instructions.

        Args:
            file_path: Path to file relative to repo root
            instructions: Edit instructions in natural language

        Returns:
            Updated file content
        """
    try:
        """
        Run MTP validation on a file.

        Args:
            file_path: Path to file relative to repo root

        Returns:
            Validation results including warnings, errors, and recommendations
        """
    try:
        """
        Validate recent changes using MTP validation walker.

        Args:
            files: Optional list of files to validate. If None, validates all changed files.

        Returns:
            Dict containing validation results
        """
    try:
        """
        Execute the full Genius/MTP workflow: planning, editing, validation.

        Args:
            task_description: Task description in natural language
            context: Optional repository context

        Returns:
            Dictionary containing plan, edits, and validation results
        """
    result = {}
