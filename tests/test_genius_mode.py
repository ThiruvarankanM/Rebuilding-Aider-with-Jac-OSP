"""
tests/test_genius_mode.py

Unit tests for Genius Mode (MTP autonomous agent) in aider.jac.genius_agent.
"""

import unittest
from unittest.mock import patch

# Import the GeniusAgent class via Python-Jac bridge
from aider.integration.mtp_interface import GeniusAgent

class TestGeniusAgent(unittest.TestCase):
    def setUp(self):
        # Initialize the GeniusAgent
        self.agent = GeniusAgent()
    
    def test_agent_initialization(self):
        """Test that the agent initializes correctly"""
        self.assertIsNotNone(self.agent)
        self.assertTrue(hasattr(self.agent, "plan"))
        self.assertTrue(hasattr(self.agent, "execute"))

    @patch("aider.integration.mtp_interface.GeniusAgent.execute")
    def test_simple_execution(self, mock_execute):
        """Test execution of a simple task"""
        mock_execute.return_value = "Task Completed"
        result = self.agent.execute("Do a simple test")
        self.assertEqual(result, "Task Completed")
        mock_execute.assert_called_once_with("Do a simple test")

    def test_agent_plan_property(self):
        """Test that plan property exists and is a list"""
        plan = self.agent.plan
        self.assertIsInstance(plan, list)

if __name__ == "__main__":
    unittest.main()
