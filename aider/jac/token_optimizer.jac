# token_optimizer.jac
# Utility for managing token budgets and compressing content

import * from file_nodes;
import * from ranking_algorithms;

node TokenBudget {
    has int max_tokens;              # Maximum allowed tokens
    has int used_tokens = 0;         # Tokens already used
    has float compression_rate = 0.5 # Default compression (50%)
}

walker TokenOptimizer {
    can process(CodeFile),
        compress(CodeFile),
        summarize(FunctionNode),
        summarize(ClassNode);

    has int budget_limit = 4000;     # Default total budget
    has int safety_margin = 500;     # Leave some margin

    can entry {
        std.log(f"TokenOptimizer started. Budget limit: {budget_limit}");
    }

    # Process a file and decide whether to compress
    can process(CodeFile) {
        int approx_tokens = len(this.content)  # Rough proxy: characters ~ tokens
        if approx_tokens + global.used_tokens > budget_limit - safety_margin:
            std.log(f"File {this.filename} too large, compressing...")
            compress(this)
        else:
            global.used_tokens += approx_tokens
            std.log(f"Accepted file {this.filename} (tokens used: {global.used_tokens})")
    }

    # Compression logic: reduce function/class details
    can compress(CodeFile) {
        global.used_tokens += int(len(this.content) * global.compression_rate)
        this.content = f"[COMPRESSED CONTENT of {this.filename}]"
        std.log(f"Compressed {this.filename} (tokens used: {global.used_tokens})")
    }

    # Summarize functions
    can summarize(FunctionNode) {
        string summary = f"Function {this.name} with {len(this.parameters)} params."
        this.code = f"[SUMMARY] {summary}"
    }

    # Summarize classes
    can summarize(ClassNode) {
        string summary = f"Class {this.name} with {len(this.methods)} methods."
        this.docstring = f"[SUMMARY] {summary}"
    }
}

# Global token budget instance
global TokenBudget global_budget = TokenBudget {
    max_tokens: 4000,
    used_tokens: 0,
    compression_rate: 0.5
}
