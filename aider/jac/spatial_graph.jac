# spatial_graph.jac
# SpatialGraph implementation for OSP RepoMap

# A simple graph structure to model relationships between files/code nodes

node SpatialGraph:
    has
        map[CodeFile, set[CodeFile]] adjacency  # Key: node, Value: set of neighbors

# Add a node to the graph
walker add_node(node: CodeFile):
    if node not in here.adjacency:
        here.adjacency[node] = set()
        std.log(f"Node added: {node.file_path}")
    else:
        std.warn(f"Node {node.file_path} already exists in graph")

# Remove a node and all its edges
walker remove_node(node: CodeFile):
    if node not in here.adjacency:
        std.warn(f"Node {node.file_path} not found in graph")
        return
    # Remove edges from other nodes
    for other_node, neighbors in here.adjacency.items():
        neighbors.discard(node)
    # Remove node itself
    del here.adjacency[node]
    std.log(f"Node removed: {node.file_path}")

# Add a directed edge from source to target
walker add_edge(source: CodeFile, target: CodeFile):
    if source not in here.adjacency:
        here.add_node(source)
    if target not in here.adjacency:
        here.add_node(target)
    here.adjacency[source].add(target)
    std.log(f"Edge added: {source.file_path} -> {target.file_path}")

# Remove an edge
walker remove_edge(source: CodeFile, target: CodeFile):
    if source in here.adjacency:
        here.adjacency[source].discard(target)
        std.log(f"Edge removed: {source.file_path} -> {target.file_path}")

# Get neighbors of a node
walker get_neighbors(node: CodeFile) -> list[CodeFile]:
    if node not in here.adjacency:
        return []
    return list(here.adjacency[node])

# Check if a path exists between two nodes (DFS)
walker has_path(source: CodeFile, target: CodeFile) -> bool:
    visited = set()
    stack = [source]
    while stack:
        current = stack.pop()
        if current == target:
            return True
        if current not in visited:
            visited.add(current)
            stack.extend(here.adjacency.get(current, []))
    return False

# Get all nodes in the graph
walker get_all_nodes() -> list[CodeFile]:
    return list(here.adjacency.keys())

# Debug: print adjacency
walker print_graph():
    for node, neighbors in here.adjacency.items():
        neighbor_paths = [n.file_path for n in neighbors]
        std.log(f"{node.file_path} -> {neighbor_paths}")
