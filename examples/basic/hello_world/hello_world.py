"""Hello world script."""

from pathlib import Path


def hello_world(file="output.txt"):
    """Create hello world file"""
    Path(file).write_text("Hello!", encoding="utf-8")


if __name__ == "__main__":
    hello_world("./output.txt")
