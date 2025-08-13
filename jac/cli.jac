# cli.jac
# Command Line Interface for Jac-Aider

func run_command(command: str) {
    print("Running command: " + command)
    # Parse and dispatch commands to agents
}

walker CLI {
    can start() {
        print("CLI ready. Type commands to interact with Jac-Aider.")
        # Here you can read input and call run_command()
    }
}
