# helper_functions.jac
# General utility functions for OSP agents

func greet(name: str) {
    print("Hello, " + name + "! Welcome to OSP system.")
}

func calculate_importance(score: int, weight: float) -> float {
    return score * weight
}

func format_list(items: list[str]) -> str {
    return ", ".join(items)
}
