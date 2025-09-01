#!/usr/bin/env python3
"""
Aider-Genius Command Line Interface
Professional autonomous coding assistant with Jac-OSP integration
"""

import os
import sys
import argparse
import json
from pathlib import Path
from typing import List, Dict, Any
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn

# Add aider to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from aider.integration.jac_bridge import JacBridge
from aider.integration.file_editor import AutoEditor
from aider.integration.llm_client import LLMClient

console = Console()

class AiderGeniusCLI:
    def __init__(self):
        self.project_root = os.getcwd()
        self.jac_bridge = None
        self.auto_editor = None
        self.llm_client = None
        
        # Initialize components
        self._initialize_components()
    
    def _initialize_components(self):
        """Initialize all system components"""
        try:
            # Initialize Jac Bridge
            bridge_root = os.path.dirname(os.path.abspath(__file__))
            self.jac_bridge = JacBridge(bridge_root)
            
            # Initialize Auto Editor
            self.auto_editor = AutoEditor(self.jac_bridge)
            
            # Initialize LLM Client (will handle API key loading)
            self.llm_client = LLMClient()
            
            console.print("✓ All components initialized successfully")
        except Exception as e:
            console.print(f"Warning: Component initialization issue - {e}")
    
    def analyze_project(self, target_dir: str = None) -> Dict[str, Any]:
        """Analyze project using OSP ranking algorithms"""
        if not target_dir:
            target_dir = self.project_root
            
        console.print(f"Analyzing project: {target_dir}")
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            task = progress.add_task("Executing OSP analysis...", total=None)
            
            # Execute Jac OSP ranking
            try:
                osp_result = self.jac_bridge.call_walker(
                    "file_analysis", "get_osp_ranking", 
                    {"target_dir": target_dir}
                )
                progress.update(task, description="✓ OSP analysis complete")
                return osp_result
            except Exception as e:
                progress.update(task, description=f"✗ OSP analysis failed: {e}")
                return {"error": str(e)}
    
    def optimize_tokens(self, file_path: str = None) -> Dict[str, Any]:
        """Execute token usage optimization"""
        console.print("Executing token optimization...")
        
        try:
            if file_path and os.path.exists(file_path):
                with open(file_path, 'r') as f:
                    code = f.read()
            else:
                # Project-wide optimization
                code = "# Project-wide optimization"
            
            result = self.jac_bridge.call_walker(
                "token_optimizer", "optimize_prompt",
                {"code": code}
            )
            
            console.print("✓ Token optimization complete")
            return result
            
        except Exception as e:
            console.print(f"✗ Token optimization failed: {e}")
            return {"error": str(e)}
    
    def auto_edit(self, task: str, files: List[str] = None) -> Dict[str, Any]:
        """Execute autonomous code editing using OSP guidance"""
        console.print(f"Executing autonomous edit: {task}")
        
        if not files:
            # Use OSP to identify relevant files
            console.print("Using OSP to find relevant files...")
            osp_result = self.analyze_project()
            if "ranked_files" in osp_result:
                files = [f["path"] for f in osp_result["ranked_files"][:3]]
            else:
                files = []
        
        if not files:
            return {"error": "No relevant files identified"}
        
        # Execute autonomous editing
        try:
            result = self.auto_editor.autonomous_edit(task, files)
            return result
        except Exception as e:
            console.print(f"✗ Autonomous editing failed: {e}")
            return {"error": str(e)}
    
    def setup_config(self) -> bool:
        """Initialize system configuration"""
        console.print("Setting up Aider-Genius configuration...")
        
        config_dir = Path.home() / ".aider-genius"
        config_dir.mkdir(exist_ok=True)
        
        config_file = config_dir / "config.json"
        
        if not config_file.exists():
            default_config = {
                "llm_provider": "openai",
                "model": "gpt-4",
                "max_tokens": 4000,
                "temperature": 0.2,
                "osp_enabled": True,
                "token_optimization": True,
                "git_safety": True,
                "backup_enabled": True
            }
            
            with open(config_file, 'w') as f:
                json.dump(default_config, f, indent=2)
            
            console.print("Configuration setup complete.")
            console.print("Add your API key to complete setup:")
            console.print(f"   Edit: {config_file}")
            console.print("   Add: 'api_key': 'your-api-key-here'")
            
        else:
            console.print("Configuration already exists")
            
        return True

def create_parser():
    """Create command line argument parser"""
    parser = argparse.ArgumentParser(
        description="Aider-Genius: AI coding assistant with Jac-OSP",
        epilog="Examples:\n"
               "  aider-genius analyze\n"
               "  aider-genius optimize main.py\n"
               "  aider-genius edit 'add error handling'\n"
               "  aider-genius setup",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('command', 
                       choices=['analyze', 'optimize', 'edit', 'setup'],
                       help='Command to execute')
    
    parser.add_argument('target', nargs='?',
                       help='Target file or task description')
    
    parser.add_argument('--files', nargs='+',
                       help='Specific files to target')
    
    parser.add_argument('--dir', 
                       help='Target directory (default: current)')
    
    parser.add_argument('--dry-run', action='store_true',
                       help='Show what would be done without making changes')
    
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Verbose output')
    
    return parser

def main():
    """Main CLI entry point"""
    parser = create_parser()
    args = parser.parse_args()
    
    # Initialize CLI
    cli = AiderGeniusCLI()
    
    console.print(Panel.fit(
        "AIDER-GENIUS: Autonomous AI Coding Assistant\n"
        "Powered by Jac Object-Spatial Programming",
        style="bold cyan"
    ))
    
    # Execute commands
    if args.command == 'setup':
        cli.setup_config()
        
    elif args.command == 'analyze':
        target_dir = args.dir or args.target or os.getcwd()
        result = cli.analyze_project(target_dir)
        
        if "error" not in result:
            console.print("[bold green]OSP Analysis Results:[/bold green]")
            if "ranked_files" in result:
                for i, file_info in enumerate(result["ranked_files"][:5], 1):
                    console.print(f"   {i}. {file_info['path']} (relevance: {file_info['relevance']:.2f})")
        else:
            console.print(f"✗ Analysis failed: {result['error']}")
    
    elif args.command == 'optimize':
        target_file = args.target
        result = cli.optimize_tokens(target_file)
        
        if "error" not in result:
            console.print("[bold green]Token Optimization Results:[/bold green]")
            console.print(f"   Original: {result.get('original_tokens', 'N/A')} tokens")
            console.print(f"   Optimized: {result.get('optimized_tokens', 'N/A')} tokens") 
            console.print(f"   Savings: {result.get('savings_percent', 'N/A'):.1f}%")
        else:
            console.print(f"✗ Optimization failed: {result['error']}")
    
    elif args.command == 'edit':
        if not args.target:
            console.print("✗ Please provide a task description for editing")
            return
            
        task = args.target
        files = args.files
        
        if args.dry_run:
            console.print(f"[bold yellow]DRY RUN - Would execute:[/bold yellow] {task}")
            if files:
                console.print(f"   Target files: {files}")
            else:
                console.print("   Files: Auto-selected using OSP ranking")
            return
        
        result = cli.auto_edit(task, files)
        
        if "error" not in result:
            console.print("[bold green]Autonomous Edit Results:[/bold green]")
            console.print(f"   Task: {result.get('task', task)}")
            console.print(f"   Files modified: {len(result.get('changes', []))}")
            console.print(f"   Success: {result.get('success', False)}")
        else:
            console.print(f"✗ Edit failed: {result['error']}")
    
    console.print("\nUse --help for more options")

if __name__ == "__main__":
    main()
