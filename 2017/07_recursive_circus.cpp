#include <iostream>
#include <regex>
#include <stdexcept>
#include <unordered_map>
#include <vector>

class Program {
    struct InvalidFormat : public std::runtime_error {
        InvalidFormat() : std::runtime_error("Line has invalid format.") {};
    };

public:
    Program() = default;
    Program(const std::string& line)
    {
        std::smatch line_match;
        if (!std::regex_match(line, line_match,
                std::regex{R"((\w+) \((\d+)\)(?: -> ((?:\w+(, |$))+))?)"}
        )) throw InvalidFormat{};

        name_ = line_match[1];
        weight_ = std::stoi(line_match[2]);

        auto names{line_match[3]};
        if (!names.length()) return;

        auto names_str{names.str()};
        std::smatch names_match;
        while (std::regex_search(names_str, names_match,
                std::regex{R"(\w+)"}
        )) {
            supported_.push_back(names_match.str());
            names_str = names_match.suffix();
        }
    }

    friend std::istream& operator>>(std::istream& input, Program& prog)
    {
        std::string line;
        while (std::getline(std::cin, line)) {
            try {
                Program dummy{line};
                std::swap(prog, dummy);
                break;
            } catch (InvalidFormat) {
                continue;
            }
        }
        return input;
    }

    const std::string& name() const { return name_; }
    int weight() const { return weight_; }
    const std::vector<std::string>& supported() const { return supported_; }

private:
    std::string name_;
    int weight_;
    std::vector<std::string> supported_;
};

using ProgramTower = std::unordered_map<std::string, Program>;

// Return map: program name -> name of supporting program
std::unordered_map<std::string, std::string>
supporter_map(const ProgramTower& programs)
{
    std::unordered_map<std::string, std::string> result;
    for (auto const& name_prog : programs) {
        auto supporter{name_prog.second};
        for (auto const& supported : supporter.supported()) {
            result[supported] = supporter.name();
        }
    }
    return result;
}

// Return total weight of the program with the given name, and all sub-towers
// it is supporting.
int total_weight(const ProgramTower& programs, const std::string& name)
{
    auto base{programs.at(name)};
    int result{base.weight()};
    for (auto const& sub : base.supported()) {
        result += total_weight(programs, sub);
    }
    return result;
}

// Determing which program in the tower supported by the program with the given
// name has the wrong weight (i.e. causes a sub-tower to be unbalanced).
// Assumes that there is exactly one such program.
struct SearchResult {
    bool is_balanced;
    std::string name;
    int correct_weight;
};

SearchResult wrong_weight(const ProgramTower& programs, const std::string& name)
{
    std::cout << "---------------- wrong weight: " << name << " --------------------\n";

    std::unordered_map<int, std::vector<std::string>> weights;
    for (auto const& sub : programs.at(name).supported()) {
        weights[total_weight(programs, sub)].push_back(sub);
    }

    for (auto const& weight_subs : weights) {
        std::cout << "weight: " << weight_subs.first;
        for (auto const& sub : weight_subs.second) {
            std::cout << ' ' << sub;
        }
        std::cout << '\n';
    }

    if (weights.size() == 1) {
        std::cout << "-------------end wrong weight: " << name << "--------------------\n";

        return {true, "", 0}; // name is balanced
    }

    int correct_total_weight;
    std::string wrong_program;

    for (auto const& weight_subs : weights) {
        auto subs{weight_subs.second};
        if (subs.size() != 1) {
            correct_total_weight = weight_subs.first;

            std::cout << "correct total weight: " << correct_total_weight << '\n';

            continue;
        }
        // subs contains single sub-program with the wrong total weight
        // if the sub-towers are balanced, sub itself is wrong
        for (auto const& sub : subs) {
            auto result{wrong_weight(programs, sub)};
            if (!result.is_balanced) {
                std::cout << sub << " is not balanced\n";

                std::cout << "-------------end wrong weight: " << name << "--------------------\n";

                return result;
            } else {
                std::cout << sub << " is the wrong program\n";

                wrong_program = sub;
                continue;
            }
        }
    }
    auto correct_weight{
        programs.at(wrong_program).weight()
        + correct_total_weight - total_weight(programs, wrong_program)
    };

    std::cout << "-------------end wrong weight: " << name << "--------------------\n";

    return {true, wrong_program, correct_weight};
}

int main()
{
    ProgramTower programs_by_name;
    Program prog;
    while (std::cin >> prog) {
        programs_by_name.insert({prog.name(), prog});
    }

    auto supporters{supporter_map(programs_by_name)};
    for (auto const& name_prog : programs_by_name) {
        auto name{name_prog.first};
        if (supporters.find(name) != std::end(supporters)) continue;
        std::cout << name << " not supported by any program!\n";
        std::cout << "The total weight supported by " << name
                  << " is " << total_weight(programs_by_name, name) << '\n';

        auto wrong{wrong_weight(programs_by_name, name)};
        std::cout << "The sub-tower supported by " << name << " is "
                  << (wrong.is_balanced ? "" : "not ")
                  << "balanced\n";
        std::cout << "Program " << wrong.name << " has the wrong weight.\n";
        std::cout << "Its weight would need to be " << wrong.correct_weight << '\n';
    }
}
