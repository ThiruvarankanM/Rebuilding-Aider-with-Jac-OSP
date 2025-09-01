# test_methods.jac
# Test file to isolate the method syntax issue

walker TestWalker {
    has test_data: list = [];

    # Generate a plan for tasks
    can generate_plan() {
        tasks = ["task1", "task2", "task3"];
        results = [];
        
        for task in tasks {
            results.append(task);
        }
        
        print("Generated plan with " + str(len(results)) + " tasks");
        return results;
    }
}

with entry {
    tw = spawn here TestWalker;
    result = tw.generate_plan();
    print("Test completed successfully");
}
