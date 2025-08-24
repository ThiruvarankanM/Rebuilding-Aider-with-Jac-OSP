# editor_prompts.jac
# Jac module for code editor prompt templates
# Focused on code editing, refactoring, bug fixing, and suggestions

walker editor_prompts {

    # Code improvement prompt
    global func code_improvement_prompt(file_name: str, issues: list = [], context: str = ""):
        prompt = f"""
        CODE IMPROVEMENT TASK: {file_name}

        KNOWN ISSUES:
        {"; ".join(issues) if issues else 'No specific issues provided.'}

        CONTEXT:
        {context if context else 'No additional context provided.'}

        INSTRUCTIONS:
        - Suggest improvements to code readability and maintainability
        - Optimize function or class structure
        - Ensure proper variable naming and commenting
        """
        return prompt.strip()

    # Bug fixing prompt
    global func bug_fix_prompt(file_name: str, bug_description: str, related_code: str = ""):
        prompt = f"""
        BUG FIX TASK: {file_name}

        BUG DESCRIPTION:
        {bug_description}

        RELATED CODE:
        {related_code if related_code else 'No specific code snippet provided.'}

        INSTRUCTIONS:
        - Identify root cause of the bug
        - Suggest corrected code or refactoring
        - Ensure no new bugs are introduced
        """
        return prompt.strip()

    # Refactoring suggestion prompt
    global func refactoring_prompt(file_name: str, functions: list = [], context: str = ""):
        prompt = f"""
        REFACTORING TASK: {file_name}

        FUNCTIONS/CLASSES TO REVIEW:
        {"; ".join(functions) if functions else 'All functions and classes'}

        CONTEXT:
        {context if context else 'No additional context provided.'}

        INSTRUCTIONS:
        - Improve code modularity and reuse
        - Reduce duplication
        - Follow language-specific best practices
        """
        return prompt.strip()

    # Code review prompt
    global func code_review_prompt(file_name: str, reviewer: str = "assistant", focus_areas: list = []):
        prompt = f"""
        CODE REVIEW TASK: {file_name}

        REVIEWER: {reviewer}

        FOCUS AREAS:
        {"; ".join(focus_areas) if focus_areas else 'General code quality, readability, and correctness'}

        INSTRUCTIONS:
        - Highlight potential issues or bugs
        - Suggest improvements in code style and structure
        - Check for maintainability and performance optimizations
        """
        return prompt.strip()

    # Add comments prompt
    global func add_comments_prompt(file_name: str, code_snippet: str, context: str = ""):
        prompt = f"""
        ADD COMMENTS TASK: {file_name}

        CODE SNIPPET:
        {code_snippet}

        CONTEXT:
        {context if context else 'No additional context provided.'}

        INSTRUCTIONS:
        - Add meaningful and concise comments
        - Explain logic for complex blocks
        - Maintain readability and clarity
        """
        return prompt.strip()

    # Automated suggestion prompt
    global func automated_suggestion_prompt(file_name: str, task_summary: str):
        prompt = f"""
        AUTOMATED EDITOR SUGGESTION: {file_name}

        TASK SUMMARY:
        {task_summary}

        INSTRUCTIONS:
        - Provide actionable code modifications
        - Suggest optimizations and improvements
        - Ensure no unintended side effects
        """
        return prompt.strip()

}

# End of editor_prompts.jac
