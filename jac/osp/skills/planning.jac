# planning.jac
# Define planning strategies

walker Planner {
    has plan_steps: list[str];

    can create_plan(goal: str) {
        // Example: split goal into actionable steps
        plan_steps = ["Step 1 for " + goal, "Step 2 for " + goal];
    }

    can show_plan() -> list[str] {
        return plan_steps;
    }
}
