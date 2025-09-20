"""Tests for the sample Python project."""

import pytest
from sample_project import greet, calculate_fibonacci, Calculator


class TestGreeting:
    """Tests for the greet function."""
    
    def test_greet_with_name(self):
        """Test greeting with a valid name."""
        result = greet("Alice")
        assert result == "Hello, Alice! Welcome to the automation template."
    
    def test_greet_with_empty_string(self):
        """Test greeting with empty string raises ValueError."""
        with pytest.raises(ValueError, match="Name must be a non-empty string"):
            greet("")
    
    def test_greet_with_none(self):
        """Test greeting with None raises ValueError."""
        with pytest.raises(ValueError, match="Name must be a non-empty string"):
            greet(None)
    
    def test_greet_with_non_string(self):
        """Test greeting with non-string raises ValueError."""
        with pytest.raises(ValueError, match="Name must be a non-empty string"):
            greet(123)


class TestFibonacci:
    """Tests for the calculate_fibonacci function."""
    
    def test_fibonacci_base_cases(self):
        """Test Fibonacci base cases."""
        assert calculate_fibonacci(0) == 0
        assert calculate_fibonacci(1) == 1
    
    def test_fibonacci_sequence(self):
        """Test Fibonacci sequence calculation."""
        expected = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
        for i, expected_val in enumerate(expected):
            assert calculate_fibonacci(i) == expected_val
    
    def test_fibonacci_negative_raises_error(self):
        """Test that negative input raises ValueError."""
        with pytest.raises(ValueError, match="n must be non-negative"):
            calculate_fibonacci(-1)


class TestCalculator:
    """Tests for the Calculator class."""
    
    def test_addition(self):
        """Test addition operation."""
        calc = Calculator()
        result = calc.add(5, 3)
        assert result == 8
        assert "5 + 3 = 8" in calc.get_history()
    
    def test_subtraction(self):
        """Test subtraction operation."""
        calc = Calculator()
        result = calc.subtract(10, 4)
        assert result == 6
        assert "10 - 4 = 6" in calc.get_history()
    
    def test_multiplication(self):
        """Test multiplication operation."""
        calc = Calculator()
        result = calc.multiply(6, 7)
        assert result == 42
        assert "6 × 7 = 42" in calc.get_history()
    
    def test_division(self):
        """Test division operation."""
        calc = Calculator()
        result = calc.divide(15, 3)
        assert result == 5
        assert "15 ÷ 3 = 5" in calc.get_history()
    
    def test_division_by_zero(self):
        """Test division by zero raises ZeroDivisionError."""
        calc = Calculator()
        with pytest.raises(ZeroDivisionError, match="Cannot divide by zero"):
            calc.divide(10, 0)
    
    def test_history_tracking(self):
        """Test that history is tracked correctly."""
        calc = Calculator()
        calc.add(1, 1)
        calc.subtract(5, 2)
        calc.multiply(3, 4)
        
        history = calc.get_history()
        assert len(history) == 3
        assert "1 + 1 = 2" in history
        assert "5 - 2 = 3" in history
        assert "3 × 4 = 12" in history
    
    def test_clear_history(self):
        """Test clearing calculation history."""
        calc = Calculator()
        calc.add(1, 1)
        calc.subtract(5, 2)
        
        assert len(calc.get_history()) == 2
        
        calc.clear_history()
        assert len(calc.get_history()) == 0
    
    def test_history_independence(self):
        """Test that get_history returns a copy."""
        calc = Calculator()
        calc.add(1, 1)
        
        history1 = calc.get_history()
        history2 = calc.get_history()
        
        # Modify one copy
        history1.append("modified")
        
        # Original and second copy should be unaffected
        assert "modified" not in calc.get_history()
        assert "modified" not in history2