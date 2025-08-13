# edge_definitions.jac
# Define relationships between nodes

edge Calls {
    from FunctionNode;
    to FunctionNode;
}

edge Imports {
    from FileNode;
    to FileNode;
}

edge Contains {
    from FileNode;
    to FunctionNode;
}
