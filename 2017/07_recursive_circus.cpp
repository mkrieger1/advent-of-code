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
    }
}
