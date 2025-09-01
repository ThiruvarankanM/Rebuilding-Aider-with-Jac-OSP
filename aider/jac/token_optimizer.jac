# token_optimizer.jac
# Utility for managing token budgets and compressing content

node TokenBudget {
    has max_tokens: int = 4000;      # Maximum allowed tokens
    has used_tokens: int = 0;        # Tokens already used
    has compression_rate: float = 0.5; # Default compression (50%)
}

node TokenOptimizer {
    has budget_limit: int = 4000;    # Default total budget
    has safety_margin: int = 500;    # Leave some margin
    has used_tokens: int = 0;        # Track used tokens

    # Process a file and decide whether to compress
    def process(filename: str, content: str) -> str {
        approx_tokens = len(content);  # Rough proxy: characters ~ tokens
        if approx_tokens + self.used_tokens > self.budget_limit - self.safety_margin {
            print("File " + filename + " too large, compressing...");
            return self.compress(filename, content);
        } else {
            self.used_tokens += approx_tokens;
            print("Accepted file " + filename + " (tokens used: " + str(self.used_tokens) + ")");
            return content;
        }
    }

    # Compression logic: reduce file content
    def compress(filename: str, content: str) -> str {
        compressed_tokens = int(len(content) * 0.5);
        self.used_tokens += compressed_tokens;
        compressed_content = "[COMPRESSED CONTENT of " + filename + "]";
        print("Compressed " + filename + " (tokens used: " + str(self.used_tokens) + ")");
        return compressed_content;
    }

    # Summarize functions
    def summarize_function(func_name: str, parameters: list) -> str {
        summary = "Function " + func_name + " with " + str(len(parameters)) + " params.";
        return "[SUMMARY] " + summary;
    }

    # Summarize classes  
    def summarize_class(class_name: str, methods: list) -> str {
        summary = "Class " + class_name + " with " + str(len(methods)) + " methods.";
        return "[SUMMARY] " + summary;
    }

    # Get current token usage
    def get_token_usage() -> int {
        return self.used_tokens;
    }

    # Reset token counter
    def reset_tokens() {
        self.used_tokens = 0;
        print("Token counter reset");
    }

    # Check if we're within budget
    def within_budget() -> bool {
        return self.used_tokens < (self.budget_limit - self.safety_margin);
    }
}

with entry {
    optimizer = TokenOptimizer();
    print("TokenOptimizer Demo:");
    print("Budget limit: " + str(optimizer.budget_limit));
    
    # Test processing small file
    small_content = "def hello(): print('world')";
    result1 = optimizer.process("small.py", small_content);
    print("Result 1: " + result1);
    
    # Test processing large file
    large_content = "# Very large file content" * 200;  # Simulate large file
    result2 = optimizer.process("large.py", large_content);
    print("Result 2 (truncated): " + result2[:50] + "...");
    
    # Test summarization
    func_summary = optimizer.summarize_function("my_function", ["param1", "param2"]);
    print("Function summary: " + func_summary);
    
    class_summary = optimizer.summarize_class("MyClass", ["method1", "method2", "method3"]);
    print("Class summary: " + class_summary);
    
    # Check usage
    print("Total tokens used: " + str(optimizer.get_token_usage()));
    print("Within budget: " + str(optimizer.within_budget()));
    
    print("TokenOptimizer demo completed!");
}
