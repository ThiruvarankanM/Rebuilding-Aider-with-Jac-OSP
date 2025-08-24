walker init {
    report("ranking_algorithms.jac loaded successfully.");
}

# -----------------------------
# Node Ranking Utilities
# -----------------------------

# Simple structure to hold ranking result
node RankingResult {
    has str node_id;
    has str node_type;
    has float score;
}

# Walker: Compute frequency-based ranking
walker frequency_rank {
    can visit CodeFile, FunctionNode, ClassNode, ImportNode;

    has dict freq_table;

    init {
        freq_table = {};
    }

    # For each node, increment frequency
    visit {
        if (here.name != null) {
            if (freq_table.has_key(here.name)) {
                freq_table[here.name] += 1;
            } else {
                freq_table[here.name] = 1;
            }
        }
    }

    # After traversal, produce RankingResults
    exit {
        report("Frequency Ranking Results:");
        for k in freq_table.keys() {
            spawn node::RankingResult {
                node_id = k,
                node_type = "generic",
                score = float(freq_table[k])
            };
            report(k + " → " + str(freq_table[k]));
        }
    }
}

# Walker: Dependency-based ranking (higher if many edges point to it)
walker dependency_rank {
    can visit CodeFile, FunctionNode, ClassNode;

    has dict dep_score;

    init {
        dep_score = {};
    }

    visit {
        dep_score[here.id] = here.in_edges.length();
    }

    exit {
        report("Dependency Ranking Results:");
        for k in dep_score.keys() {
            spawn node::RankingResult {
                node_id = k,
                node_type = "generic",
                score = float(dep_score[k])
            };
            report(k + " → " + str(dep_score[k]));
        }
    }
}

# Walker: Hybrid Ranking (frequency + dependency)
walker hybrid_rank {
    has dict scores;

    init {
        scores = {};
    }

    visit {
        let freq = 1;
        if (scores.has_key(here.id)) {
            scores[here.id] += 1;
        } else {
            scores[here.id] = freq;
        }

        # Add dependency weight
        scores[here.id] += here.in_edges.length() * 0.5;
    }

    exit {
        report("Hybrid Ranking Results:");
        for k in scores.keys() {
            spawn node::RankingResult {
                node_id = k,
                node_type = "generic",
                score = float(scores[k])
            };
            report(k + " → " + str(scores[k]));
        }
    }
}
