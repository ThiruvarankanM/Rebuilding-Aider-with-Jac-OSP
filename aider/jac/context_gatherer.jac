# context_gatherer.jac
# Smart context collection utilities
# Collects the most relevant nodes/files from the RepoMap for a given query or task.

import from repomap_osp { * };
import from spatial_graph { * };
import from ranking_algorithms { * };

node ContextGatherer {
    # Configurable token budget for context collection
    has int token_budget = 2048;

    # Balance between semantic similarity vs. structural importance
    has float semantic_weight = 0.6;
    has float structural_weight = 0.4;

    # Gather top-k nodes/files relevant to a query
    can gather_context(string query, int max_items=10) -> list {
        list results = [];

        # Step 1: Get candidate nodes (RepoMap + Spatial Graph neighbors)
        list candidates = [];
        with entry=RepoMap {
            candidates += entry->functions;
            candidates += entry->classes;
            candidates += entry->imports;
            candidates += entry->files;
        }

        # Step 2: Score candidates using ranking algorithms
        map scored = {};
        for (n in candidates) {
            float semantic_score = rank_semantic(n, query);
            float structural_score = rank_by_degree(n);

            float combined = (semantic_weight * semantic_score) +
                             (structural_weight * structural_score);
            scored[n] = combined;
        }

        # Step 3: Sort and select top candidates
        list top_nodes = sort_dict_by_value(scored, true);
        top_nodes = top_nodes[0:max_items];

        # Step 4: Ensure token budget isn’t exceeded
        int used_tokens = 0;
        for (n in top_nodes) {
            int size = estimate_tokens(n);
            if used_tokens + size > token_budget {
                break;
            }
            results += [n];
            used_tokens += size;
        }

        return results;
    }

    # Estimate token usage of a node/file
    can estimate_tokens(node n) -> int {
        if n.code {
            return int(len(n.code) / 4);   # rough estimate (4 chars per token avg)
        }
        return 10;
    }

    # Utility: sort dict by value -> returns list of keys sorted by value (desc by default)
    can sort_dict_by_value(map d, bool descending=true) -> list {
        list items = [];
        for (k, v) in d {
            items += [(k, v)];
        }
        # sort ascending by value
        items.sort(lambda a, b: (a[1] < b[1]));
        if descending {
            items.reverse();
        }
        list keys = [];
        for (p in items) {
            keys += [p[0]];
        }
        return keys;
    }
}
