"""
genius_mode_demo.py

Demonstrates the Genius/MTP mode of the Aider system.
Uses autonomous agents, walkers, and OSP integration.
"""

from aider import main, commands, llm, repo

def genius_demo():
    print("=== Aider Genius Mode Demo ===")

    # Step 1: Set up a repo context (example)
    print("Loading repository context...")
    try:
        repo_context = repo.get_repo_context(max_tokens=2000)
        print(f"Repository context loaded ({len(repo_context)} chars).")
    except Exception as e:
        print(f"Warning: Could not load repo context: {e}")
        repo_context = None

    # Step 2: Prepare a Genius-mode prompt
    prompt = "Analyze this repo and suggest performance optimizations."
    prepared_prompt = llm.prepare_prompt(prompt, args=type('Args', (), {'genius': True})())
    print(f"\nPrepared Genius Prompt:\n{prepared_prompt}\n")

    # Step 3: Generate a Genius-mode response
    print("Generating Genius-mode response...")
    try:
        response = llm.generate_response(prepared_prompt, args=type('Args', (), {'genius': True})())
        print("\nGenius-mode Response:\n", response)
    except Exception as e:
        print(f"Error generating Genius response: {e}")

    # Step 4: Example of running a command in Genius-mode context
    print("\nRunning example command 'ls' in Genius context...")
    try:
        commands.cmd_run(commands=None, args="ls")
    except Exception as e:
        print(f"Command execution failed: {e}")

if __name__ == "__main__":
    genius_demo()
