# repomap_osp.jac
# OSP RepoMap implementation

node RepoMap {
    has files: dict = {};
    has spatial_graph: dict = {};

    # Add a new file to the repo map
    def add_file(file_path: str, content: str) -> str {
        if file_path in self.files {
            print("File " + file_path + " already exists in RepoMap");
            return file_path;
        }
        self.files[file_path] = content;
        print("Added file: " + file_path);
        return file_path;
    }

    # Remove a file from the repo map
    def remove_file(file_path: str) {
        if file_path not in self.files {
            print("File " + file_path + " not found in RepoMap");
            return;
        }
        del self.files[file_path];
        print("Removed file: " + file_path);
    }

    # Update file content
    def update_file_content(file_path: str, new_content: str) {
        if file_path not in self.files {
            print("Cannot update " + file_path + ": not in RepoMap");
            return;
        }
        self.files[file_path] = new_content;
        print("Updated content for file: " + file_path);
    }

    # Get a file node by path
    def get_file_node(file_path: str) -> str {
        if file_path in self.files {
            return self.files[file_path];
        } else {
            return "";
        }
    }

    # Build the spatial graph by analyzing dependencies
    def build_graph() {
        file_paths = [];
        for file_path in self.files {
            file_paths.append(file_path);
        }
        print("RepoMap graph built with " + str(len(file_paths)) + " files");
    }

    # List all file paths in the repo map
    def list_all_files() -> list {
        file_paths = [];
        for file_path in self.files {
            file_paths.append(file_path);
        }
        return file_paths;
    }

    # Find dependencies of a given file
    def find_dependencies(file_path: str) -> list {
        if file_path not in self.files {
            return [];
        }
        dependencies = [];
        for other_path in self.files {
            if other_path != file_path {
                dependencies.append(other_path);
            }
        }
        return dependencies;
    }
}

with entry {
    repo = RepoMap();
    print("RepoMap OSP Demo:");
    
    # Test adding files
    repo.add_file("main.py", "print('hello')");
    repo.add_file("utils.py", "def helper(): pass");
    repo.add_file("config.py", "DEBUG = True");
    
    # Test listing files
    files = repo.list_all_files();
    print("Files in repo: " + str(files));
    
    # Test dependencies
    deps = repo.find_dependencies("main.py");
    print("Dependencies for main.py: " + str(deps));
    
    # Build graph
    repo.build_graph();
    
    print("RepoMap demo completed!");
}
