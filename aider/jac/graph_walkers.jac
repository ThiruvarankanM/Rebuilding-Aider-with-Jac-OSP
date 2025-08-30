# graph_walkers.jac
# Graph traversal walkers for RepoMap / SpatialGraph

walker GraphWalkers {

    # Depth-First Search
    can dfs(CodeFile start, callable visit) {
        set visited = {}
        list stack = [start]

        while len(stack) > 0 {
            CodeFile current = stack.pop()
            if current not in visited {
                visit(current)
                visited.add(current)
                list neighbors = this.get_neighbors(current)
                for neighbor in reversed(neighbors) {
                    if neighbor not in visited {
                        stack += [neighbor]
                    }
                }
            }
        }
    }

    # Breadth-First Search
    can bfs(CodeFile start, callable visit) {
        set visited = {}
        list queue = [start]

        while len(queue) > 0 {
            CodeFile current = queue.pop(0)
            if current not in visited {
                visit(current)
                visited.add(current)
                list neighbors = this.get_neighbors(current)
                for neighbor in neighbors {
                    if neighbor not in visited {
                        queue += [neighbor]
                    }
                }
            }
        }
    }

    # Topological sort (Kahn's algorithm)
    can topological_sort() -> list {
        map in_degree = {}
        list all_nodes = this.get_all_nodes()
        for node in all_nodes {
            in_degree[node] = 0
        }

        for node in all_nodes {
            for neighbor in this.get_neighbors(node) {
                in_degree[neighbor] = in_degree.get(neighbor, 0) + 1
            }
        }

        list zero_in = [node for node in all_nodes if in_degree[node] == 0]
        list result = []

        while len(zero_in) > 0 {
            CodeFile node = zero_in.pop()
            result += [node]
            for neighbor in this.get_neighbors(node) {
                in_degree[neighbor] -= 1
                if in_degree[neighbor] == 0 {
                    zero_in += [neighbor]
                }
            }
        }

        if len(result) != len(all_nodes) {
            std.warn("Graph has cycles; topological sort incomplete")
        }

        return result
    }

    # Find all paths (DFS-based)
    can find_all_paths(CodeFile source, CodeFile target) -> list {
        list paths = []

        can dfs_path(CodeFile node, list path) {
            path += [node]
            if node == target {
                paths += [list(path)]
            } else {
                for neighbor in this.get_neighbors(node) {
                    if neighbor not in path {
                        dfs_path(neighbor, path)
                    }
                }
            }
            path.pop()
        }

        dfs_path(source, [])
        return paths
    }

    # Shortest path (BFS-based, unweighted)
    can shortest_path(CodeFile source, CodeFile target) -> list {
        set visited = {source}
        map parent = {}
        list queue = [source]

        while len(queue) > 0 {
            CodeFile current = queue.pop(0)
            if current == target {
                list path = []
                while current != null {
                    path.insert(0, current)
                    current = parent.get(current, null)
                }
                return path
            }
            for neighbor in this.get_neighbors(current) {
                if neighbor not in visited {
                    visited.add(neighbor)
                    parent[neighbor] = current
                    queue += [neighbor]
                }
            }
        }

        return []  # No path found
    }

    # Debug: print traversal order
    can print_traversal(CodeFile start, string method = "dfs") {
        list order = []

        can visitor(node) {
            order += [node.filename]
        }

        if method == "dfs" {
            this.dfs(start, visitor)
        } elif method == "bfs" {
            this.bfs(start, visitor)
        } else {
            std.warn("Unknown traversal method: " + method)
            return
        }

        std.log(method.upper() + " traversal order: " + str(order))
    }

    # Placeholder: you must implement actual neighbor retrieval
    can get_neighbors(CodeFile node) -> list {
        return []  # override with actual graph logic
    }

    # Placeholder: retrieve all nodes in graph
    can get_all_nodes() -> list {
        return []  # override with actual node collection
    }
}
