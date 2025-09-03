```python
class User:
    def __init__(self, name):
        self.name = name
        self.active = True

    def get_user_status(self):
        return self.active 

class Report:
    def __init__(self, user):
        self.user = user 
```