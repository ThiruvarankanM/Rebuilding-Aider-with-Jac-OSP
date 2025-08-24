Here’s a detailed **`jac_integration.md`** for your project:

```markdown
# Jac Integration Documentation

## Overview

The **Jac Integration** in Aider provides a bridge between **Python** and **Jac**, enabling the use of advanced autonomous reasoning, graph-based repository analysis, and multi-step planning.  
This allows Aider to leverage Jac walkers, nodes, and algorithms while maintaining Python-friendly APIs.

Jac integration is structured into:

- **Core Jac modules**: RepoMap, FileNodes, GraphWalkers
- **Support utilities**: Token optimizer, ranking, impact analysis
- **MTP / Genius mode modules**: Planning, editing, validation walkers
- **Python ↔ Jac bridge**: Interfaces and helpers for Python code

---

## Folder Structure

```

aider/
└── jac/
├── repomap\_osp.jac
├── file\_nodes.jac
├── graph\_walkers.jac
├── ranking\_algorithms.jac
├── token\_optimizer.jac
├── change\_coordinator.jac
├── impact\_analyzer.jac
├── context\_gatherer.jac
├── planning\_walker.jac
├── editing\_walker.jac
├── validation\_walker.jac
├── genius\_agent.jac
└── integration/
├── jac\_bridge.py
├── osp\_interface.py
└── mtp\_interface.py

````

---

## Python ↔ Jac Bridge

### 1. `jac_bridge.py`
- Handles **low-level communication** between Python and Jac runtime.
- Provides functions to **invoke Jac walkers**, run Jac nodes, and retrieve results.
- Example:

```python
from aider.jac.integration.jac_bridge import JacBridge

bridge = JacBridge()
result = bridge.run_walker("PlanningWalker", task="Refactor auth module")
print(result)
````

---

### 2. `osp_interface.py`

* High-level **OSP (Open Source Planner) interface** for Python.
* Exposes repo graph analysis, file ranking, and dependency traversal.
* Example:

```python
from aider.jac.integration.osp_interface import OSPInterface

osp = OSPInterface()
osp.load_repository(".")
top_files = osp.rank_files(limit=5)
print(top_files)
```

---

### 3. `mtp_interface.py`

* High-level **MTP / Genius Mode interface** for autonomous task execution.
* Combines multiple walkers: Planning → Editing → Validation.
* Example:

```python
from aider.jac.integration.mtp_interface import MTPInterface

mtp = MTPInterface()
mtp.load_repo(".")
plan = mtp.create_plan("Optimize data pipeline")
mtp.apply_plan(plan)
results = mtp.validate_changes()
```

---

## Usage Guidelines

1. **Load Repository**

   * All Jac walkers operate on a loaded RepoMap.
   * Use `.load_repo()` to initialize the repository graph.

2. **Walkers**

   * **PlanningWalker**: Generates task plan.
   * **EditingWalker**: Executes code changes.
   * **ValidationWalker**: Ensures correctness.

3. **Token Management**

   * Integrated token optimization ensures prompt size stays within limits.
   * Use `token_optimizer.jac` indirectly via Python interfaces.

4. **Error Handling**

   * Jac runtime errors propagate through Python bridge.
   * Use try-except blocks in Python when calling walkers.

---

## Best Practices

* Always **validate repository state** after edits.
* Combine **OSP ranking** with Genius Mode to prioritize important files.
* Keep **Jac modules updated** when repository structure changes.
* Enable verbose logging in Jac for debugging complex multi-file changes.

---

## References

* Jac Documentation: [https://jaclang.org/docs](https://jaclang.org/docs)
* Genius Mode: See `genius_mode_guide.md`
* RepoMap: See `osp_architecture.md`

---

**End of Jac Integration Documentation**

```

Next, I can provide **`migration_guide.md`**, the last documentation file. Do you want me to continue with that?
```
