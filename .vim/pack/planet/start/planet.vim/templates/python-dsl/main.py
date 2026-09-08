"""An addition DSL: a line contains one or more integers separated by +."""
import re

def evaluate(source):
    if not re.fullmatch(r"\s*[+-]?\d+(?:\s*\+\s*[+-]?\d+)*\s*", source):
        raise ValueError("Expected integers separated by +")
    return sum(int(value) for value in re.findall(r'[+-]?\d+', source.replace(' ', '')))

if __name__ == '__main__':
    import sys
    print(evaluate(' '.join(sys.argv[1:]) or '1 + 2'))
