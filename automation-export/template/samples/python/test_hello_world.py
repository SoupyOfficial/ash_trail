"""Tests for hello_world module."""

import pytest
from hello_world import hello_world


def test_hello_world_default():
    """Test default greeting."""
    result = hello_world()
    assert result == "Hello, World!"


def test_hello_world_custom_name():
    """Test greeting with custom name."""
    result = hello_world("Python")
    assert result == "Hello, Python!"


def test_hello_world_empty_name():
    """Test error handling for empty name."""
    with pytest.raises(ValueError, match="Name cannot be empty"):
        hello_world("")

    with pytest.raises(ValueError, match="Name cannot be empty"):
        hello_world("   ")


def test_hello_world_invalid_type():
    """Test error handling for invalid type."""
    with pytest.raises(TypeError, match="Name must be a string"):
        hello_world(123)

    with pytest.raises(TypeError, match="Name must be a string"):
        hello_world(None)


class TestHelloWorldIntegration:
    """Integration tests for hello_world functionality."""

    def test_multiple_greetings(self):
        """Test multiple greetings in sequence."""
        names = ["Alice", "Bob", "Charlie"]
        results = [hello_world(name) for name in names]

        expected = ["Hello, Alice!", "Hello, Bob!", "Hello, Charlie!"]
        assert results == expected

    def test_unicode_names(self):
        """Test greeting with unicode characters."""
        result = hello_world("世界")
        assert result == "Hello, 世界!"

        result = hello_world("José")
        assert result == "Hello, José!"
