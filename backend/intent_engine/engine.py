class IntentEngine:
    def __init__(self):
        pass

    def process(self, command: str) -> str:
        command = command.lower()
        
        if "weather" in command:
            return "I cannot check the weather yet, but it seems nice outside."
        elif "news" in command:
            return "No news is good news, right?"
        elif "joke" in command:
            return "Why did the robot go to the doctor? Because it had a virus!"
        else:
            return f"I received your command: '{command}', but I am not sure how to handle it remotely."
