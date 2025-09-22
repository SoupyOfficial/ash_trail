"""Simple Hello World application for testing Python automation."""

__version__ = "1.0.0"


def hello_world(name: str = "World") -> str:
    """
    Return a greeting message.

    Args:
        name: The name to greet (default: "World")

    Returns:
        A greeting message string
    """
    if not isinstance(name, str):
        raise TypeError("Name must be a string")
    if not name.strip():
        raise ValueError("Name cannot be empty")

    return f"Hello, {name}!"


def main() -> None:
    """Main entry point."""
    print(hello_world())
    print(hello_world("Python"))


if __name__ == "__main__":
    main()
