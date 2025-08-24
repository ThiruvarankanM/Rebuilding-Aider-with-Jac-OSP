# repomap_osp.jac
# OSP RepoMap implementation using file_nodes.jac

# Import dependencies
can RepoMap has
    walker build_graph
    walker get_file_node
    walker list_all_files
    walker add_file
    walker remove_file
    walker update_file_content
    walker find_dependencies

node RepoMap:
    has
        map[string, CodeFile] files  # Keyed by file path
        SpatialGraph spatial_graph

# Add a new file to the repo map
walker add_file(file_path: string, content: string = "") -> CodeFile:
    if file_path in here.files:
        std.warn(f"File {file_path} already exists in RepoMap")
        return here.files[file_path]
    new_file = CodeFile(file_path=file_path, content=content)
    here.files[file_path] = new_file
    here.spatial_graph.add_node(new_file)
    std.log(f"Added file: {file_path}")
    return new_file

# Remove a file from the repo map
walker remove_file(file_path: string):
    if file_path not in here.files:
        std.warn(f"File {file_path} not found in RepoMap")
        return
    node = here.files[file_path]
    here.spatial_graph.remove_node(node)
    del here.files[file_path]
    std.log(f"Removed file: {file_path}")

# Update file content
walker update_file_content(file_path: string, new_content: string):
    if file_path not in here.files:
        std.error(f"Cannot update {file_path}: not in RepoMap")
        return
    file_node = here.files[file_path]
    file_node.content = new_content
    std.log(f"Updated content for file: {file_path}")

# Get a file node by path
walker get_file_node(file_path: string) -> CodeFile:
    return here.files.get(file_path, None)

# Build the spatial graph by analyzing dependencies
walker build_graph():
    for file_path, code_file in here.files.items():
        deps = code_file.extract_dependencies()  # Returns list of paths
        for dep_path in deps:
            dep_node = here.files.get(dep_path, None)
            if dep_node:
                here.spatial_graph.add_edge(code_file, dep_node)
    std.log("RepoMap graph built with dependencies")

# List all file paths in the repo map
walker list_all_files() -> list[string]:
    return [file_path for file_path in here.files]

# Find dependencies of a given file
walker find_dependencies(file_path: string) -> list[CodeFile]:
    node = here.files.get(file_path, None)
    if not node:
        return []
    return here.spatial_graph.get_neighbors(file_path)
