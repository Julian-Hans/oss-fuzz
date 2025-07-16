#!/usr/bin/env python3
import sys

def gen_payload() -> bytes:
    # your logic here
    return b"your static input"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <output file>", file=sys.stderr)
        sys.exit(1)
    out_file = sys.argv[1]
    with open(out_file, "wb") as f:
        f.write(gen_payload())
