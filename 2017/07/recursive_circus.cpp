#include <iostream>
#include <regex>
#include <stdexcept>
#include <unordered_map>
#include <vector>

class Program {
public:
    using Name = std::string;
    using Weight = int;

    struct InvalidFormat : public std::runtime_error {
        InvalidFormat() : std::runtime_error("Line has invalid format.") {};
    };

    Program() = default;
    Program(const Name& n, Weight w, std::vector<Name> supported)
      : name_{n}, weight_{w}, supported_{supported}
    {}

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

    const Name& name() const { return name_; }
    Weight weight() const { return weight_; }
    const std::vector<Name>& supported() const { return supported_; }

private:
    Name name_;
    Weight weight_;
    std::vector<Name> supported_;
};

class ProgramTower {
    // Map from name to program with that name.
    using NameMap = std::unordered_map<Program::Name, Program>;
    // Map from program name to name of supporting program.
    using SupportMap = std::unordered_map<Program::Name, Program::Name>;

    // Return a map of which program is supported by which.
    static SupportMap build_support_map(const NameMap& programs)
    {
        SupportMap result;
        for (auto const& name_prog : programs) {
            auto supporter{name_prog.second};
            for (auto const& supported : supporter.supported()) {
                result.insert({supported, supporter.name()});
            }
        }
        return result;
    }

    // Find the base program (the one which is not supported by any other).
    static Program::Name find_base(
        const NameMap& programs, const SupportMap& support)
    {
        for (auto const& name_prog : programs) {
            auto name{name_prog.first};
            if (support.find(name) == std::end(support)) return name;
        }
        throw std::runtime_error("No program is the base.");
    }

public:
    ProgramTower() = default;
    ProgramTower(const NameMap& programs)
      : programs_{programs},
        support_{build_support_map(programs_)},
        base_{find_base(programs_, support_)}
    {}

    friend std::istream& operator>>(std::istream& input, ProgramTower& tower)
    {
        NameMap programs;
        Program prog;
        while (input >> prog) programs.insert({prog.name(), prog});
        ProgramTower dummy{programs};
        std::swap(tower, dummy);
        return input;
    }

    // Return the total weight of the program with the given name, and all
    // sub-towers it is supporting.
    Program::Weight total_weight(const Program::Name& name)
    {
        auto base{programs_.at(name)};
        Program::Weight result{base.weight()};
        for (auto const& sub : base.supported()) {
            result += total_weight(sub);
        }
        return result;
    }
    Program::Weight total_weight() { return total_weight(base()); }

    // Determine which program in the tower supported by the program with the
    // given name has the wrong weight (i.e. causes a sub-tower to be
    // unbalanced), assuming that there is exactly one such program.
    struct BalanceResult {
        bool is_balanced;
        Program::Name name;
        Program::Weight correct_weight;
    };

    BalanceResult wrong_weight(const Program::Name& name)
    {
        // Map from weight to list of supported sub-towers with that weight.
        std::unordered_map<Program::Weight, std::vector<Program::Name>> weights;
        for (auto const& sub : programs_.at(name).supported()) {
            weights[total_weight(sub)].push_back(sub);
        }

        // One unique weight
        // -> This tower is balanced, no program in it has the wrong weight.
        if (weights.size() == 1) {
            return {true, "", 0};
        }

        // Not all supported sub-towers have the same total weight
        // -> One of the programs in the sub-towers has the wrong weight (given
        //    the problem statement we can assume that there is exactly one such
        //    program).
        //
        // -> For N sub-towers,
        //    N-1 sub-towers have total weight w1 (which is "correct")
        //    and 1 sub-tower has total weight w2 (which is "wrong")
        //
        // If the "wrong" sub-tower itself is balanced, then its base program
        // must be the one with the wrong weight. Otherwise it is obtained by
        // recursion.
        int correct_total_weight;
        Program::Name wrong_program;

        for (auto const& weight_subs : weights) {
            auto subs{weight_subs.second};
            if (subs.size() != 1) {
                correct_total_weight = weight_subs.first; // this is w1
                continue;
            }
            // w2 case
            for (auto const& sub : subs) {
                auto result{wrong_weight(sub)};
                if (!result.is_balanced) {
                    return result;
                } else {
                    wrong_program = sub;
                    continue;
                }
            }
        }

        // Determine correct weight of the "wrong" program.
        auto correct_weight{
            programs_.at(wrong_program).weight()
            + correct_total_weight - total_weight(wrong_program)
        };
        return {false, wrong_program, correct_weight};
    }
    BalanceResult wrong_weight() { return wrong_weight(base()); }

    Program::Name base() const { return base_; }

private:
    NameMap programs_;
    SupportMap support_;
    Program::Name base_;
};


int main()
{
    ProgramTower tower;
    std::cin >> tower;
    auto name{tower.base()};

    std::cout << "Program '" << name
              << "' is the base of the tower of programs.\n";

    std::cout << "The total weight of the sub-tower starting from '" << name
              << "' is " << tower.total_weight(name) << ".\n";

    auto wrong{tower.wrong_weight(name)};
    std::cout << "The sub-tower supported by '" << name << "' is "
              << (wrong.is_balanced ? "" : "not ")
              << "balanced.\n";

    std::cout << "Program '" << wrong.name << "' has the wrong weight.\n";

    std::cout << "Its weight would need to be "
              << wrong.correct_weight << ".\n";
}
