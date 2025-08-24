"""
tests/test_osp_repomap.py

Unit tests for the OSP RepoMap functionality in aider.jac.repomap_osp.
"""

import unittest
from pathlib import Path

# Import the RepoMap and FileNode classes from your Jac-Python bridge
from aider.integration.osp_interface import RepoMap, CodeFile

class TestRepoMap(unittest.TestCase):
    def setUp(self):
        # Create temporary file structure for testing
        self.test_root = Path("tests/test_repo")
        self.test_root.mkdir(exist_ok=True)
        (self.test_root / "file1.py").write_text("print('Hello')")
        (self.test_root / "file2.py").write_text("def foo(): pass")

        # Initialize RepoMap
        self.repo_map = RepoMap(str(self.test_root))

    def tearDown(self):
        # Cleanup created files
        for f in self.test_root.iterdir():
            f.unlink()
        self.test_root.rmdir()

    def test_files_added(self):
        """Ensure all files are added to the RepoMap"""
        files = self.repo_map.get_all_files()
        file_names = [f.name for f in files]
        self.assertIn("file1.py", file_names)
        self.assertIn("file2.py", file_names)

    def test_file_node_properties(self):
        """Check that FileNode objects have correct attributes"""
        files = self.repo_map.get_all_files()
        for f in files:
            self.assertIsInstance(f, CodeFile)
            self.assertTrue(hasattr(f, "name"))
            self.assertTrue(hasattr(f, "content"))

    def test_repo_map_traversal(self):
        """Test basic traversal of RepoMap nodes"""
        nodes = self.repo_map.walk_files()
        node_names = [n.name for n in nodes]
        self.assertGreaterEqual(len(node_names), 2)
        self.assertIn("file1.py", node_names)

if __name__ == "__main__":
    unittest.main()
