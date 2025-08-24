Here’s a professional and detailed **`genius_mode_guide.md`** for your project:

````markdown
# Genius Mode Usage Guide

## Overview

The **Genius Mode** (MTP - Multi-Task Planner) in Aider enables **autonomous, intelligent code analysis and editing**.  
It leverages:

- **OSP RepoMap**: Repository representation
- **Walkers**: Planning, editing, validation
- **Token Optimizer**: Efficient prompt generation
- **Jac Integration**: Python ↔ Jac bridge for advanced logic

Genius Mode allows you to delegate tasks like:

- Planning multi-step code changes
- Coordinating edits across multiple files
- Validating code quality and functionality
- Suggesting improvements automatically

---

## Key Concepts

### 1. Walkers
Genius Mode is powered by several walkers:

| Walker                 | Purpose                                               |
|------------------------|-------------------------------------------------------|
| `PlanningWalker`       | Generates a structured plan for tasks                |
| `EditingWalker`        | Applies planned changes to code                       |
| `ValidationWalker`     | Ensures the changes meet correctness criteria        |
| `ImpactAnalyzer`       | Determines dependencies and side effects             |

### 2. Prompt Management
- MTP uses **optimized prompts** to reduce token usage.
- Genius-specific templates ensure tasks are clear and concise.
- Prompts may include repository context for better reasoning.

### 3. Token Optimization
- Automatically compresses boilerplate text.
- Balances context inclusion vs. token limits.
- Ensures that large repositories do not exceed model limits.

---

## How to Use Genius Mode

### Enabling Genius Mode
When starting Aider:

```bash
python -m aider.main --genius
````

Alternatively, in Python:

```python
from aider.llm import prepare_prompt, generate_response
from aider.args import Args

args = Args()
args.genius = True

prompt = "Refactor the user authentication module"
response = generate_response(prompt, args=args)
print(response)
```

### Autonomous Workflow

1. **Analyze Repository**

   ```python
   from aider.jac.integration.mtp_interface import MTPInterface
   mtp = MTPInterface()
   mtp.load_repo(".")
   ```

2. **Plan Changes**

   ```python
   plan = mtp.create_plan("Optimize performance for data processing")
   print(plan)
   ```

3. **Execute Edits**

   ```python
   mtp.apply_plan(plan)
   ```

4. **Validate**

   ```python
   results = mtp.validate_changes()
   for r in results:
       print(r.status, r.details)
   ```

### Best Practices

* Always run `validate_changes()` after applying edits.
* Use `rank_files()` from OSP to prioritize large or critical files.
* Combine Genius Mode with version control (Git) for safe experimentation.

---

## Integration with Existing Tools

* Works seamlessly with the Aider editor and command interface.
* Supports multi-file operations and cross-dependency analysis.
* Can be extended with custom walkers or prompts.

---

## Notes

* Genius Mode is designed for advanced users who want automated, intelligent code suggestions.
* Model and token optimizations ensure responsiveness even on large repositories.
* For debugging, enable `VERBOSE` mode in `llm.py` to see prompt and response details.

---

**End of Genius Mode Guide**

```

---

Next, I can provide **`jac_integration.md`**, the documentation for Python ↔ Jac bridge. Do you want me to continue with that?
```
