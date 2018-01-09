#include "recursive_circus.h"
#include <regex>

Program::InvalidFormat::InvalidFormat()
  : std::runtime_error("Line has invalid format.")
{}

Program::Program(const Name& n, Weight w, std::vector<Name> supported)
  : name_{n}, weight_{w}, supported_{supported}
{}

Program::Program(const std::string& line)
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

std::istream& operator>>(std::istream& input, Program& prog)
{
    std::string line;
    while (std::getline(input, line)) {
        try {
            Program dummy{line};
            std::swap(prog, dummy);
            break;
        } catch (Program::InvalidFormat) {
            continue;
        }
    }
    return input;
}


// Return a map of which program is supported by which.
ProgramTower::SupportMap
ProgramTower::build_support_map(const NameMap& programs)
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
Program::Name
ProgramTower::find_base(const NameMap& programs, const SupportMap& support)
{
    for (auto const& name_prog : programs) {
        auto name{name_prog.first};
        if (support.find(name) == std::end(support)) return name;
    }
    throw std::runtime_error("No program is the base.");
}

ProgramTower::ProgramTower(const NameMap& programs)
  : programs_{programs},
    support_{build_support_map(programs_)},
    base_{find_base(programs_, support_)}
{}

ProgramTower::ProgramTower(const std::vector<Program>& programs)
{
    NameMap map;
    for (auto const& prog : programs) map.insert({prog.name(), prog});
    ProgramTower dummy{map};
    std::swap(*this, dummy);
}

std::istream& operator>>(std::istream& input, ProgramTower& tower)
{
    ProgramTower::NameMap programs;
    Program prog;
    while (input >> prog) programs.insert({prog.name(), prog});
    ProgramTower dummy{programs};
    std::swap(tower, dummy);
    return input;
}

// Return the total weight of the program with the given name, and all
// sub-towers it is supporting.
Program::Weight ProgramTower::total_weight(const Program::Name& name)
{
    auto base{programs_.at(name)};
    Program::Weight result{base.weight()};
    for (auto const& sub : base.supported()) {
        result += total_weight(sub);
    }
    return result;
}

// Determine which program in the tower supported by the program with the
// given name has the wrong weight (i.e. causes a sub-tower to be unbalanced),
// assuming that there is exactly one such program.
ProgramTower::BalanceResult ProgramTower::wrong_weight(const Program::Name& name)
{
    auto supported{programs_.at(name).supported()};
    if (!supported.size()) {
        return {true, "", 0};
    }

    // Map from weight to list of supported sub-towers with that weight.
    std::unordered_map<Program::Weight, std::vector<Program::Name>> weights;
    for (auto const& sub : supported) {
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
            if (!result.balanced) {
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
