def methods(obj):
    """Print public methods of an object."""
    print(*[m for m in dir(obj) if not m.startswith("_")], sep="\n")
