#include "machine.h"
#include <regex>
#include <stdexcept>
#include <string>

Machine::Instruction::Operation
Machine::Instruction::to_operation(const std::string& s)
{
    if (s == "inc") return Operation::Inc;
    if (s == "dec") return Operation::Dec;
    throw std::runtime_error("Unknown operation.");
}

Machine::Instruction::Comparison
Machine::Instruction::to_comparison(const std::string& s)
{
    if (s == "==") return Comparison::Equal;
    if (s == "!=") return Comparison::Unequal;
    if (s == "<" ) return Comparison::Less;
    if (s == "<=") return Comparison::LessEqual;
    if (s == ">" ) return Comparison::Greater;
    if (s == ">=") return Comparison::GreaterEqual;
    throw std::runtime_error("Unknown comparison.");
}

bool Machine::Instruction::evaluate(
    Comparison cmp, RegisterValue a, RegisterValue b)
{
    switch (cmp) {
    case Comparison::Equal:        return a == b;
    case Comparison::Unequal:      return a != b;
    case Comparison::Less:         return a <  b;
    case Comparison::LessEqual:    return a <= b;
    case Comparison::Greater:      return a >  b;
    case Comparison::GreaterEqual: return a >= b;
    }
}

Machine::Instruction::Instruction(const std::string& line)
{
    std::smatch line_match;
    if (!std::regex_match(line, line_match,
        std::regex{R"((\w+) (\w+) ([+-]?\d+) if (\w+) (\W+) ([+-]?\d+))"}
    )) throw std::runtime_error{"Invalid format."};

    target = line_match[1];
    operation = to_operation(line_match[2]);
    operation_amount = stoi(line_match[3]);
    source = line_match[4];
    comparison = to_comparison(line_match[5]);
    compare_value = stoi(line_match[6]);
}

std::istream& operator>>(std::istream& input, Machine::Instruction& i)
{
    std::string line;
    while (std::getline(input, line)) {
        //try {
            Machine::Instruction dummy{line};
            std::swap(i, dummy);
            break;
        //} catch (std::runtime_error) {
        //    continue; // TODO use custom exception, abort program
        //}
    }
    return input;
}

Machine::RegisterValue Machine::max_value() const
{
    // TODO make smarter
    RegisterValue current_max{0};
    for (auto const& name_value : registers_) {
        auto value{name_value.second};
        if (value > current_max) current_max = value;
    }
    return current_max;
}

void Machine::execute(const Instruction& i)
{
    RegisterValue src{registers_[i.source]};
    if (Instruction::evaluate(i.comparison, src, i.compare_value)) {
        RegisterValue& target{registers_[i.target]};
        switch (i.operation) {
        case Instruction::Operation::Inc:
            target += i.operation_amount;
            break;
        case Instruction::Operation::Dec:
            target -= i.operation_amount;
            break;
        }
        if (target > all_time_max_) all_time_max_ = target;
    }
}
