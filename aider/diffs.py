import difflib
import sys
from .dump import dump  # noqa: F401

def main():
    if len(sys.argv) != 3:
        print("Usage: python diffs.py file1 file2")
        sys.exit(1)
    file_orig, file_updated = sys.argv[1], sys.argv[2]
    with open(file_orig, "r", encoding="utf-8") as f:
        lines_orig = f.readlines()
    with open(file_updated, "r", encoding="utf-8") as f:
        lines_updated = f.readlines()
    for i in range(len(lines_updated)):
        res = diff_partial_update(lines_orig, lines_updated[:i])
        print(res)
        input()

def create_progress_bar(percentage):
    block = "█"
    empty = "░"
    total_blocks = 30
    filled_blocks = int(total_blocks * percentage // 100)
    empty_blocks = total_blocks - filled_blocks
    bar = block * filled_blocks + empty * empty_blocks
    return bar

def assert_newlines(lines):
    if not lines:
        return
    for line in lines[:-1]:
        assert line and line[-1] == "\n", line

def diff_partial_update(lines_orig, lines_updated, final=False, fname=None, repo_handler=None):
    """
    Given only the first part of an updated file, show the diff while
    ignoring the block of "deleted" lines that are past the end of the
    partially complete update.
    """
    # Use repo_handler for canonical file state if available
    if repo_handler and fname:
        lines_orig = repo_handler.get_file_lines(fname) or lines_orig
    
    assert_newlines(lines_orig)
    num_orig_lines = len(lines_orig)
    if final:
        last_non_deleted = num_orig_lines
    else:
        last_non_deleted = find_last_non_deleted(lines_orig, lines_updated)

    if last_non_deleted is None:
        return ""

    if num_orig_lines:
        pct = last_non_deleted * 100 / num_orig_lines
    else:
        pct = 50

    bar = create_progress_bar(pct)
    bar = f" {last_non_deleted:3d} / {num_orig_lines:3d} lines [{bar}] {pct:3.0f}%\n"

    lines_orig = lines_orig[:last_non_deleted]
    if not final:
        lines_updated = lines_updated[:-1] + [bar]

    diff = difflib.unified_diff(lines_orig, lines_updated, n=5)
    diff = list(diff)[2:]
    diff = "".join(diff)
    
    if not diff.endswith("\n"):
        diff += "\n"

    for i in range(3, 10):
        backticks = "`" * i
        if backticks not in diff:
            break

    show = f"{backticks}diff\n"
    if fname:
        show += f"--- {fname} original\n"
        show += f"+++ {fname} updated\n"
    show += diff
    show += f"{backticks}\n\n"

    return show

def create_structured_diff(file_changes, output_format="unified"):
    """Create structured diffs for multi-file changes"""
    if output_format == "json":
        return {"files": [{"path": path, "diff": diff} for path, diff in file_changes.items()]}
    
    # Default unified format for multiple files
    result = ""
    for path, (orig_lines, new_lines) in file_changes.items():
        result += diff_partial_update(orig_lines, new_lines, final=True, fname=path)
    return result

def optimize_diff_context(diff_text, max_tokens=1000):
    """Optimize diff for LLM token usage by reducing context"""
    lines = diff_text.split('\n')
    if len(lines) <= max_tokens // 10:  # Rough token estimation
        return diff_text
    
    # Keep header and reduce context lines
    header_lines = []
    diff_lines = []
    
    for line in lines:
        if line.startswith('---') or line.startswith('+++') or line.startswith('@@'):
            header_lines.append(line)
        else:
            diff_lines.append(line)
    
    # Keep essential changes, reduce context
    essential_lines = [line for line in diff_lines if line.startswith('+') or line.startswith('-')]
    context_lines = [line for line in diff_lines if not (line.startswith('+') or line.startswith('-'))]
    
    # Limit context lines
    max_context = min(len(context_lines), (max_tokens // 20))
    limited_context = context_lines[:max_context//2] + context_lines[-max_context//2:]
    
    return '\n'.join(header_lines + essential_lines + limited_context)

def find_last_non_deleted(lines_orig, lines_updated):
    diff = list(difflib.ndiff(lines_orig, lines_updated))
    num_orig = 0
    last_non_deleted_orig = None
    for line in diff:
        code = line[0]
        if code == " ":
            num_orig += 1
            last_non_deleted_orig = num_orig
        elif code == "-":
            # line only in orig
            num_orig += 1
        elif code == "+":
            # line only in updated
            pass
    return last_non_deleted_orig

if __name__ == "__main__":
    main()