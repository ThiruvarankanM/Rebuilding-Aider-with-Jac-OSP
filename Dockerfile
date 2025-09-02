# Use official Python runtime as base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install aider-jac-osp from PyPI
RUN pip install --no-cache-dir aider-jac-osp

# Create workspace directory
WORKDIR /workspace

# Expose port for potential web interface
EXPOSE 8080

# Set default command
CMD ["aider-genius", "--help"]
