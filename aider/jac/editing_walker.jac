# editing_walker.jac
# Jac module for editing walker
# Responsible for orchestrating multi-file code edits based on tasks and changes.

walker EditingWalker {
    # Queue of edit tasks: each task contains file path, code snippet, and description
    has list edit_queue = [];

    # Add an edit task to the queue
    can add_edit_task(string file_path, string code_snippet, string description="") {
        map task = {
            "file": file_path,
            "code": code_snippet,
            "desc": description
        };
        this.edit_queue += [task];
        report("[EditingWalker] Added edit task for " + file_path);
    }

    # Execute all queued edits
    can execute_edits() {
        report("[EditingWalker] Executing " + str(len(this.edit_queue)) + " edit tasks...");
        for (task in this.edit_queue) {
            try {
                this.apply_edit(task);
            } catch {
                report("[EditingWalker] Failed to apply edit to " + task["file"]);
            }
        }

        # Clear queue after execution
        this.edit_queue.clear();
        report("[EditingWalker] All edits executed and queue cleared.");
    }

    # Apply a single edit to the file
    can apply_edit(map task) {
        string file_path = task["file"];
        string code_snippet = task["code"];
        string description = task["desc"];

        report("[EditingWalker] Applying edit to " + file_path + " | " + description);

        if not fs.exists(file_path) {
            report("[EditingWalker] File does not exist: " + file_path + ". Creating new file.");
            fs.write_text(file_path, code_snippet);
        } else {
            string existing_code = fs.read_text(file_path);
            string updated_code = existing_code + "\n\n" + code_snippet;
            fs.write_text(file_path, updated_code);
        }

        report("[EditingWalker] Edit applied to " + file_path);
    }

    # Preview edits without executing
    can preview_edits() {
        report("[EditingWalker] Previewing edit queue:");
        int i = 1;
        for (task in this.edit_queue) {
            report("  " + str(i) + ". File: " + task["file"] + ", Description: " + task["desc"]);
            string snippet_preview = substring(task["code"].replace("\n", " "), 0, 60);
            if len(task["code"]) > 60 {
                snippet_preview = snippet_preview + "...";
            }
            report("     Code snippet preview: " + snippet_preview);
            i = i + 1;
        }
    }

    # Remove a task from the queue by file path
    can remove_edit_task(string file_path) {
        list new_queue = [];
        for (t in this.edit_queue) {
            if t["file"] != file_path {
                new_queue += [t];
            }
        }
        this.edit_queue = new_queue;
        report("[EditingWalker] Removed tasks for file " + file_path);
    }

    # Clear all queued edits
    can clear_queue() {
        this.edit_queue.clear();
        report("[EditingWalker] Cleared all edit tasks.");
    }
}

# End of editing_walker.jac
