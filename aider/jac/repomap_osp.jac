# repomap_osp.jac
# OSP RepoMap implementation using file_nodes.jac

import { CodeFile } from "file_nodes.jac"
import { SpatialGraph } from "spatial_graph.jac"

node RepoMap {
    has map[str, CodeFile] files = {};
    has SpatialGraph spatial_graph = SpatialGraph();

    # Add a new file to the repo map
    walker add_file(file_path: str, content: str = "") -> CodeFile:
        if file_path in here.files:
            std.warn(f"File {file_path} already exists in RepoMap")
            return here.files[file_path]
        new_file = CodeFile(filename=file_path, content=content)
        here.files[file_path] = new_file
        here.spatial_graph.add_node(new_file)
        std.log(f"Added file: {file_path}")
        return new_file

    # Remove a file from the repo map
    walker remove_file(file_path: str):
        if file_path not in here.files:
            std.warn(f"File {file_path} not found in RepoMap")
            return
        node = here.files[file_path]
        here.spatial_graph.remove_node(node)
        del here.files[file_path]
        std.log(f"Removed file: {file_path}")

    # Update file content
    walker update_file_content(file_path: str, new_content: str):
        if file_path not in here.files:
            std.error(f"Cannot update {file_path}: not in RepoMap")
            return
        file_node = here.files[file_path]
        file_node.content = new_content
        std.log(f"Updated content for file: {file_path}")

    # Get a file node by path
    walker get_file_node(file_path: str) -> CodeFile:
        return here.files[file_path] if file_path in here.files else null

    # Build the spatial graph by analyzing dependencies
    walker build_graph():
        for file_path in here.files.keys():
            code_file = here.files[file_path]
            deps = code_file.extract_dependencies()  # Must return list of paths
            for dep_path in deps:
                if dep_path in here.files:
                    dep_node = here.files[dep_path]
                    here.spatial_graph.add_edge(code_file, dep_node)
        std.log("RepoMap graph built with dependencies")

    # List all file paths in the repo map
    walker list_all_files() -> list[str]:
        return [file_path for file_path in here.files.keys()]

    # Find dependencies of a given file
    walker find_dependencies(file_path: str) -> list[CodeFile]:
        if file_path not in here.files:
            return []
        node = here.files[file_path]
        return here.spatial_graph.get_neighbors(node)
}
