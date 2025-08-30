# file_nodes.jac
# Core OSP module: Defines file and code-level nodes

node CodeFile {
    has string filename;
    has string language;       # e.g., "python", "java", "cpp"
    has int total_tokens = 0;  # total tokens in file
    has bool is_test_file = false;

    can log_info() {
        report("📄 File: " + this.filename + " (" + this.language + "), Tokens=" + str(this.total_tokens));
    }
}

node FunctionNode {
    has string name;
    has list parameters = [];
    has string return_type = "";
    has int start_line = 0;
    has int end_line = 0;
    has int token_count = 0;

    can signature() -> string {
        string params = "";
        for (int i = 0; i < len(this.parameters); i = i + 1) {
            if i > 0 {
                params = params + ",";
            }
            params = params + this.parameters[i];
        }
        return this.name + "(" + params + ") : " + this.return_type;
    }

    can log_info() {
        report("🔹 Function: " + this.signature() + " [Lines " + str(this.start_line) + "-" + str(this.end_line) + "]");
    }
}

node ClassNode {
    has string name;
    has list base_classes = [];
    has int start_line = 0;
    has int end_line = 0;
    has int token_count = 0;

    can log_info() {
        string bases = "";
        for (int i = 0; i < len(this.base_classes); i = i + 1) {
            if i > 0 {
                bases = bases + ",";
            }
            bases = bases + this.base_classes[i];
        }
        report("🏛 Class: " + this.name + (len(bases) > 0 ? " (extends " + bases + ")" : ""));
    }
}

node ImportNode {
    has string module_name;
    has string import_type = ""; # "internal" or "external"
    
    can log_info() {
        report("📦 Import: " + this.module_name + " [" + this.import_type + "]");
    }
}

# Relationships
edge contains;   # CodeFile -> FunctionNode, ClassNode, ImportNode
edge imports;    # CodeFile -> CodeFile (dependency)

# Example usage behaviors
walker FileLogger {
    start {
        report("=== Logging File Graph ===");
        visit (*);
    }

    has list seen_files = [];

    visit {
        if (here is CodeFile and not (here in this.seen_files)) {
            here.log_info();
            this.seen_files += [here];
            visit(out:contains);
            visit(out:imports);
        } else if (here is FunctionNode) {
            here.log_info();
        } else if (here is ClassNode) {
            here.log_info();
        } else if (here is ImportNode) {
            here.log_info();
        }
    }

    stop {
        report("=== End of File Graph ===");
    }
}
