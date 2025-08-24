"""
basic_usage.py

Demonstrates the basic usage of the Aider system.
Shows adding files, running commands, and interacting with LiteLLM.
"""

from aider import main, commands, llm

def main_demo():
    # Initialize Aider environment
    print("=== Aider Basic Usage Demo ===")

    # Example 1: Add a file to chat session
    file_to_add = "example_file.py"
    print(f"Adding file: {file_to_add}")
    commands.cmd_add(commands=None, args=file_to_add)

    # Example 2: Drop a file
    print(f"Dropping file: {file_to_add}")
    commands.cmd_drop(commands=None, args=file_to_add)

    # Example 3: Prepare a prompt for LiteLLM
    prompt = "Explain this Python function in simple terms."
    prepared_prompt = llm.prepare_prompt(prompt)
    print(f"Prepared Prompt:\n{prepared_prompt}\n")

    # Example 4: Generate a response using LiteLLM
    print("Generating response from LiteLLM...")
    response = llm.generate_response(prepared_prompt)
    print("LiteLLM Response:\n", response)

    # Example 5: Demonstrate help command
    print("\nShowing help information:")
    commands.cmd_help(args="usage")

if __name__ == "__main__":
    main_demo()
