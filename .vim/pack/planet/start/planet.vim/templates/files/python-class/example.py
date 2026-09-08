from dataclasses import dataclass


@dataclass
class Example:
    name: str

    def greeting(self) -> str:
        return f"Hello, {self.name}"
