"""
tests/test_token_optimization.py

Unit tests for token optimization and prompt compression features in Jac.
"""

import unittest
from unittest.mock import patch

from aider.llm import optimize_prompt_for_genius

class TestTokenOptimization(unittest.TestCase):
    def test_basic_prompt_compression(self):
        """Test that common boilerplate phrases are compressed"""
        prompt = "Please help me with this task. I would like you to optimize it."
        optimized = optimize_prompt_for_genius(prompt)
        self.assertIn("Help:", optimized)
        self.assertIn("Do:", optimized)
        self.assertNotIn("Please help me with", optimized)
        self.assertNotIn("I would like you to", optimized)

    def test_prompt_with_context_truncation(self):
        """Test that long repo context is truncated correctly"""
        prompt = "Optimize this code."
        context = "A" * 5000  # Very long context
        optimized = optimize_prompt_for_genius(prompt, context=context)
        self.assertTrue(len(optimized) < 5100)  # Should truncate context
        self.assertIn("Context:", optimized)
        self.assertIn("Task:", optimized)

    @patch("aider.llm.VERBOSE", True)
    def test_error_handling(self):
        """Test fallback if an exception occurs during optimization"""
        with patch("aider.llm.get_genius_template", side_effect=Exception("Mock error")):
            prompt = "Test prompt"
            optimized = optimize_prompt_for_genius(prompt)
            self.assertEqual(optimized, prompt)  # Should fallback to original

if __name__ == "__main__":
    unittest.main()
