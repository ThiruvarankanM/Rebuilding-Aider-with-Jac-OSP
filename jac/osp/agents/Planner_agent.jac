# planner_agent.jac
# Agent responsible for creating and managing plans

agent PlannerAgent {
    has plans: list[str];

    can create_plan(goal: str) {
        plans.append("Plan for: " + goal);
        print("Plan created for goal: " + goal);
    }

    can list_plans() -> list[str] {
        return plans;
    }
}
