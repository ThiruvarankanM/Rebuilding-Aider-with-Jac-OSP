#!/usr/bin/env python3
"""
Apply the indentation fix to the actual file
"""

def apply_fixed_pattern():
    # Read current simple1.py
    with open('simple1.py', 'r') as f:
        content = f.read()
    
    print("Current content:")
    print(content)
    print("\n" + "="*40)
    
    lines = content.split('\n')
    
    # Find and fix the indentation
    for i, line in enumerate(lines):
        if "self.active = True" in line:
            print(f"Found line {i}: '{line}'")
            indent_match = len(line) - len(line.lstrip())
            print(f"Indentation: {indent_match} spaces")
            
            # Create properly indented line
            indent_str = " " * indent_match
            new_line = f"{indent_str}self.status = 'active'  # AI-added"
            
            # Insert before self.active = True
            lines.insert(i, new_line)
            break
    
    # Write back
    result = '\n'.join(lines)
    with open('simple1.py', 'w') as f:
        f.write(result)
    
    print("Fixed content:")
    print(result)
    print("\n✅ Formatting fixed!")

if __name__ == "__main__":
    apply_fixed_pattern()
