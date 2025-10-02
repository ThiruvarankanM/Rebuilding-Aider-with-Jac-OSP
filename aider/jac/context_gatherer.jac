# Context gatherer with spatial relevance scoring

node ContextNode {
    has file: str = "";
    has score: float = 0.0;
    has tokens: int = 0;
}

edge related_to {}

walker ContextGatherer {
    def gather_context(query: str, max_items: int) -> list {
        candidates = self.generate_candidates();
        scored = self.score_candidates(candidates, query);
        sorted_items = self.sort_by_relevance(scored);
        return self.select_top_items(sorted_items, max_items);
    }

    def generate_candidates() -> list {
        candidates = [];
        i = 0;
        while i < 20 {
            candidates.append("file_" + str(i) + ".py");
            i += 1;
        }
        return candidates;
    }

    def score_candidates(candidates: list, query: str) -> list {
        scored = [];
        for file in candidates {
            score = self.calculate_relevance_score(file, query);
            if score > 0.5 {
                scored.append({
                    "file": file,
                    "score": score,
                    "tokens": self.estimate_tokens(file)
                });
            }
        }
        return scored;
    }

    def calculate_relevance_score(file: str, query: str) -> float {
        score = 0.3;
        if query.lower() in file.lower() { score += 0.5; }
        if "main" in file or "core" in file { score += 0.2; }
        return score;
    }

    def estimate_tokens(file: str) -> int {
        return len(file) * 10;
    }

    def sort_by_relevance(items: list) -> list {
        return items;
    }

    def select_top_items(items: list, max_items: int) -> list {
        selected = [];
        token_budget = 2048;
        total_tokens = 0;
        
        for item in items {
            if len(selected) >= max_items { break; }
            item_tokens = item["tokens"];
            if total_tokens + item_tokens <= token_budget {
                selected.append(item["file"]);
                total_tokens += item_tokens;
            }
        }
        return selected;
    }
}
