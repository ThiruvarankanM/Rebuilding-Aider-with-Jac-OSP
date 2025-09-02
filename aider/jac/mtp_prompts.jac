# mtp_prompts.jac
# Jac module for Multi-Task Prompts (MTP) for Genius agent
# Contains templates for task descriptions, planning, editing, and validation

walker mtp_prompts {

    # General task template
    global func task_template(task_name: str, details: str, files: list):
        prompt = f"""
        TASK: {task_name}
        DESCRIPTION:
        {details}

        FILES AFFECTED:
        {', '.join(files) if files else 'None'}

        INSTRUCTIONS:
        - Use best practices
        - Ensure code correctness and maintainability
        - Respect existing code structure
        """
        return prompt.strip()

    # Planning prompt
    global func planning_prompt(task_name: str, context: str = ""):
        prompt = f"""
        PLAN TASK: {task_name}
        CONTEXT:
        {context if context else 'No context provided.'}

        STEPS:
        1. Analyze current repo structure
        2. Identify dependencies and impacted files
        3. Suggest sequential plan of actions
        4. Prioritize tasks with highest impact
        """
        return prompt.strip()

    # Editing prompt
    global func editing_prompt(task_name: str, code_snippet: str, instructions: str):
        prompt = f"""
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
    global func validation_prompt(task_name: str, files: list, checks: list):
        prompt = f"""
        VALIDATION TASK: {task_name}
        FILES TO VALIDATE:
        {', '.join(files)}

        CHECKS TO PERFORM:
        {', '.join(checks)}

        GOAL:
        - Ensure syntax correctness
        - Ensure logical consistency
        - Ensure adherence to coding standards
        """
        return prompt.strip()

    # Web/tool search prompt
    global func tool_integration_prompt(task_name: str, query: str, context: str = ""):
        prompt = f"""
        TOOL ASSISTANCE TASK: {task_name}

        QUERY:
        {query}

        CONTEXT:
        {context if context else 'No additional context.'}

        INSTRUCTIONS:
        - Provide relevant information only
        - Summarize if response is large
        - Return results in a structured format
        """
        return prompt.strip()

    # Concise prompt generator
    global func concise_prompt(task_name: str, summary: str):
        prompt = f"""
        TASK: {task_name}
        SUMMARY: {summary}
        """
        return prompt.strip()

}

# End of mtp_prompts.jac
