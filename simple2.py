from simple1 import User

class Report:
    def __init__(self, user_name="John Doe", email="john@example.com"):
        self.user = User(user_name, email=email)
        self.created_at = None
        self.report_data = {}
        
    def get_status(self):
        """Get user status with contact information"""
        status = 'active' if self.user.active else 'inactive'
        contact = self.user.get_contact_info()
        return f"{self.user.name} is {status}. Contact: {contact}"
    
    def generate_report(self):
        """Generate comprehensive user report"""
        self.report_data = {
            "user_profile": self.user.get_profile_summary(),
            "status": "active" if self.user.active else "inactive",
            "timestamp": self._get_current_timestamp()
        }
        return self.report_data
    
    def _get_current_timestamp(self):
        """Get current timestamp for report"""
        from datetime import datetime
        return datetime.now().isoformat()
    
    def save_report(self, filename=None):
        """Save report to file (placeholder for real implementation)"""
        if not filename:
            filename = f"report_{self.user.name.replace(' ', '_').lower()}.json"
        
        # In real implementation, this would save to file
        # For now, return the data that would be saved
        import json
        report_json = json.dumps(self.generate_report(), indent=2)
        print(f"Report saved to {filename}")
        return report_json
