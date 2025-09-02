# editing_walker.jac
# Jac module for editing walker
# Responsible for orchestrating multi-file code edits based on tasks and changes.

walker editing_walker {

    # Queue of edit tasks: each task contains file path, code snippet, and description
    global var edit_queue: list = []

    # Add an edit task to the queue
    global func add_edit_task(file_path: str, code_snippet: str, description: str = ""):
        task = {
            "file": file_path,
            "code": code_snippet,
            "desc": description
        }
        edit_queue.append(task)
        print(f"[EditingWalker] Added edit task for {file_path}")

    # Execute all queued edits
    global func execute_edits():
        print(f"[EditingWalker] Executing {len(edit_queue)} edit tasks...")
        for task in edit_queue:
            try:
                apply_edit(task)
            except Exception as e:
                print(f"[EditingWalker] Failed to apply edit to {task['file']}: {e}")

        # Clear queue after execution
        edit_queue.clear()
        print("[EditingWalker] All edits executed and queue cleared.")

    # Apply a single edit to the file
    global func apply_edit(task: dict):
        file_path = task["file"]
        code_snippet = task["code"]
        description = task.get("desc", "")
        
        print(f"[EditingWalker] Applying edit to {file_path} | {description}")
        # Check if file exists
        if !os.exists(file_path):
            print(f"[EditingWalker] File does not exist: {file_path}. Creating new file.")
            os.write_text(file_path, code_snippet)
        else:
            # Append new code or update logic (simple example: append at end)
            existing_code = os.read_text(file_path)
            updated_code = existing_code + "\n\n" + code_snippet
            os.write_text(file_path, updated_code)
        
        print(f"[EditingWalker] Edit applied to {file_path}")

    # Preview edits without executing
    global func preview_edits():
        print("[EditingWalker] Previewing edit queue:")
        for i, task in enumerate(edit_queue):
            print(f"  {i+1}. File: {task['file']}, Description: {task.get('desc', '')}")
            snippet_preview = task['code'][:60].replace("\n", " ") + ("..." if len(task['code']) > 60 else "")
            print(f"     Code snippet preview: {snippet_preview}")

    # Remove a task from the queue by file path
    global func remove_edit_task(file_path: str):
        global edit_queue
        edit_queue = [t for t in edit_queue if t['file'] != file_path]
        print(f"[EditingWalker] Removed tasks for file {file_path}")

    # Clear all queued edits
    global func clear_queue():
        global edit_queue
        edit_queue.clear()
        print("[EditingWalker] Cleared all edit tasks.")
}

# End of editing_walker.jac
