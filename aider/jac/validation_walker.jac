# validation_walker.jac
# Jac module for validation walker
# Responsible for validating code edits, running tests, and checking syntax/standards

walker validation_walker {

    # Queue of validation tasks
    global var validation_queue: list = []

    # Add a validation task
    global func add_validation_task(file_path: str, validation_type: str = "syntax"):
        task = {
            "file": file_path,
            "type": validation_type
        }
        validation_queue.append(task)
        std.log(f"[ValidationWalker] Added {validation_type} validation task for {file_path}")

    # Execute all queued validations
    global func execute_validations():
        std.log(f"[ValidationWalker] Executing {len(validation_queue)} validation tasks...")
        for task in validation_queue:
            try:
                validate_task(task)
            catch e:
                std.log(f"[ValidationWalker] Validation failed for {task['file']}: {e}")

        validation_queue.clear()
        std.log("[ValidationWalker] All validations executed and queue cleared.")

    # Validate a single task
    global func validate_task(task: dict):
        file_path = task["file"]
        validation_type = task.get("type", "syntax")
        
        std.log(f"[ValidationWalker] Validating {file_path} | Type: {validation_type}")

        if not tool_integration.file_exists(file_path):
            std.log(f"[ValidationWalker] File does not exist: {file_path}")
            return

        code = tool_integration.read_file(file_path)

        if validation_type == "syntax":
            validate_syntax(code, file_path)
        elif validation_type == "style":
            validate_style(code, file_path)
        elif validation_type == "tests":
            run_tests(file_path)
        else:
            std.log(f"[ValidationWalker] Unknown validation type: {validation_type}")

    # Simple syntax check (example for Python)
    global func validate_syntax(code: str, file_path: str):
        try:
            py_compile.compile(code, filename=file_path, doraise=True)
            std.log(f"[ValidationWalker] Syntax check passed for {file_path}")
        catch e:
            std.log(f"[ValidationWalker] Syntax error in {file_path}: {e}")

    # Style check (placeholder)
    global func validate_style(code: str, file_path: str):
        std.log(f"[ValidationWalker] Style check passed for {file_path} (placeholder)")

    # Run tests (placeholder)
    global func run_tests(file_path: str):
        std.log(f"[ValidationWalker] Running tests for {file_path} (placeholder)")

    # Preview queued validations
    global func preview_validations():
        std.log("[ValidationWalker] Previewing validation queue:")
        for i, task in enumerate(validation_queue):
            std.log(f"  {i+1}. File: {task['file']}, Type: {task.get('type', 'syntax')}")

    # Remove a validation task by file
    global func remove_validation_task(file_path: str):
        global validation_queue
        validation_queue = [t for t in validation_queue if t['file'] != file_path]
        std.log(f"[ValidationWalker] Removed validations for file {file_path}")

    # Clear all validation tasks
    global func clear_queue():
        global validation_queue
        validation_queue.clear()
        std.log("[ValidationWalker] Cleared all validation tasks.")
}

# End of validation_walker.jac
