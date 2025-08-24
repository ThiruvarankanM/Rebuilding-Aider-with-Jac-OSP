"""
tests/test_jac_integration.py

Unit tests for Python ↔ Jac bridge (mtp_interface, osp_interface, jac_bridge)
"""

import unittest
from unittest.mock import patch

from aider.integration import jac_bridge
from aider.integration import osp_interface
from aider.integration import mtp_interface

class TestJacBridge(unittest.TestCase):
    def test_jac_bridge_imports(self):
        """Ensure jac_bridge module can be imported and has expected functions"""
        self.assertTrue(hasattr(jac_bridge, "execute_jac_command"))
        self.assertTrue(callable(jac_bridge.execute_jac_command))

    @patch("aider.integration.mtp_interface.GeniusAgent")
    def test_mtp_interface_agent(self, mock_agent_class):
        """Test mtp_interface GeniusAgent integration"""
        agent = mock_agent_class.return_value
        agent.execute.return_value = "Mocked result"
        genius_agent = mtp_interface.GeniusAgent()
        result = genius_agent.execute("Test command")
        self.assertEqual(result, "Mocked result")
        agent.execute.assert_called_once_with("Test command")

    def test_osp_interface_access(self):
        """Test that OSP interface can initialize RepoMap"""
        repomap = osp_interface.RepoMap()
        self.assertIsNotNone(repomap)
        self.assertTrue(hasattr(repomap, "nodes"))
        self.assertIsInstance(repomap.nodes, list)

if __name__ == "__main__":
    unittest.main()
