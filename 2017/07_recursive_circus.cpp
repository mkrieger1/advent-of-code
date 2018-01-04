#include <iostream>
#include <regex>
#include <stdexcept>
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

    void print()
    {
        std::cout << "name: " << name_ << '\n';
        std::cout << "weight: " << weight_ << '\n';
        std::cout << "supports:\n";
        for (auto const& name : supported_) {
            std::cout << name << '\n';
        }
    }

private:
    std::string name_;
    int weight_;
    std::vector<std::string> supported_;
};

int main()
{
    Program prog;
    while (std::cin >> prog) {
        prog.print();
    }
}
