#include <iostream>
#include <limits>
#include <sstream>
#include <stdexcept>
#include <string>
long evaluate(const std::string &source) {
    std::istringstream in(source); long total, value; char op;
    if (!(in >> total)) throw std::runtime_error("expected integer");
    while (in >> op) {
        if (op != '+' || !(in >> value)) throw std::runtime_error("expected + integer");
        if ((value > 0 && total > std::numeric_limits<long>::max() - value)
            || (value < 0 && total < std::numeric_limits<long>::min() - value))
            throw std::runtime_error("integer overflow");
        total += value;
    }
    return total;
}
int main(int argc, char **argv) {
    try { std::cout << evaluate(argc > 1 ? argv[1] : "1 + 2") << '\n'; }
    catch (const std::exception &e) { std::cerr << e.what() << '\n'; return 1; }
}
