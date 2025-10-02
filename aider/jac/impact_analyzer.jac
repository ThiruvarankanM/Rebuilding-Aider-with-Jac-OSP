# Impact analyzer with OSP spatial relationships

node FileImpact {
    has file_path: str = "";
    has impact_score: float = 0.0;
    has risk_level: str = "low";
    has dependencies: list = [];
}

edge impacts {}
edge depends_on {}

walker ImpactAnalyzer {
    def analyze_change_impact(change_desc: str, affected_files: list) -> dict {
        total_impact = 0.0;
        for file_path in affected_files {
            total_impact += self.calculate_file_impact(file_path);
        }
        
        return {
            "change_id": "impact_" + str(len(affected_files)),
            "description": change_desc,
            "affected_files": affected_files,
            "impact_score": total_impact,
            "risk_level": self.determine_risk(total_impact),
            "dependencies": self.find_dependencies(affected_files)
        };
    }

    def calculate_file_impact(file_path: str) -> float {
        score = 0.5;
        if "main" in file_path or "__init__" in file_path { score += 2.0; }
        if "test" in file_path { score += 0.5; }
        if "util" in file_path or "helper" in file_path { score += 1.0; }
        return score;
    }

    def determine_risk(impact_score: float) -> str {
        if impact_score >= 5.0 { return "critical"; }
        elif impact_score >= 3.0 { return "high"; }
        elif impact_score >= 1.5 { return "medium"; }
        return "low";
    }

    def find_dependencies(files: list) -> list {
        deps = [];
        for file_path in files {
            if "." in file_path {
                base_name = file_path.split(".")[0];
                deps.append(base_name);
            }
        }
        return deps;
    }
}
