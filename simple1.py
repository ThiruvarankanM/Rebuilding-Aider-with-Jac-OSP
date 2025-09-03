class User:
    def __init__(self, name, email=None, phone=None):
        self.name = name
        self.email = email
        self.active = True
        self.phone = phone
    
    def get_contact_info(self):
        """Return formatted contact information"""
        contacts = []
        if self.email:
            contacts.append(f"Email: {self.email}")
        if self.phone:
            contacts.append(f"Phone: {self.phone}")
        return ", ".join(contacts) if contacts else "No contact info available"
    
    def update_status(self, status):
        """Update user active status"""
        if isinstance(status, bool):
            self.active = status
            return True
        return False
    
    def get_profile_summary(self):
        """Get complete user profile summary"""
        return {
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "active": self.active,
            "contact_info": self.get_contact_info()
        }