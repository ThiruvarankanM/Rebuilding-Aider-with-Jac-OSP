# jac_executor.py
# Executes Jac scripts from Python

import subprocess

def run_jac_script(script_path):
    result = subprocess.run(["jac", script_path], capture_output=True, text=True)
    return result.stdout

if __name__ == "__main__":
    output = run_jac_script("jac/main.jac")
    print(output)
