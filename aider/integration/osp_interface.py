"""
osp_interface.py
High-level OSP (Optimal Software Planning) interface.
Provides Python-friendly API to interact with Jac-based RepoMap.
"""

from typing import Any, Dict, List, Optional
from .jac_bridge import JacBridge, JacBridgeError

class OSPInterfaceError(Exception):
    """Custom exception for OSP interface errors."""
    pass

class OSPInterface:
    """
    High-level interface for OSP RepoMap operations.
    """

    def __init__(self, jac_workspace: Optional[str] = None):
        """
        Initialize OSP interface with optional Jac workspace.

        Args:
            jac_workspace: Path to the Jac project containing OSP modules
        """
        self.bridge = JacBridge(jac_workspace=jac_workspace)

    def list_files(self) -> List[str]:
        """
        List all files in the repository according to RepoMap.

        Returns:
            List of relative file paths
        """
        try:
            files = self.bridge.call_walker("repomap_osp", "list_all_files")
            return files or []
        except JacBridgeError as e:
            raise OSPInterfaceError(f"Failed to list files: {e}")

    def list_functions(self, file_path: str) -> List[str]:
        """
        List all functions in a specific file.

        Args:
            file_path: Path to the file relative to repo root

        Returns:
            List of function names
        """
    try:
        """
        Rank files in the repository based on OSP algorithms.

        Args:
            files: List of files to rank. If None, ranks all files.
            context: Optional context for ranking

        Returns:
            Dict mapping file paths to ranking scores
        """
    try:
        """
        Get direct dependencies of a file.

        Args:
            file_path: Relative file path

        Returns:
            List of dependent file paths
        """
    try:
        """
        Search nodes in the RepoMap using query.

        Args:
            query: Search string
            node_type: Optional node type filter (e.g., "FunctionNode", "ClassNode")

        Returns:
            List of nodes with relevant metadata
        """
    try:
