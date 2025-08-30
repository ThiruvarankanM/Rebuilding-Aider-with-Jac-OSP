# architect_prompts.jac
# Jac module for architect-level prompt templates
# Focused on high-level system design, refactoring, and architecture guidance

walker architect_prompts {

    # System design analysis prompt
    def system_design_prompt(system_name: str, context: str = "", objectives: list = []):
        prompt = f"""
        ARCHITECTURE ANALYSIS: {system_name}

        CONTEXT:
        {context if context else 'No context provided.'}

        OBJECTIVES:
        {"; ".join(objectives) if objectives else "Provide high-level architectural analysis."}

        INSTRUCTIONS:
        - Identify major components and dependencies
        - Suggest improvements for maintainability and scalability
        - Consider modularity and separation of concerns
        """
        return prompt.strip()

    # Refactoring guidance prompt
    def refactoring_prompt(component_name: str, issues: list, suggestions: list):
        prompt = f"""
        REFACTORING TASK: {component_name}

        KNOWN ISSUES:
        {"; ".join(issues) if issues else 'No known issues provided.'}

        SUGGESTED IMPROVEMENTS:
        {"; ".join(suggestions) if suggestions else 'Provide refactoring recommendations.'}

        INSTRUCTIONS:
        - Ensure backward compatibility
        - Optimize code structure and readability
        - Reduce redundancy and improve modularity
        """
        return prompt.strip()

    # Dependency review prompt
    def dependency_review_prompt(component_name: str, dependencies: list):
        prompt = f"""
        DEPENDENCY REVIEW: {component_name}

        DEPENDENCIES:
        {"; ".join(dependencies) if dependencies else 'No dependencies listed.'}

        OBJECTIVES:
        - Identify unnecessary or risky dependencies
        - Suggest replacement or optimization
        - Maintain overall system integrity
        """
        return prompt.strip()

    # Architecture validation prompt
    def architecture_validation_prompt(system_name: str, files: list, checks: list):
        prompt = f"""
        ARCHITECTURE VALIDATION: {system_name}

        FILES TO CHECK:
        {', '.join(files) if files else 'No files specified.'}

        CHECKS TO PERFORM:
        {', '.join(checks) if checks else 'Provide architectural consistency checks.'}

        GOAL:
        - Ensure adherence to architecture principles
        - Detect potential design flaws
        - Maintain modular and scalable structure
        """
        return prompt.strip()

    # High-level planning prompt
    def high_level_planning_prompt(task_name: str, goals: list, context: str = ""):
        prompt = f"""
        HIGH-LEVEL PLAN: {task_name}

        GOALS:
        {"; ".join(goals) if goals else 'Define goals for the task.'}

        CONTEXT:
        {context if context else 'No context provided.'}

        INSTRUCTIONS:
        - Break down tasks into sequential actions
        - Prioritize actions based on impact
        - Consider architectural implications of each step
        """
        return prompt.strip()

    # Concise architect prompt generator
    def concise_architect_prompt(task_name: str, summary: str):
        prompt = f"""
        ARCHITECT TASK: {task_name}
        SUMMARY: {summary}
        """
        return prompt.strip()

}

# End of architect_prompts.jac
