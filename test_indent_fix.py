#!/usr/bin/env python3
"""
Quick Fix for Indentation Issue
Test the proper indentation logic
"""

def test_fix():
    content = """class User:
    def __init__(self, name):
        self.name = name
        self.active = True"""
    
    lines = content.split('\n')
    print("Original lines:")
    for i, line in enumerate(lines):
        print(f"{i}: '{line}'")
    
    # Find the line with self.active = True
    for i, line in enumerate(lines):
        if "self.active = True" in line:
            print(f"\nFound target line {i}: '{line}'")
            # Get indentation
            indent_match = len(line) - len(line.lstrip())
            print(f"Indentation: {indent_match} spaces")
            
            # Create new line with same indentation
            indent_str = " " * indent_match
            new_line = f"{indent_str}self.status = 'active'  # AI-added"
            print(f"New line: '{new_line}'")
            
            # Insert BEFORE the target line
            lines.insert(i, new_line)
            break
    
    print("\nFixed lines:")
    for i, line in enumerate(lines):
        print(f"{i}: '{line}'")
    
    result = '\n'.join(lines)
    print(f"\nFinal result:\n{result}")

if __name__ == "__main__":
    test_fix()
