#!/usr/bin/env python3
"""Debug LLM response parsing"""

import os, sys
sys.path.append('/Users/thiru-07/Documents/GitHub/Rebuilding-Aider-with-Jac-OSP')

from aider.integration.llm_client import LLMClient

print("=== DEBUG LLM RESPONSE ===")

# Quick test 
client = LLMClient()

# Read current files
with open('simple1.py', 'r') as f:
    simple1_orig = f.read()
with open('simple2.py', 'r') as f:
    simple2_orig = f.read()

prompt = f"""Enhance these Python files by adding the requested methods:

FILE 1 - simple1.py:  
{simple1_orig}

FILE 2 - simple2.py:  
{simple2_orig}

Add these enhancements:
1. Add get_user_info() method to User class that returns a formatted string
2. Add count_reports() method to Report class that returns a number

Provide the complete enhanced code for BOTH files. Format your response as:

SIMPLE1:
```python
[complete enhanced simple1.py code here]
```

SIMPLE2:
```python  
[complete enhanced simple2.py code here]
```"""

print("Making API call...")
response = client._call_openrouter(prompt)
generated_code = response.get('code', '')

print(f"\nFull LLM Response ({len(generated_code)} chars):")
print("=" * 60)
print(generated_code)
print("=" * 60)

# Test parsing
import re
simple1_match = re.search(r'SIMPLE1:.*?```python\n(.*?)```', generated_code, re.DOTALL | re.IGNORECASE)
simple2_match = re.search(r'SIMPLE2:.*?```python\n(.*?)```', generated_code, re.DOTALL | re.IGNORECASE)

if simple1_match:
    print(f"\nParsed SIMPLE1 ({len(simple1_match.group(1))} chars):")
    print(simple1_match.group(1))
else:
    print("\nFailed to parse SIMPLE1")

if simple2_match:
    print(f"\nParsed SIMPLE2 ({len(simple2_match.group(1))} chars):")
    print(simple2_match.group(1))
else:
    print("\nFailed to parse SIMPLE2")
