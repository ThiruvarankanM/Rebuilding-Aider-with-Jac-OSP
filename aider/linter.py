import os
import re
import subprocess
import sys
import traceback
import warnings
from dataclasses import dataclass
from pathlib import Path

import oslex
from grep_ast import TreeContext, filename_to_lang
from grep_ast.tsl import get_parser

from aider.dump import dump
from aider.run_cmd import run_cmd_subprocess

warnings.simplefilter("ignore", category=FutureWarning)


@dataclass
class LintResult:
    text: str
    lines: list
    issues: list = None  # Structured issues for downstream usage


class Linter:
    def __init__(self, encoding="utf-8", root=None, strict=False):
        self.encoding = encoding
        self.root = root
        self.strict = strict  # From args.lint_strict
        self.languages = dict(python=self.py_lint)
        self.all_lint_cmd = None

    def set_linter(self, lang, cmd):
        if lang:
            self.languages[lang] = cmd
            return
        self.all_lint_cmd = cmd

    def get_rel_fname(self, fname):
        if self.root:
            try:
                return os.path.relpath(fname, self.root)
            except ValueError:
                return fname
        return fname

    def lint_content(self, fname, content):
        """Lint string content directly (for repo/editor integration)"""
        rel_fname = self.get_rel_fname(fname)
        lang = filename_to_lang(fname)
        if not lang:
            return None
            
        if lang == "python":
            return self.py_lint_content(fname, rel_fname, content)
        return basic_lint(rel_fname, content)

    def py_lint_content(self, fname, rel_fname, code):
        """Python linting for string content"""
        issues = []
        basic_res = basic_lint(rel_fname, code)
        compile_res = lint_python_compile(fname, code)
        
        # Only flake8 if strict mode
        flake_res = self.flake8_lint(rel_fname) if self.strict else None
        
        text = ""
        lines = set()
        for res in [basic_res, compile_res, flake_res]:
            if not res:
                continue
            if text:
                text += "\n"
            text += res.text
            lines.update(res.lines)
            if hasattr(res, 'issues') and res.issues:
                issues.extend(res.issues)

        if text or lines:
            return LintResult(text, lines, issues)

    def lint(self, fname, cmd=None):
        rel_fname = self.get_rel_fname(fname)
        try:
            code = Path(fname).read_text(encoding=self.encoding, errors="replace")
        except OSError as err:
            return LintResult(f"Unable to read {fname}: {err}", [], [])

        return self.lint_content(fname, code)

    # ... (keep existing methods: run_cmd, errors_to_lint_result, py_lint, flake8_lint)


def lint_python_compile(fname, code):
    try:
        compile(code, fname, "exec")
        return
    except Exception as err:
        end_lineno = getattr(err, "end_lineno", err.lineno)
        line_numbers = list(range(err.lineno - 1, end_lineno))
        
        tb_lines = traceback.format_exception(type(err), err, err.__traceback__)
        res = "".join(tb_lines[:1] + tb_lines[-2:])  # Simplified traceback
        
        issues = [{"file": fname, "line": err.lineno, "error": str(err)}]
        return LintResult(text=res, lines=line_numbers, issues=issues)


def basic_lint(fname, code):
    lang = filename_to_lang(fname)
    if not lang or lang == "typescript":
        return

    try:
        parser = get_parser(lang)
        tree = parser.parse(bytes(code, "utf-8"))
        errors = traverse_tree(tree.root_node)
    except Exception:
        return

    if errors:
        issues = [{"file": fname, "line": line+1, "error": "Syntax error"} for line in errors]
        return LintResult(text="", lines=errors, issues=issues)


def traverse_tree(node):
    errors = []
    if node.type == "ERROR" or node.is_missing:
        errors.append(node.start_point[0])
    for child in node.children:
        errors += traverse_tree(child)
    return errors


# Keep existing helper functions unchanged...