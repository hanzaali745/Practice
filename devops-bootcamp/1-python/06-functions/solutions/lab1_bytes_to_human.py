#!/usr/bin/env python3
def bytes_to_human(n: int) -> str:
    """Convert a byte count to a human-readable string (1024 based)."""
    size = float(n)
    for unit in ["B", "KB", "MB", "GB", "TB"]:
        if size < 1024 or unit == "TB":
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} TB"  # unreachable, keeps type checkers happy


if __name__ == "__main__":
    for value in [512, 1536, 5 * 1024**2, 3.2 * 1024**3, 7 * 1024**4]:
        print(value, "->", bytes_to_human(value))
