# planning_walker.jac
# Jac module for planning walker
# Responsible for analyzing tasks, dependencies, and generating a high-level plan.

walker planning_walker {

    # Generate a plan for a list of tasks with optional dependencies
    global func generate_plan(tasks: list, dependencies: dict = {}) -> list:
        """
        Args:
            tasks: List of task names
            dependencies: Dict mapping task -> list of dependent tasks

        Returns:
            Ordered list of tasks respecting dependencies (topological sort)
        """
        sorted_tasks = []
        visited = {}
        
        # Recursive DFS for topological sort
        func visit(task: str):
            if task in visited:
                if visited[task] == "visiting":
                    print(f"[PlanningWalker] Circular dependency detected on task {task}")
                    return
                return
            visited[task] = "visiting"
            for dep in dependencies.get(task, []):
                visit(dep)
            visited[task] = "visited"
            sorted_tasks.append(task)
        
        for t in tasks:
            visit(t)
        
        return sorted_tasks

    # Estimate task effort based on simple heuristics (length, complexity)
    global func estimate_effort(task: str) -> int:
        """
        Returns an integer representing estimated effort (1-10)
        """
        length = len(task)
        if length < 10:
            return 1
        elif length < 20:
            return 3
        elif length < 50:
            return 5
        elif length < 100:
            return 7
        else:
            return 10

    # Generate prioritized plan (tasks ordered by dependencies + effort)
    global func prioritized_plan(tasks: list, dependencies: dict = {}) -> list:
        ordered = generate_plan(tasks, dependencies)
        # Sort by descending effort to prioritize heavier tasks first
        return sorted(ordered, key=lambda t: -estimate_effort(t))

    # Merge sub-plans from multiple modules or walkers
    global func merge_subplans(subplans: list) -> list:
        """
        Takes multiple lists of tasks and merges them, removing duplicates
        while preserving order.
        """
        seen = set()
        merged = []
        for plan in subplans:
            for task in plan:
                if task not in seen:
                    merged.append(task)
                    seen.add(task)
        return merged

    # Display plan in a readable format
    global func display_plan(plan: list):
        print("[PlanningWalker] Generated Plan:")
        for i, task in enumerate(plan):
            print(f"  {i+1}. {task}")
}

# End of planning_walker.jac
