# ranking_algorithms.jac
# Node ranking utilities for RepoMap analysis

node RankingResult {
    has node_id: str;
    has node_type: str;
    has score: float;
}

walker RankingAlgorithms {
    has results: list = [];

    # Frequency-based ranking
    def frequency_rank() -> dict {
        freq_table = {};
        nodes = ["node1", "node2", "node3", "node1"];
        
        for node in nodes {
            if node in freq_table {
                freq_table[node] = freq_table[node] + 1;
            } else {
                freq_table[node] = 1;
            }
        }
        
        print("Frequency Ranking Results:");
        for node in freq_table {
            score = freq_table[node];
            print(node + " → " + str(score));
        }
        
        return freq_table;
    }

    # Dependency-based ranking
    def dependency_rank() -> dict {
        dep_scores = {};
        nodes = ["node1", "node2", "node3"];
        
        for node in nodes {
            dep_count = len(node);
            dep_scores[node] = dep_count;
        }
        
        print("Dependency Ranking Results:");
        for node in dep_scores {
            score = dep_scores[node];
            print(node + " → " + str(score));
        }
        
        return dep_scores;
    }

    # Hybrid ranking combining frequency and dependency
    def hybrid_rank() -> dict {
        freq_scores = self.frequency_rank();
        dep_scores = self.dependency_rank();
        hybrid_scores = {};
        
        print("Hybrid Ranking Results:");
        for node in freq_scores {
            freq_weight = freq_scores[node];
            dep_weight = 0;
            if node in dep_scores {
                dep_weight = dep_scores[node];
            }
            total_score = freq_weight + dep_weight * 0.5;
            
            hybrid_scores[node] = total_score;
            print(node + " → " + str(total_score));
        }
        
        return hybrid_scores;
    }

    # Get top ranked nodes
    def get_top_ranked() -> list {
        print("Getting top ranked nodes...");
        scores = self.hybrid_rank();
        top_nodes = [];
        
        for node in scores {
            top_nodes.append(node);
        }
        
        print("Top nodes: " + str(top_nodes));
        return top_nodes;
    }

    # Run all ranking algorithms
    def run_all_rankings() {
        print("Running all ranking algorithms:");
        self.get_top_ranked();
        print("All rankings completed!");
    }
}

with entry {
    ra = RankingAlgorithms();
    print("Ranking Algorithms Demo:");
    ra.run_all_rankings();
}