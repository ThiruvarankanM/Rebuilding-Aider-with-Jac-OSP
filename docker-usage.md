# Aider-Jac-OSP Docker Usage

## Build the Docker image
```bash
docker build -t aider-jac-osp .
```

## Run the container interactively
```bash
docker run -it aider-jac-osp bash
```

## Run with current directory mounted
```bash
docker run -it -v $(pwd):/workspace aider-jac-osp
```

## Run specific commands
```bash
# Show help
docker run --rm aider-jac-osp aider-genius --help

# Analyze project (mount your code)
docker run --rm -v $(pwd):/workspace aider-jac-osp aider-genius analyze

# Interactive session with mounted code
docker run -it -v $(pwd):/workspace aider-jac-osp bash
```

## Environment Variables
```bash
# With API key
docker run -e OPENROUTER_API_KEY=your-key -it aider-jac-osp

# With custom config
docker run -v ~/.aider-genius:/root/.aider-genius -it aider-jac-osp
```
