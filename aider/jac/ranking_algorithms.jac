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

    has map freq_table;

    init {
        freq_table = {};
    }

    visit {
        if here.name != null {
            if here.name in freq_table {
                freq_table[here.name] += 1;
            } else {
                freq_table[here.name] = 1;
            }
        }
    }

    exit {
        report("Frequency Ranking Results:");
        for k in freq_table.keys() {
            spawn RankingResult {
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

    has map dep_score;

    init {
        dep_score = {};
    }

    visit {
        dep_score[here.id] = here.in_edges.length();
    }

    exit {
        report("Dependency Ranking Results:");
        for k in dep_score.keys() {
            spawn RankingResult {
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
    has map scores;

    init {
        scores = {};
    }

    visit {
        let freq = 1.0;
        if here.id in scores {
            scores[here.id] += freq;
        } else {
            scores[here.id] = freq;
        }

        # Add dependency weight
        scores[here.id] += here.in_edges.length() * 0.5;
    }

    exit {
        report("Hybrid Ranking Results:");
        for k in scores.keys() {
            spawn RankingResult {
                node_id = k,
                node_type = "generic",
                score = float(scores[k])
            };
            report(k + " → " + str(scores[k]));
        }
    }
}
