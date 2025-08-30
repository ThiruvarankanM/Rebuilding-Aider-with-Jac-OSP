# genius_agent.jac
# Jac module for the Genius/MTP autonomous agent
# Coordinates all walkers and manages autonomous code edits, planning, and validation

walker GeniusAgent {

    # References to other walkers
    has planning_walker_ref: ref = null
    has editing_walker_ref: ref = null
    has validation_walker_ref: ref = null
    has tool_integration_ref: ref = null

    # Task queue for Genius agent
    has list task_queue = []

    # Initialize agent with walker references
    can init(ref planning, ref editing, ref validation, ref tools) {
        this.planning_walker_ref = planning
        this.editing_walker_ref = editing
        this.validation_walker_ref = validation
        this.tool_integration_ref = tools
        report("[GeniusAgent] Initialized with walkers and tools.")
    }

    # Add task to agent queue
    can add_task(string description, list file_targets = [], int priority = 1) {
        dict task = {
            "desc": description,
            "files": file_targets,
            "priority": priority,
            "status": "pending"
        }
        this.task_queue += [task]
        report("[GeniusAgent] Added task: " + description + " | Priority: " + str(priority))
    }

    # Process all tasks
    can process_tasks() {
        report("[GeniusAgent] Processing " + str(len(this.task_queue)) + " tasks...")

        # Sort tasks by priority (higher first)
        this.task_queue = sort(this.task_queue, by=lambda t: -t["priority"])

        for task in this.task_queue {
            try {
                this.execute_task(task)
            } catch {
                report("[GeniusAgent] Error executing task '" + task["desc"] + "'")
            }
        }

        # Clear tasks after execution
        this.task_queue = []
        report("[GeniusAgent] All tasks processed.")
    }

    # Execute a single task
    can execute_task(dict task) {
        report("[GeniusAgent] Executing task: " + task["desc"])

        # Step 1: Planning
        if this.planning_walker_ref != null {
            this.planning_walker_ref.plan_task(task)
        }

        # Step 2: Editing
        if this.editing_walker_ref != null {
            this.editing_walker_ref.apply_task(task)
        }

        # Step 3: Validation
        if this.validation_walker_ref != null {
            for f in task["files"] {
                this.validation_walker_ref.add_validation_task(f, "syntax")
            }
            this.validation_walker_ref.execute_validations()
        }

        # Step 4: Tool integration (web search, file reads)
        if this.tool_integration_ref != null {
            this.tool_integration_ref.assist_task(task)
        }

        task["status"] = "completed"
        report("[GeniusAgent] Task completed: " + task["desc"])
    }

    # Preview all pending tasks
    can preview_tasks() {
        report("[GeniusAgent] Previewing task queue:")
        for i in range(0, len(this.task_queue)) {
            dict task = this.task_queue[i]
            report("  " + str(i+1) + ". Desc: " + task["desc"] +
                   ", Files: " + str(task["files"]) +
                   ", Status: " + task["status"])
        }
    }

    # Remove a task by description
    can remove_task(string description) {
        this.task_queue = [t for t in this.task_queue if t["desc"] != description]
        report("[GeniusAgent] Removed task(s) with description: " + description)
    }

    # Clear all tasks
    can clear_tasks() {
        this.task_queue = []
        report("[GeniusAgent] Cleared all tasks in queue.")
    }

    # Smart prioritization: raise priority of tasks affecting multiple files
    can reprioritize_tasks() {
        for task in this.task_queue {
            if len(task["files"]) > 3 {
                task["priority"] = task["priority"] + 1
            }
        }
        report("[GeniusAgent] Tasks reprioritized based on file impact.")
    }
}

# End of genius_agent.jac
