# Aider-Genius Demo Commands

## Professional AI Coding Assistant with Jac-OSP Integration

This document provides the essential commands to demonstrate your working Aider-Genius system.

### Prerequisites
Your system is ready with:
- ✓ OpenRouter API key configured (Google Gemma 2 free model)
- ✓ Virtual environment setup (.venv) 
- ✓ Professional polish completed
- ✓ All dependencies installed

### 1. Activate Environment
```bash
source .venv/bin/activate
```

### 2. Basic System Test
```bash
# Test the CLI is working
aider-genius --help

# Verify system configuration
aider-genius setup
```

### 3. Core Features Demonstration

#### OSP File Analysis (Spatial Programming)
```bash
# Analyze current project structure using Object-Spatial Programming
aider-genius analyze

# Analyze specific directory
aider-genius analyze --dir ./aider
```

#### Token Optimization 
```bash
# Optimize token usage for a file
aider-genius optimize aider/cli.py

# Project-wide token analysis
aider-genius optimize
```

#### Autonomous Code Editing
```bash
# Dry run - show what would be done
aider-genius edit "add error handling to main function" --dry-run

# Actual autonomous edit
aider-genius edit "add docstring to analyze_project method" --files aider/cli.py
```

### 4. Advanced Integration Test

#### Test OpenRouter API Integration
```bash
# Run system test to verify API connectivity
python system_test.py
```

#### Manual API Test
```python
# Quick Python test of OpenRouter
from aider.integration.llm_client import LLMClient
client = LLMClient()
result = client.generate_code("Create a simple hello world function")
print(result)
```

### 5. Key Demo Points to Highlight

1. **Professional Interface**: Clean, enterprise-grade CLI without excessive emojis
2. **Working AI Integration**: Real OpenRouter API calls generating actual code
3. **OSP Analysis**: Spatial file ranking showing intelligent project understanding
4. **Token Optimization**: Cost-effective AI usage with smart prompt optimization
5. **Autonomous Editing**: AI-guided code modifications with safety features

### 6. Expected Outputs

- **OSP Analysis**: Shows ranked list of project files with relevance scores
- **Token Optimization**: Displays original vs optimized token counts with savings
- **Code Generation**: Returns actual Python code from AI model (130+ tokens)
- **System Status**: All components report as "Connected" and "Active"

### 7. Professional Presentation Notes

- System uses Google Gemma 2 (free) model for demonstrations
- All operations run in isolated virtual environment
- Professional language throughout - no excessive emojis
- Enterprise-grade error handling and logging
- Real OSP spatial algorithms analyzing file relationships

Your system is fully functional and ready for professional demonstration.
