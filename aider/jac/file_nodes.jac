# ==========================================
# file_nodes.jac
# Core OSP module: Defines file and code-level nodes
# ==========================================

node CodeFile {
    has string filename;
    has string language;       # e.g., "python", "java", "cpp"
    has int total_tokens = 0;  # total tokens in file
    has bool is_test_file = false;

    can log_info() {
        std.log("📄 File: " + filename + " (" + language + "), Tokens=" + str(total_tokens));
    }
}

node FunctionNode {
    has string name;
    has list<string> parameters;
    has string return_type;
    has int start_line;
    has int end_line;
    has int token_count;

    can signature() -> string {
        return name + "(" + ",".join(parameters) + ") : " + return_type;
    }

    can log_info() {
        std.log("🔹 Function: " + signature() + " [Lines " + str(start_line) + "-" + str(end_line) + "]");
    }
}

node ClassNode {
    has string name;
    has list<string> base_classes;
    has int start_line;
    has int end_line;
    has int token_count;

    can log_info() {
        std.log("🏛 Class: " + name + " (extends " + ",".join(base_classes) + ")");
    }
}

node ImportNode {
    has string module_name;
    has string import_type; # "internal" or "external"
    
    can log_info() {
        std.log("📦 Import: " + module_name + " [" + import_type + "]");
    }
}

# ========================
# Relationships
# ========================

edge contains;   # CodeFile -> FunctionNode, ClassNode, ImportNode
edge imports;    # CodeFile -> CodeFile (dependency)

# ========================
# Example usage behaviors
# ========================

walker file_logger {
    start {
        std.log("=== Logging File Graph ===");
        visit (*);
    }

    has seen_files = set();

    visit {
        if (here is CodeFile and here not in seen_files) {
            here.log_info();
            seen_files.add(here);
            visit(out:contains);
            visit(out:imports);
        }
        elif (here is FunctionNode) {
            here.log_info();
        }
        elif (here is ClassNode) {
            here.log_info();
        }
        elif (here is ImportNode) {
            here.log_info();
        }
    }

    stop {
        std.log("=== End of File Graph ===");
    }
}
