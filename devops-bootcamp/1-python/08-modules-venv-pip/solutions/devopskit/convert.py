def bytes_to_human(n: float) -> str:
    """Convert a byte count to a human-readable string (1024 based)."""
    size = float(n)
    for unit in ["B", "KB", "MB", "GB"]:
        if size < 1024:
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} TB"
