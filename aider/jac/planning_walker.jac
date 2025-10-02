# Planning walker with OSP spatial organization

node Task {
    has name: str = "";
    has complexity: str = "medium";
    has estimated_days: int = 2;
    has dependencies: list = [];
}

node Phase {
    has number: int = 1;
    has tasks: list = [];
    has duration: int = 0;
}

edge depends_on {}
edge contains {}

walker PlanningWalker {
    has max_tasks_per_phase: int = 3;
    
    def generate_plan(tasks: list, dependencies: dict) -> dict {
        phases = self.organize_into_phases(tasks);
        duration = self.calculate_duration(phases);
        risk = self.assess_risk(tasks, dependencies);
        
        return {
            "total_tasks": len(tasks),
            "phases": phases,
            "estimated_duration": duration,
            "risk_assessment": risk
        };
    }

    def organize_into_phases(tasks: list) -> list {
        phases = [];
        current_phase = [];
        
        for task in tasks {
            current_phase.append(task);
            if len(current_phase) >= self.max_tasks_per_phase {
                phases.append({
                    "number": len(phases) + 1,
                    "tasks": current_phase,
                    "duration": self.estimate_duration(current_phase)
                });
                current_phase = [];
            }
        }
        
        if len(current_phase) > 0 {
            phases.append({
                "number": len(phases) + 1,
                "tasks": current_phase,
                "duration": self.estimate_duration(current_phase)
            });
        }
        
        return phases;
    }

    def estimate_duration(tasks: list) -> int {
        total = 0;
        for task in tasks {
            complexity = task.get("complexity", "medium");
            if complexity == "high" {
                total += 5;
            } elif complexity == "medium" {
                total += 3;
            } else {
                total += 1;
            }
        }
        return total;
    }

    def calculate_duration(phases: list) -> int {
        total = 0;
        for phase in phases {
            total += phase["duration"];
        }
        return total + (total / 5);
    }

    def assess_risk(tasks: list, dependencies: dict) -> str {
        score = 0.0;
        if len(tasks) > 20 { score += 2.0; }
        elif len(tasks) > 10 { score += 1.0; }
        
        if score >= 4.0 { return "critical"; }
        elif score >= 2.5 { return "high"; }
        elif score >= 1.0 { return "medium"; }
        return "low";
    }
}
