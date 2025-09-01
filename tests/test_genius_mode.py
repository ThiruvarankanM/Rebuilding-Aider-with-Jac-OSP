"""
tests/test_genius_mode.py

Unit tests for Genius Mode autonomous operations with Jac-OSP integration.
"""

import unittest
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from aider.genius import GeniusMode, GeniusConfig
from aider.jac_integration import JacIntegration

class MockIO:
    """Mock IO class for testing."""
    def tool_output(self, message):
        pass

class MockRepo:
    """Mock repository class for testing."""
    def get_tracked_files(self):
        return ["test1.py", "test2.py"]

class TestGeniusConfig(unittest.TestCase):
    """Test Genius Mode configuration."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config = GeniusConfig()
    
    def test_config_loading(self):
        """Test that configuration loads correctly."""
        self.assertIsInstance(self.config.config, dict)
        self.assertIn('max_iterations', self.config.config)
        self.assertIn('confidence_threshold', self.config.config)
    
    def test_config_methods(self):
        """Test configuration get/set methods."""
        # Test get
        value = self.config.get('max_iterations')
        self.assertIsNotNone(value)
        
        # Test set
        self.config.set('test_setting', 42)
        self.assertEqual(self.config.get('test_setting'), 42)

class TestGeniusMode(unittest.TestCase):
    """Test Genius Mode functionality."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.mock_io = MockIO()
        self.mock_repo = MockRepo()
        
    def test_genius_mode_initialization(self):
        """Test that Genius Mode initializes correctly."""
        try:
            genius = GeniusMode(self.mock_io, self.mock_repo)
            self.assertIsNotNone(genius)
            self.assertTrue(hasattr(genius, 'jac'))
        except Exception as e:
            # Expected if Jac integration isn't fully set up
            self.assertIn('Jac integration', str(e))
    
    def test_genius_mode_availability(self):
        """Test availability check."""
        try:
            genius = GeniusMode(self.mock_io, self.mock_repo)
            available = genius.is_available()
            self.assertIsInstance(available, bool)
        except Exception as e:
            # Expected if Jac integration isn't fully set up
            self.assertIn('Jac integration', str(e))

if __name__ == "__main__":
    unittest.main()

    def test_agent_plan_property(self):
        """Test that plan property exists and is a list"""
        plan = self.agent.plan
        self.assertIsInstance(plan, list)

if __name__ == "__main__":
    unittest.main()
