# walker_definitions.jac
# Define walkers to traverse nodes and edges

walker FileScanner {
    can scan_repo(root_path: str) -> list[FileNode] {
        // Implementation will explore files and create nodes
    }
}

walker DependencyMapper {
    can map_dependencies(files: list[FileNode]) -> list[edge] {
        // Implementation will map Calls, Imports, and Contains edges
    }
}
