# token_optimizer.jac
# Utility for managing token budgets and compressing content

# Import nodes from file_nodes
import * from file_nodes;
import * from ranking_algorithms;

node TokenBudget {
    has int max_tokens;         # Maximum allowed tokens
    has int used_tokens = 0;    # Tokens already used
    has float compression_rate = 0.5;  # Default compression (50%)
}

walker TokenOptimizer {
    can process(CodeFile),
        compress(CodeFile),
        summarize(FunctionNode),
        summarize(ClassNode);

    has int budget_limit = 4000;   # Default total budget
    has int safety_margin = 500;   # Leave some margin

    can entry {
        report("TokenOptimizer started. Budget limit: " + str(budget_limit));
    }

    # Process a file and decide whether to compress
    can process(CodeFile) {
        int approx_tokens = len(this.content);   # Rough proxy: characters ~ tokens
        if (approx_tokens + global.used_tokens > budget_limit - safety_margin) {
            report("File " + this.name + " too large, compressing...");
            compress(this);
        } else {
            global.used_tokens += approx_tokens;
            report("Accepted file " + this.name + " (tokens used: " + str(global.used_tokens) + ")");
        }
    }

    # Compression logic: reduce function/class details
    can compress(CodeFile) {
        global.used_tokens += int(len(this.content) * global.compression_rate);
        this.content = "[COMPRESSED CONTENT of " + this.name + "]";
        report("Compressed " + this.name + " (tokens used: " + str(global.used_tokens) + ")");
    }

    # Summarize functions
    can summarize(FunctionNode) {
        string summary = "Function " + this.name + " with " + str(len(this.parameters)) + " params.";
        this.code = "[SUMMARY] " + summary;
    }

    # Summarize classes
    can summarize(ClassNode) {
        string summary = "Class " + this.name + " with " + str(len(this.methods)) + " methods.";
        this.docstring = "[SUMMARY] " + summary;
    }
}

# Global token budget instance
global TokenBudget global = TokenBudget {
    max_tokens: 4000,
    used_tokens: 0,
    compression_rate: 0.5
};
