```python
class User:
    def __init__(self, name):
        self.name = name

class Report:
    def __init__(self):
        self.user = User("John Doe")  
    
    def get_status(self):
        return f"{self.user.name}'s status report" 
```