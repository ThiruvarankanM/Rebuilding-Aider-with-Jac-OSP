"""
tests/test_jac_integration.py

Unit tests for Python ↔ Jac integration components.
Tests the bridge, interfaces, and integration classes.
"""

import unittest
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from aider.integration.jac_bridge import JacBridge
from aider.integration.osp_interface import OSPInterface
from aider.integration.mtp_interface import MTPInterface
from aider.jac_integration import JacIntegration
from aider.genius import GeniusConfig

class TestJacIntegration(unittest.TestCase):
    """Test the main Jac integration class."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.integration = JacIntegration()
    
    def test_integration_initialization(self):
        """Test that JacIntegration initializes correctly."""
        self.assertIsNotNone(self.integration)
        self.assertTrue(hasattr(self.integration, 'osp'))
        self.assertTrue(hasattr(self.integration, 'mtp'))
        self.assertTrue(hasattr(self.integration, 'bridge'))
    
    def test_command_handling(self):
        """Test command handling functionality."""
        result = self.integration.handle_command('/jac rank')
        self.assertIsInstance(result, dict)
        
        # Test invalid command
        result = self.integration.handle_command('/jac invalid')
        self.assertIn('error', result)
    
    def test_status_method(self):
        """Test get_status method."""
        status = self.integration.get_status()
        self.assertIsInstance(status, dict)
        self.assertIn('available', status)
        self.assertIn('jac_workspace', status)

class TestJacBridge(unittest.TestCase):
    """Test the Jac bridge functionality."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.bridge = JacBridge()
    
    def test_bridge_initialization(self):
        """Test that JacBridge initializes correctly."""
        self.assertIsNotNone(self.bridge)
        self.assertTrue(hasattr(self.bridge, 'jac_workspace'))
    
    def test_test_connection(self):
        """Test the test_connection method."""
        result = self.bridge.test_connection()
        self.assertIsInstance(result, dict)
        self.assertIn('success', result)

class TestOSPInterface(unittest.TestCase):
    """Test the OSP interface."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.osp = OSPInterface()
    
    def test_osp_initialization(self):
        """Test that OSPInterface initializes correctly."""
        self.assertIsNotNone(self.osp)
        self.assertTrue(hasattr(self.osp, 'bridge'))

class TestMTPInterface(unittest.TestCase):
    """Test the MTP interface."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.mtp = MTPInterface()
    
    def test_mtp_initialization(self):
        """Test that MTPInterface initializes correctly."""
        self.assertIsNotNone(self.mtp)
        self.assertTrue(hasattr(self.mtp, 'bridge'))

class TestGeniusConfig(unittest.TestCase):
    """Test the Genius configuration."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config = GeniusConfig()
    
    def test_config_initialization(self):
        """Test that GeniusConfig initializes correctly."""
        self.assertIsNotNone(self.config)
        self.assertIsInstance(self.config.config, dict)
        self.assertGreater(len(self.config.config), 0)
    
    def test_config_get_set(self):
        """Test configuration get/set methods."""
        # Test get
        value = self.config.get('max_iterations', 0)
        self.assertIsInstance(value, int)
        
        # Test set
        self.config.set('test_key', 'test_value')
        self.assertEqual(self.config.get('test_key'), 'test_value')

if __name__ == "__main__":
    unittest.main()
