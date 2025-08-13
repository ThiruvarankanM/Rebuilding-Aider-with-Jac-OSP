# task_management.jac
# Define task management abilities

walker TaskManager {
    has tasks: list[str];

    can add_task(task: str) {
        tasks.append(task);
    }

    can list_tasks() -> list[str] {
        return tasks;
    }
}
