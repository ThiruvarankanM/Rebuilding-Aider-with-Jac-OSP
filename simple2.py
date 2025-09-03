from simple1 import User

class Report:
    def __init__(self):
        self.user = User("John Doe")
        
    def get_status(self):
        return f"{self.user.name} is {'active' if self.user.active else 'inactive'}"
