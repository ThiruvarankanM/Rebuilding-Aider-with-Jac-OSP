# tool_integration.jac
# Jac module for bridging tools: file operations, web search, shell commands, etc.
# Provides standard interfaces for walkers and genius agent to use.

walker tool_integration {

    # Open a file and read content
    global func read_file(path: str) -> str:
        try:
            file = open(path, "r")
            content = file.read()
            file.close()
            return content
        except Exception as e:
            print(f"[ToolIntegration] Error reading file {path}: {e}")
            return ""

    # Write content to a file
    global func write_file(path: str, content: str):
        try:
            file = open(path, "w")
            file.write(content)
            file.close()
            print(f"[ToolIntegration] Wrote content to {path}")
        except Exception as e:
            print(f"[ToolIntegration] Error writing file {path}: {e}")

    # Execute a shell command and return stdout
    global func run_shell(cmd: str) -> str:
        try:
            import subprocess
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            return result.stdout
        except Exception as e:
            print(f"[ToolIntegration] Shell command failed: {e}")
            return ""

    # Simple web search (placeholder, can integrate with API)
    global func web_search(query: str, max_results: int = 5) -> list:
        """
        Perform a web search and return top results.
        Currently returns dummy data; can be extended with real search APIs.
        """
        results = []
        for i in range(max_results):
            results.append(f"Result {i+1} for query '{query}'")
        return results

    # Check if a file exists
    global func file_exists(path: str) -> bool:
        import os
        return os.path.exists(path)

    # List files in a directory (optionally recursive)
    global func list_files(directory: str, recursive: bool = False) -> list:
        import os
        all_files = []
        try:
            if recursive:
                for root, dirs, files in os.walk(directory):
                    for f in files:
                        all_files.append(os.path.join(root, f))
            else:
                for f in os.listdir(directory):
                    full_path = os.path.join(directory, f)
                    if os.path.isfile(full_path):
                        all_files.append(full_path)
            return all_files
        except Exception as e:
            print(f"[ToolIntegration] Error listing files: {e}")
            return []

    # Read a JSON file
    global func read_json(path: str) -> dict:
        import json
        try:
            file = open(path, "r")
            data = json.load(file)
            file.close()
            return data
        except Exception as e:
            print(f"[ToolIntegration] Error reading JSON {path}: {e}")
            return {}

    # Write JSON data to a file
    global func write_json(path: str, data: dict):
        import json
        try:
            file = open(path, "w")
            json.dump(data, file, indent=2)
            file.close()
        except Exception as e:
            print(f"[ToolIntegration] Error writing JSON {path}: {e}")
}

# End of tool_integration.jac
