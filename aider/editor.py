"""
Enhanced Editor module for handling multi-file text editor interactions.

This module provides functionality to:
- Discover and launch the system's configured text editor
- Create and manage temporary files for editing
- Handle editor preferences from environment variables
- Support cross-platform editor operations
- Manage multiple files simultaneously
- Integrate with repo management, chat flow, and LLM systems
- Provide undo/redo functionality across multiple files
"""

import os
import platform
import subprocess
import tempfile
from typing import Dict, List, Optional, Tuple, Any
from pathlib import Path
from datetime import datetime
import json

from rich.console import Console

from aider.dump import dump  # noqa

DEFAULT_EDITOR_NIX = "vi"
DEFAULT_EDITOR_OS_X = "vim"
DEFAULT_EDITOR_WINDOWS = "notepad"

console = Console()


class FileEditHistory:
    """Manages edit history for a single file."""
    
    def __init__(self, filename: str, initial_content: str = ""):
        self.filename = filename
        self.history: List[Tuple[str, datetime]] = [(initial_content, datetime.now())]
        self.current_index = 0
    
    def add_edit(self, content: str):
        """Add a new edit to the history."""
        # Remove any future history if we're not at the latest state
        self.history = self.history[:self.current_index + 1]
        self.history.append((content, datetime.now()))
        self.current_index = len(self.history) - 1
    
    def undo(self) -> Optional[str]:
        """Undo to previous state."""
        if self.current_index > 0:
            self.current_index -= 1
            return self.history[self.current_index][0]
        return None
    
    def redo(self) -> Optional[str]:
        """Redo to next state."""
        if self.current_index < len(self.history) - 1:
            self.current_index += 1
            return self.history[self.current_index][0]
        return None
    
    def get_current_content(self) -> str:
        """Get current content."""
        return self.history[self.current_index][0]


class MultiFileEditor:
    """Enhanced editor for handling multiple files with AI integration."""
    
    def __init__(self, repo_manager=None, chat_flow=None, llm_client=None):
        self.open_files: Dict[str, str] = {}  # {filename: current_content}
        self.file_histories: Dict[str, FileEditHistory] = {}  # {filename: history}
        self.temp_files: Dict[str, str] = {}  # {filename: temp_path}
        
        # Integration components
        self.repo = repo_manager
        self.chat = chat_flow
        self.llm = llm_client
        
        # Editor discovery
        self._editor_command = None
    
    def discover_editor(self, editor_override: Optional[str] = None) -> str:
        """
        Discovers and returns the appropriate editor command.
        Caches result for performance.
        """
        if self._editor_command and not editor_override:
            return self._editor_command
            
        system = platform.system()
        if system == "Windows":
            default_editor = DEFAULT_EDITOR_WINDOWS
        elif system == "Darwin":
            default_editor = DEFAULT_EDITOR_OS_X
        else:
            default_editor = DEFAULT_EDITOR_NIX

        if editor_override:
            editor = editor_override
        else:
            editor = get_environment_editor(default_editor)
        
        self._editor_command = editor
        return editor
    
    def load_file(self, filename: str) -> str:
        """
        Load a file into the editor with repo integration.
        
        :param filename: Path to the file to load
        :return: File content
        :raises FileNotFoundError: If file doesn't exist in repo
        """
        # Use repo manager if available for validation
        if self.repo:
            if not self.repo.file_exists(filename):
                raise FileNotFoundError(f"{filename} not found in repo")
            content = self.repo.read_file(filename)
        else:
            # Fallback to direct file reading
            if not Path(filename).exists():
                raise FileNotFoundError(f"{filename} not found")
            with open(filename, 'r', encoding='utf-8') as f:
                content = f.read()
        
        # Store in open files and initialize history
        self.open_files[filename] = content
        self.file_histories[filename] = FileEditHistory(filename, content)
        
        print_status_message(True, f"Loaded file: {filename}")
        return content
    
    def load_multiple_files(self, filenames: List[str]) -> Dict[str, str]:
        """
        Load multiple files at once.
        
        :param filenames: List of file paths
        :return: Dictionary of {filename: content}
        """
        loaded_files = {}
        for filename in filenames:
            try:
                content = self.load_file(filename)
                loaded_files[filename] = content
            except FileNotFoundError as e:
                print_status_message(False, str(e))
        
        return loaded_files
    
    def save_file(self, filename: str, content: Optional[str] = None) -> bool:
        """
        Save a file with repo integration.
        
        :param filename: File to save
        :param content: Content to save (uses current content if None)
        :return: True if successful
        """
        if filename not in self.open_files:
            print_status_message(False, f"File {filename} not open in editor")
            return False
        
        save_content = content or self.open_files[filename]
        
        try:
            if self.repo:
                success = self.repo.write_file(filename, save_content)
            else:
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(save_content)
                success = True
            
            if success:
                # Update content and add to history if changed
                if save_content != self.open_files[filename]:
                    self.open_files[filename] = save_content
                    self.file_histories[filename].add_edit(save_content)
                
                print_status_message(True, f"Saved file: {filename}")
                return True
            else:
                print_status_message(False, f"Failed to save file: {filename}")
                return False
                
        except Exception as e:
            print_status_message(False, f"Error saving {filename}: {str(e)}")
            return False
    
    def edit_files(self, changes: Dict[str, str]) -> Dict[str, bool]:
        """
        Apply batch edits to multiple files.
        
        :param changes: Dictionary of {filename: new_content}
        :return: Dictionary of {filename: success_status}
        """
        results = {}
        
        for filename, new_content in changes.items():
            if filename in self.open_files:
                # Update content and add to history
                old_content = self.open_files[filename]
                if new_content != old_content:
                    self.open_files[filename] = new_content
                    self.file_histories[filename].add_edit(new_content)
                    results[filename] = True
                    print_status_message(True, f"Applied changes to: {filename}")
                else:
                    results[filename] = True  # No changes needed
            else:
                print_status_message(False, f"File not open: {filename}")
                results[filename] = False
        
        return results
    
    def apply_llm_edits(self, suggestions: Dict[str, str]) -> Dict[str, bool]:
        """
        Apply LLM-suggested edits with integration to chat flow.
        
        :param suggestions: Dictionary of {filename: suggested_content}
        :return: Dictionary of {filename: success_status}
        """
        print_status_message(True, f"Applying LLM suggestions to {len(suggestions)} files", "bold blue")
        
        # Log the suggestions if chat flow is available
        if self.chat:
            self.chat.log_llm_edits(suggestions)
        
        return self.edit_files(suggestions)
    
    def request_code_fix(self, files_to_fix: List[str], issue_description: str = "") -> Optional[Dict[str, str]]:
        """
        Request LLM to generate fixes for specified files.
        
        :param files_to_fix: List of filenames to fix
        :param issue_description: Description of the issue to fix
        :return: Dictionary of suggested fixes or None if LLM unavailable
        """
        if not self.llm:
            print_status_message(False, "LLM client not available for code fixes")
            return None
        
        # Prepare context with current file contents
        file_contexts = {}
        for filename in files_to_fix:
            if filename in self.open_files:
                file_contexts[filename] = self.open_files[filename]
            else:
                print_status_message(False, f"File not loaded: {filename}")
        
        if not file_contexts:
            return None
        
        try:
            # Generate fixes using LLM
            suggestions = self.llm.generate_fix(file_contexts, issue_description)
            print_status_message(True, f"Generated fixes for {len(suggestions)} files")
            return suggestions
        except Exception as e:
            print_status_message(False, f"Error generating LLM fixes: {str(e)}")
            return None
    
    def undo(self, filename: str) -> bool:
        """
        Undo last edit for a specific file.
        
        :param filename: File to undo
        :return: True if successful
        """
        if filename not in self.file_histories:
            print_status_message(False, f"No history for file: {filename}")
            return False
        
        previous_content = self.file_histories[filename].undo()
        if previous_content is not None:
            self.open_files[filename] = previous_content
            print_status_message(True, f"Undid changes to: {filename}")
            return True
        else:
            print_status_message(False, f"Nothing to undo for: {filename}")
            return False
    
    def redo(self, filename: str) -> bool:
        """
        Redo last undone edit for a specific file.
        
        :param filename: File to redo
        :return: True if successful
        """
        if filename not in self.file_histories:
            print_status_message(False, f"No history for file: {filename}")
            return False
        
        next_content = self.file_histories[filename].redo()
        if next_content is not None:
            self.open_files[filename] = next_content
            print_status_message(True, f"Redid changes to: {filename}")
            return True
        else:
            print_status_message(False, f"Nothing to redo for: {filename}")
            return False
    
    def undo_all(self) -> Dict[str, bool]:
        """Undo last edit for all open files."""
        results = {}
        for filename in self.open_files.keys():
            results[filename] = self.undo(filename)
        return results
    
    def pipe_editor_multi(self, files_data: Dict[str, str], suffix: Optional[str] = None, 
                         editor: Optional[str] = None) -> Dict[str, str]:
        """
        Open multiple files in editor simultaneously.
        
        :param files_data: Dictionary of {filename: initial_content}
        :param suffix: Optional file extension for temp files
        :param editor: Optional editor override
        :return: Dictionary of {filename: edited_content}
        """
        temp_paths = {}
        results = {}
        
        try:
            # Create temporary files for each
            for filename, content in files_data.items():
                temp_path = write_temp_file(content, suffix, prefix=f"edit_{Path(filename).stem}_")
                temp_paths[filename] = temp_path
                self.temp_files[filename] = temp_path
            
            # Launch editor with all files
            command_str = self.discover_editor(editor)
            all_temp_paths = " ".join(f'"{path}"' for path in temp_paths.values())
            command_str += f" {all_temp_paths}"
            
            print_status_message(True, f"Opening {len(files_data)} files in editor...")
            subprocess.call(command_str, shell=True)
            
            # Read back edited content
            for filename, temp_path in temp_paths.items():
                try:
                    with open(temp_path, "r", encoding='utf-8') as f:
                        edited_content = f.read()
                    results[filename] = edited_content
                    
                    # Update open files and history
                    if filename in self.open_files and edited_content != self.open_files[filename]:
                        self.open_files[filename] = edited_content
                        self.file_histories[filename].add_edit(edited_content)
                        
                except Exception as e:
                    print_status_message(False, f"Error reading edited file {filename}: {str(e)}")
                    results[filename] = files_data[filename]  # Return original on error
            
        finally:
            # Clean up temporary files
            self.cleanup_temp_files(list(temp_paths.values()))
        
        return results
    
    def cleanup_temp_files(self, temp_paths: Optional[List[str]] = None):
        """Clean up temporary files."""
        paths_to_clean = temp_paths or list(self.temp_files.values())
        
        for temp_path in paths_to_clean:
            try:
                if os.path.exists(temp_path):
                    os.remove(temp_path)
            except PermissionError:
                print_status_message(
                    False,
                    f"WARNING: Unable to delete temporary file {temp_path!r}. "
                    "You may need to delete it manually."
                )
        
        # Clear temp file tracking
        if not temp_paths:  # If cleaning all
            self.temp_files.clear()
    
    def get_file_status(self) -> Dict[str, Dict[str, Any]]:
        """Get status information for all open files."""
        status = {}
        for filename in self.open_files:
            history = self.file_histories.get(filename)
            status[filename] = {
                'loaded': True,
                'content_length': len(self.open_files[filename]),
                'history_length': len(history.history) if history else 0,
                'current_history_index': history.current_index if history else 0,
                'can_undo': history.current_index > 0 if history else False,
                'can_redo': history.current_index < len(history.history) - 1 if history else False
            }
        return status
    
    def close_file(self, filename: str, save_first: bool = False) -> bool:
        """
        Close a file and clean up resources.
        
        :param filename: File to close
        :param save_first: Whether to save before closing
        :return: True if successful
        """
        if filename not in self.open_files:
            print_status_message(False, f"File not open: {filename}")
            return False
        
        if save_first:
            if not self.save_file(filename):
                return False
        
        # Clean up
        del self.open_files[filename]
        if filename in self.file_histories:
            del self.file_histories[filename]
        if filename in self.temp_files:
            self.cleanup_temp_files([self.temp_files[filename]])
            del self.temp_files[filename]
        
        print_status_message(True, f"Closed file: {filename}")
        return True
    
    def close_all_files(self, save_first: bool = False) -> bool:
        """Close all open files."""
        filenames = list(self.open_files.keys())
        success = True
        
        for filename in filenames:
            if not self.close_file(filename, save_first):
                success = False
        
        return success


# Legacy functions for backward compatibility
def print_status_message(success, message, style=None):
    """
    Print a status message with appropriate styling.

    :param success: Whether the operation was successful
    :param message: The message to display
    :param style: Optional style override. If None, uses green for success and red for failure
    """
    if style is None:
        style = "bold green" if success else "bold red"
    console.print(message, style=style)
    print("")


def write_temp_file(input_data="", suffix=None, prefix=None, dir=None):
    """
    Create a temporary file with the given input data.

    :param input_data: Content to write to the temporary file
    :param suffix: Optional file extension (without the dot)
    :param prefix: Optional prefix for the temporary filename
    :param dir: Optional directory to create the file in
    :return: Path to the created temporary file
    :raises: OSError if file creation or writing fails
    """
    kwargs = {"prefix": prefix, "dir": dir}
    if suffix:
        kwargs["suffix"] = f".{suffix}"
    fd, filepath = tempfile.mkstemp(**kwargs)
    try:
        with os.fdopen(fd, "w", encoding='utf-8') as f:
            f.write(input_data)
    except Exception:
        os.close(fd)
        raise
    return filepath


def get_environment_editor(default=None):
    """
    Fetches the preferred editor from the environment variables.

    This function checks the following environment variables in order to
    determine the user's preferred editor:

     - VISUAL
     - EDITOR

    :param default: The default editor to return if no environment variable is set.
    :type default: str or None
    :return: The preferred editor as specified by environment variables or the default value.
    :rtype: str or None
    """
    editor = os.environ.get("VISUAL", os.environ.get("EDITOR", default))
    return editor


def discover_editor(editor_override=None):
    """
    Discovers and returns the appropriate editor command.

    Handles cases where the editor command includes arguments, including quoted arguments
    with spaces (e.g. 'vim -c "set noswapfile"').

    :return: The editor command as a string
    :rtype: str
    """
    system = platform.system()
    if system == "Windows":
        default_editor = DEFAULT_EDITOR_WINDOWS
    elif system == "Darwin":
        default_editor = DEFAULT_EDITOR_OS_X
    else:
        default_editor = DEFAULT_EDITOR_NIX

    if editor_override:
        editor = editor_override
    else:
        editor = get_environment_editor(default_editor)

    return editor


def pipe_editor(input_data="", suffix=None, editor=None):
    """
    Opens the system editor with optional input data and returns the edited content.

    This function creates a temporary file with the provided input data, opens it in
    the system editor, waits for the user to make changes and close the editor, then
    reads and returns the modified content. The temporary file is deleted afterwards.

    :param input_data: Initial content to populate the editor with
    :type input_data: str
    :param suffix: Optional file extension for the temporary file (e.g. '.txt', '.md')
    :type suffix: str or None
    :return: The edited content after the editor is closed
    :rtype: str
    """
    filepath = write_temp_file(input_data, suffix)
    command_str = discover_editor(editor)
    command_str += " " + filepath

    subprocess.call(command_str, shell=True)
    with open(filepath, "r", encoding='utf-8') as f:
        output_data = f.read()
    try:
        os.remove(filepath)
    except PermissionError:
        print_status_message(
            False,
            (
                f"WARNING: Unable to delete temporary file {filepath!r}. You may need to delete it"
                " manually."
            ),
        )
    return output_data