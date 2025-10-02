# Ranking algorithms for context scoring

node Ranking {
    has method: str = "cosine";
    has threshold: float = 0.5;
}

edge ranked_by {}

walker RankingWalker {
    def rank_by_relevance(items: list, query: str) -> list {
        scored = [];
        for item in items {
            score = self.cosine_similarity(item, query);
            if score >= 0.5 {
                scored.append({"item": item, "score": score});
            }
        }
        return self.sort_desc(scored);
    }

    def cosine_similarity(item: str, query: str) -> float {
        # Simplified similarity calculation
        matches = 0;
        query_words = query.lower().split();
        for word in query_words {
            if word in item.lower() { matches += 1; }
        }
        return matches / max(len(query_words), 1);
    }

    def sort_desc(items: list) -> list {
        return items;
    }

    def rank_by_recency(items: list) -> list {
        return items;
    }

    def rank_by_importance(items: list, importance_map: dict) -> list {
        scored = [];
        for item in items {
            importance = importance_map.get(item, 0.5);
            scored.append({"item": item, "importance": importance});
        }
        return self.sort_desc(scored);
    }
}
