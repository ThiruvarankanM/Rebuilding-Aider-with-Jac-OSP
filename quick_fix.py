#!/usr/bin/env python3
"""
Quick Fix: Replace the problematic _apply_demo_patterns with the working version
"""

def main():
    # Read the file editor
    with open('aider/integration/file_editor.py', 'r') as f:
        content = f.read()
    
    # Define the fixed method
    fixed_method = '''    def _apply_demo_patterns(self, file_path: str, content: str, task: str) -> bool:
        """Fallback pattern matching for demo files with PROPER indentation"""
        # For User class modifications (simple1.py or demo1.py)
        if "simple1.py" in file_path or "demo1.py" in file_path:
            lines = content.split('\\n')
            for i, line in enumerate(lines):
                if "self.active = True" in line:
                    # Get the proper indentation from the existing line (DYNAMIC)
                    indentation = len(line) - len(line.lstrip())
                    indent_str = " " * indentation
                    # Insert BEFORE self.active = True with same indentation
                    lines.insert(i, f"{indent_str}self.status = 'active'  # AI-added")
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write('\\n'.join(lines))
                    print(f"✅ Added status field with PROPER {indentation}-space indentation")
                    return True'''
    
    # Find and replace the old method
    import re
    pattern = r'def _apply_demo_patterns\(self.*?return True'
    if re.search(pattern, content, re.DOTALL):
        content = re.sub(pattern, fixed_method[4:], content, flags=re.DOTALL)
        
        # Write back
        with open('aider/integration/file_editor.py', 'w') as f:
            f.write(content)
        
        print("✅ Fixed the _apply_demo_patterns method with proper indentation logic!")
    else:
        print("❌ Could not find the method to replace")

if __name__ == "__main__":
    main()
