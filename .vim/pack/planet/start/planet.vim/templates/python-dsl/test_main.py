import unittest
from main import evaluate
class ParserTests(unittest.TestCase):
    def test_add(self): self.assertEqual(evaluate('1 + 2 + -3'), 0)
    def test_invalid(self):
        with self.assertRaises(ValueError): evaluate('1; print(2)')
if __name__ == '__main__': unittest.main()
