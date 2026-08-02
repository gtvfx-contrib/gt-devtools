if __name__ == "__main__":
    import argparse
    from pathlib import Path
    from PIL import Image

    parser = argparse.ArgumentParser(description="Convert PNG to ICO")
    parser.add_argument("source", type=Path, help="Source PNG file")
    parser.add_argument("output", type=Path, help="Output ICO file")
    args = parser.parse_args()

    source = args.source
    output = args.output

    if not source.exists():
        raise FileNotFoundError(f"Approved Envoy icon not found: {source}")

    icon = Image.open(source).convert("RGBA")

    sizes = [
        (16, 16),
        (20, 20),
        (24, 24),
        (32, 32),
        (40, 40),
        (48, 48),
        (64, 64),
        (128, 128),
        (256, 256),
    ]

    icon.save(output, format="ICO", sizes=sizes)

    print(f"Created {output}")
    print("Embedded sizes:", ", ".join(f"{w}×{h}" for w, h in sizes))
