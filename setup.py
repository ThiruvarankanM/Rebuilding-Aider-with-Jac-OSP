from setuptools import setup, find_packages
from pathlib import Path

# Read the README for long description
this_directory = Path(__file__).parent
long_description = (this_directory / "README.md").read_text(encoding="utf-8")

setup(
    name="aider",
    version="1.0.0",
    description="Aider: AI-powered code assistant with OSP & Genius mode (MTP) integration",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Thiruvarankan",
    author_email="thiru07official@gmail.com",
    url="https://github.com/ThiruvarankanM/Rebuilding-Aider-with-Jac-OSP",
    packages=find_packages(exclude=["tests*", "examples*", "docs*", "scripts*"]),
    python_requires=">=3.11",
    install_requires=[
        "python-dateutil>=2.8.2",
        "pydantic>=2.5.1",
        "rich>=13.5.0",
        "requests>=2.31.0",
        "PyYAML>=6.0",
        "litellm>=0.4.0",
        "transformers>=4.35.0",
        "torch>=2.1.0",
        "beautifulsoup4>=4.12.2",
        "lxml>=4.9.3",
        "selenium>=5.9.0",
        "numpy>=1.27.0",
        "pandas>=2.1.1",
        "pytest>=8.2.0",
        "pytest-mock>=3.12.0",
        "unittest-xml-reporting>=3.0.4",
        "jac-lang>=1.0.0",
    ],
    extras_require={
        "dev": [
            "black>=24.8.0",
            "isort>=6.1.0",
            "flake8>=7.0.0",
        ],
        "docs": [
            "mkdocs>=1.6.0",
            "mkdocs-material>=9.0.0",
        ],
    },
    entry_points={
        "console_scripts": [
            "aider=aider.__main__:main",
        ],
    },
    include_package_data=True,
    classifiers=[
        "Programming Language :: Python :: 3.11",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Code Generators",
    ],
    keywords="AI assistant LLM code OSP MTP Jac automation",
)
