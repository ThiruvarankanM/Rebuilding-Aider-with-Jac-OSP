# editor_prompts.jac
# Jac module for code editor prompt templates
# Focused on code editing, refactoring, bug fixing, and suggestions

walker editor_prompts {

    # Code improvement prompt
    def code_improvement_prompt(file_name: string, issues: list = [], context: string = ""):
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
    def bug_fix_prompt(file_name: string, bug_description: string, related_code: string = ""):
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
    def refactoring_prompt(file_name: string, functions: list = [], context: string = ""):
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
    def code_review_prompt(file_name: string, reviewer: string = "assistant", focus_areas: list = []):
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
    def add_comments_prompt(file_name: string, code_snippet: string, context: string = ""):
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
    def automated_suggestion_prompt(file_name: string, task_summary: string):
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
