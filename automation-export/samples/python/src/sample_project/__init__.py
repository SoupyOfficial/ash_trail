"""Sample Python project for testing automation template."""

__version__ = "0.1.0"


def greet(name: str) -> str:
    """Generate a greeting message.
    
    Args:
        name: The name to greet
        
    Returns:
        A friendly greeting message
    """
    if not name or not isinstance(name, str):
        raise ValueError("Name must be a non-empty string")
    
    return f"Hello, {name}! Welcome to the automation template."


def calculate_fibonacci(n: int) -> int:
    """Calculate the nth Fibonacci number.
    
    Args:
        n: The position in the Fibonacci sequence (0-indexed)
        
    Returns:
        The nth Fibonacci number
        
    Raises:
        ValueError: If n is negative
    """
    if n < 0:
        raise ValueError("n must be non-negative")
    
    if n <= 1:
        return n
    
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    
    return b


class Calculator:
    """A simple calculator class for demonstration."""
    
    def __init__(self):
        self.history = []
    
    def add(self, a: float, b: float) -> float:
        """Add two numbers."""
        result = a + b
        self.history.append(f"{a} + {b} = {result}")
        return result
    
    def subtract(self, a: float, b: float) -> float:
        """Subtract b from a."""
        result = a - b
        self.history.append(f"{a} - {b} = {result}")
        return result
    
    def multiply(self, a: float, b: float) -> float:
        """Multiply two numbers."""
        result = a * b
        self.history.append(f"{a} × {b} = {result}")
        return result
    
    def divide(self, a: float, b: float) -> float:
        """Divide a by b."""
        if b == 0:
            raise ZeroDivisionError("Cannot divide by zero")
        result = a / b
        self.history.append(f"{a} ÷ {b} = {result}")
        return result
    
    def clear_history(self):
        """Clear the calculation history."""
        self.history.clear()
    
    def get_history(self) -> list:
        """Get the calculation history."""
        return self.history.copy()