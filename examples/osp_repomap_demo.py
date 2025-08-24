"""
osp_repomap_demo.py

Demonstrates the usage of the OSP RepoMap in the Aider system.
Shows how to create a repo map, add files, traverse nodes, and analyze structure.
"""

from aider.jac.integration.osp_interface import OSPInterface

def osp_demo():
    print("=== OSP RepoMap Demo ===")

    # Step 1: Initialize OSP Interface
    osp = OSPInterface()
    print("OSP Interface initialized.")

    # Step 2: Load repository structure
    try:
        osp.load_repo(".")  # Load current working directory
        print(f"Repository loaded: {len(osp.repo_map.files)} files discovered.")
    except Exception as e:
        print(f"Error loading repository: {e}")
        return

    # Step 3: Display top-level files and nodes
    print("\nTop-level files in the repo:")
    for file_node in osp.repo_map.get_top_level_files():
        print(f" - {file_node.path} ({file_node.type})")

    # Step 4: Traverse functions and classes
    print("\nFunctions and classes found:")
    for node in osp.repo_map.get_all_nodes():
        if node.type in ["function", "class"]:
            print(f" - {node.type.title()}: {node.name} in {node.file.path}")

    # Step 5: Example ranking of files
    print("\nRanking files by importance (example):")
    ranked_files = osp.rank_files()
    for i, f in enumerate(ranked_files[:10], start=1):
        print(f" {i}. {f.path} - Score: {f.score}")

    # Step 6: Optionally, perform a simple query on RepoMap
    print("\nQuery example: Find nodes with 'demo' in name")
    demo_nodes = osp.find_nodes_by_name("demo")
    for node in demo_nodes:
        print(f" - {node.type.title()}: {node.name} in {node.file.path}")

if __name__ == "__main__":
    osp_demo()
