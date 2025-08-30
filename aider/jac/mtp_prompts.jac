# mtp_prompts.jac
# Jac module for Multi-Task Prompts (MTP) for Genius agent
# Contains templates for task descriptions, planning, editing, and validation

walker mtp_prompts {

    # General task template
    global func task_template(task_name: str, details: str, files: list = []):
        string files_str = len(files) > 0 ? str.join(files, ", ") : "None"
        string prompt = f"""
        TASK: {task_name}
        DESCRIPTION:
        {details}

        FILES AFFECTED:
        {files_str}

        INSTRUCTIONS:
        - Use best practices
        - Ensure code correctness and maintainability
        - Respect existing code structure
        """
        return prompt.strip()

    # Planning prompt
    global func planning_prompt(task_name: str, context: str = ""):
        string ctx = context != "" ? context : "No context provided."
        string prompt = f"""
        PLAN TASK: {task_name}
        CONTEXT:
        {ctx}

        STEPS:
        1. Analyze current repo structure
        2. Identify dependencies and impacted files
        3. Suggest sequential plan of actions
        4. Prioritize tasks with highest impact
        """
        return prompt.strip()

    # Editing prompt
    global func editing_prompt(task_name: str, code_snippet: str, instructions: str):
        string prompt = f"""
        EDIT TASK: {task_name}

        CODE SNIPPET:
        {code_snippet}

        INSTRUCTIONS:
        {instructions}

        OBJECTIVES:
        - Apply safe code modifications
        - Preserve existing functionality
        - Optimize readability and performance
        """
        return prompt.strip()

    # Validation prompt
    global func validation_prompt(task_name: str, files: list = [], checks: list = []):
        string files_str = len(files) > 0 ? str.join(files, ", ") : "None"
        string checks_str = len(checks) > 0 ? str.join(checks, ", ") : "None"
        string prompt = f"""
        VALIDATION TASK: {task_name}
        FILES TO VALIDATE:
        {files_str}

        CHECKS TO PERFORM:
        {checks_str}

        GOAL:
        - Ensure syntax correctness
        - Ensure logical consistency
        - Ensure adherence to coding standards
        """
        return prompt.strip()

    # Web/tool search prompt
    global func tool_integration_prompt(task_name: str, query: str, context: str = ""):
        string ctx = context != "" ? context : "No additional context."
        string prompt = f"""
        TOOL ASSISTANCE TASK: {task_name}

        QUERY:
        {query}

        CONTEXT:
        {ctx}

        INSTRUCTIONS:
        - Provide relevant information only
        - Summarize if response is large
        - Return results in a structured format
        """
        return prompt.strip()

    # Concise prompt generator
    global func concise_prompt(task_name: str, summary: str):
        string prompt = f"""
        TASK: {task_name}
        SUMMARY: {summary}
        """
        return prompt.strip()
}

# End of mtp_prompts.jac
