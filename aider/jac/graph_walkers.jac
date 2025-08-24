# graph_walkers.jac
# Graph traversal walkers for RepoMap / SpatialGraph

# Depth-First Search walker
walker dfs(start: CodeFile, visit: callable):
    visited = set()
    stack = [start]

    while stack:
        current = stack.pop()
        if current not in visited:
            visit(current)
            visited.add(current)
            # Push neighbors to stack
            neighbors = here.get_neighbors(current)
            for neighbor in reversed(neighbors):
                if neighbor not in visited:
                    stack.append(neighbor)

# Breadth-First Search walker
walker bfs(start: CodeFile, visit: callable):
    visited = set()
    queue = [start]

    while queue:
        current = queue.pop(0)
        if current not in visited:
            visit(current)
            visited.add(current)
            neighbors = here.get_neighbors(current)
            for neighbor in neighbors:
                if neighbor not in visited:
                    queue.append(neighbor)

# Topological sort (Kahn's algorithm)
walker topological_sort() -> list[CodeFile]:
    in_degree = map[CodeFile, int]()
    all_nodes = here.get_all_nodes()
    
    # Initialize in-degree
    for node in all_nodes:
        in_degree[node] = 0
    for node, neighbors in here.adjacency.items():
        for neighbor in neighbors:
            in_degree[neighbor] += 1
    
    # Nodes with 0 in-degree
    zero_in = [node for node in all_nodes if in_degree[node] == 0]
    result = []

    while zero_in:
        node = zero_in.pop()
        result.append(node)
        for neighbor in here.get_neighbors(node):
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                zero_in.append(neighbor)

    if len(result) != len(all_nodes):
        std.warn("Graph has cycles; topological sort incomplete")
    
    return result

# Find all paths from source to target (DFS based)
walker find_all_paths(source: CodeFile, target: CodeFile) -> list[list[CodeFile]]:
    paths = []

    def dfs_path(node, path):
        path.append(node)
        if node == target:
            paths.append(list(path))
        else:
            for neighbor in here.get_neighbors(node):
                if neighbor not in path:
                    dfs_path(neighbor, path)
        path.pop()

    dfs_path(source, [])
    return paths

# Shortest path (BFS-based, unweighted)
walker shortest_path(source: CodeFile, target: CodeFile) -> list[CodeFile]:
    from collections import deque
    visited = set()
    parent = map[CodeFile, CodeFile]()
    queue = deque([source])
    visited.add(source)

    while queue:
        current = queue.popleft()
        if current == target:
            # Reconstruct path
            path = []
            while current:
                path.insert(0, current)
                current = parent.get(current, None)
            return path
        for neighbor in here.get_neighbors(current):
            if neighbor not in visited:
                visited.add(neighbor)
                parent[neighbor] = current
                queue.append(neighbor)
    
    return []  # No path found

# Debug walker: print traversal order
walker print_traversal(start: CodeFile, method: str = "dfs"):
    order = []

    def visitor(node):
        order.append(node.file_path)

    if method == "dfs":
        here.dfs(start, visitor)
    elif method == "bfs":
        here.bfs(start, visitor)
    else:
        std.warn(f"Unknown traversal method: {method}")
        return

    std.log(f"{method.upper()} traversal order: {order}")
