#pragma once
#include <string>
#include <utility>
class Example {
public:
    explicit Example(std::string name) : name_(std::move(name)) {}
    const std::string &name() const noexcept { return name_; }
private:
    std::string name_;
};
