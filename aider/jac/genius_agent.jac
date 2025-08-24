# genius_agent.jac
# Jac module for the Genius/MTP autonomous agent
# Coordinates all walkers and manages autonomous code edits, planning, and validation

walker genius_agent {

    # References to other walkers
    global var planning_walker_ref: ref = null
    global var editing_walker_ref: ref = null
    global var validation_walker_ref: ref = null
    global var tool_integration_ref: ref = null

    # Task queue for Genius agent
    global var task_queue: list = []

    # Initialize agent with walker references
    global func init(
        planning: ref,
        editing: ref,
        validation: ref,
        tools: ref
    ):
        planning_walker_ref = planning
        editing_walker_ref = editing
        validation_walker_ref = validation
        tool_integration_ref = tools
        print("[GeniusAgent] Initialized with walkers and tools.")

    # Add task to agent queue
    global func add_task(description: str, file_targets: list = [], priority: int = 1):
        task = {
            "desc": description,
            "files": file_targets,
            "priority": priority,
            "status": "pending"
        }
        task_queue.append(task)
        print(f"[GeniusAgent] Added task: {description} | Priority: {priority}")

    # Process all tasks
    global func process_tasks():
        print(f"[GeniusAgent] Processing {len(task_queue)} tasks...")
        # Sort tasks by priority
        task_queue.sort(key=lambda t: -t["priority"])
        for task in task_queue:
            try:
                execute_task(task)
            except Exception as e:
                print(f"[GeniusAgent] Error executing task '{task['desc']}': {e}")

        # Clear tasks after execution
        task_queue.clear()
        print("[GeniusAgent] All tasks processed.")

    # Execute a single task
    global func execute_task(task: dict):
        print(f"[GeniusAgent] Executing task: {task['desc']}")

        # Step 1: Planning
        if planning_walker_ref != null:
            planning_walker_ref.plan_task(task)

        # Step 2: Editing
        if editing_walker_ref != null:
            editing_walker_ref.apply_task(task)

        # Step 3: Validation
        if validation_walker_ref != null:
            for file in task["files"]:
                validation_walker_ref.add_validation_task(file, "syntax")
            validation_walker_ref.execute_validations()

        # Step 4: Tool integration (web search, file reads)
        if tool_integration_ref != null:
            tool_integration_ref.assist_task(task)

        task["status"] = "completed"
        print(f"[GeniusAgent] Task completed: {task['desc']}")

    # Preview all pending tasks
    global func preview_tasks():
        print("[GeniusAgent] Previewing task queue:")
        for i, task in enumerate(task_queue):
            print(f"  {i+1}. Desc: {task['desc']}, Files: {task['files']}, Status: {task['status']}")

    # Remove a task by description
    global func remove_task(description: str):
        global task_queue
        task_queue = [t for t in task_queue if t["desc"] != description]
        print(f"[GeniusAgent] Removed task(s) with description: {description}")

    # Clear all tasks
    global func clear_tasks():
        global task_queue
        task_queue.clear()
        print("[GeniusAgent] Cleared all tasks in queue.")

    # Smart prioritization: raise priority of tasks affecting multiple files
    global func reprioritize_tasks():
        for task in task_queue:
            if len(task["files"]) > 3:
                task["priority"] += 1
        print("[GeniusAgent] Tasks reprioritized based on file impact.")

}

# End of genius_agent.jac
