# node_definitions.jac
# Define node types for repository mapping

node FileNode {
    has file_path: str;
    has content: str;
    has symbols: list[str];
    has dependencies: list[str];
}

node FunctionNode {
    has name: str;
    has parameters: list[str];
    has return_type: str;
    has parent_file: str;
}
