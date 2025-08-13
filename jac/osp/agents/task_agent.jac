# task_agent.jac
# Agent that manages tasks autonomously

agent TaskAgent {
    has task_list: list[str];

    can add_task(task: str) {
        task_list.append(task);
        print("Task added: " + task);
    }

    can complete_task(task: str) {
        if task in task_list {
            task_list.remove(task);
            print("Task completed: " + task);
        }
    }

    can list_tasks() -> list[str] {
        return task_list;
    }
}
